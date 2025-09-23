-- TRIGGERS FOR AUTOMATED ANALYTICS
-- ============================================================================

-- Trigger 1: Auto-assign jobs to cohorts when inserted
DELIMITER $
CREATE TRIGGER job_cohort_assignment 
AFTER INSERT ON jobs
FOR EACH ROW
BEGIN
    -- Assign to time-based cohorts
    INSERT INTO cohort_memberships (cohort_id, entity_type, entity_id)
    SELECT c.cohort_id, 'job', NEW.job_id
    FROM cohorts c
    WHERE c.cohort_type = 'time_based'
      AND c.is_active = TRUE
      AND NEW.posted_date BETWEEN c.start_date AND c.end_date;
    
    -- Log the event
    INSERT INTO analytics_events (event_type, entity_type, entity_id, event_properties)
    VALUES ('job_posted', 'job', NEW.job_id, JSON_OBJECT('company_id', NEW.company_id, 'posted_date', NEW.posted_date));
END$

-- Trigger 2: Update skill demand scores when jobs are posted
CREATE TRIGGER update_skill_demand
AFTER INSERT ON job_skills
FOR EACH ROW
BEGIN
    UPDATE skills 
    SET demand_score = demand_score + 1,
        updated_at = NOW()
    WHERE skill_id = NEW.skill_abr;
    
    -- Log skill usage
    INSERT INTO analytics_events (event_type, entity_type, entity_id, event_properties)
    VALUES ('skill_demanded', 'skill', NEW.skill_abr, JSON_OBJECT('job_id', NEW.job_id));
END$

-- Trigger 3: Track company growth metrics automatically
CREATE TRIGGER company_growth_tracker
AFTER INSERT ON company_metrics
FOR EACH ROW
BEGIN
    DECLARE prev_employee_count INT DEFAULT 0;
    DECLARE growth_rate DECIMAL(10,2) DEFAULT 0;
    
    -- Get previous employee count
    SELECT employee_count INTO prev_employee_count
    FROM company_metrics cm
    WHERE cm.company_id = NEW.company_id 
      AND cm.metric_date < NEW.metric_date
    ORDER BY cm.metric_date DESC
    LIMIT 1;
    
    -- Calculate growth rate
    IF prev_employee_count > 0 THEN
        SET growth_rate = (NEW.employee_count - prev_employee_count) * 100.0 / prev_employee_count;
        
        -- Auto-assign to high growth cohort if growth > 20%
        IF growth_rate > 20 THEN
            INSERT IGNORE INTO cohort_memberships (cohort_id, entity_type, entity_id)
            SELECT c.cohort_id, 'company', NEW.company_id
            FROM cohorts c
            WHERE c.cohort_name = 'High Growth Companies';
        END IF;
    END IF;
    
-- Log growth event
    INSERT INTO analytics_events (event_type, entity_type, entity_id, event_properties)
    VALUES ('company_growth_tracked', 'company', NEW.company_id, 
            JSON_OBJECT('growth_rate', growth_rate, 'new_employee_count', NEW.employee_count));
END$

-- Trigger 4: Auto-update A/B test assignments
CREATE TRIGGER ab_test_auto_assignment
AFTER INSERT ON jobs
FOR EACH ROW
BEGIN
    DECLARE active_test_count INT DEFAULT 0;
    
    -- Check for active A/B tests
    SELECT COUNT(*) INTO active_test_count
    FROM ab_tests
    WHERE status = 'active' 
      AND start_date <= NEW.posted_date 
      AND (end_date IS NULL OR end_date >= NEW.posted_date);
    
    -- Assign to active tests
    IF active_test_count > 0 THEN
        INSERT INTO ab_test_assignments (test_id, group_id, entity_type, entity_id)
        SELECT 
            at.test_id,
            atg.group_id,
            'job',
            NEW.job_id
        FROM ab_tests at
        INNER JOIN ab_test_groups atg ON at.test_id = atg.test_id
        WHERE at.status = 'active'
          AND at.start_date <= NEW.posted_date
          AND (at.end_date IS NULL OR at.end_date >= NEW.posted_date)
          AND RAND() * 100 <= atg.allocation_percentage
        LIMIT 1;
    END IF;
END$

DELIMITER ;
