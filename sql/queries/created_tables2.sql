-- STEP 3: POPULATE THE MAIN TABLES FROM YOUR EXISTING DATA
-- ============================================================================

-- 3.1 Create job records from existing job_skills and job_industries data
INSERT IGNORE INTO jobs (job_id, company_id, posted_date, created_at)
SELECT DISTINCT
    js.job_id,
    COALESCE(c.company_id, 1009) AS company_id,
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 365) DAY) AS posted_date,
    NOW() AS created_at
FROM job_skills js
LEFT JOIN job_industries ji ON js.job_id = ji.job_id
LEFT JOIN industries i ON ji.industry_id = i.industry_id
LEFT JOIN company_industries ci ON TRIM(ci.industry) = i.industry_name
LEFT JOIN companies c ON ci.company_id = c.company_id
WHERE js.job_id IS NOT NULL;

-- INSERT INTO jobs (job_id, company_id, posted_date, created_at)
-- SELECT DISTINCT 
--     js.job_id,
--     -- Try to match company_id from industries, or use a default
--     COALESCE(
--         (SELECT c.company_id 
--          FROM companies c 
--          INNER JOIN company_industries ci ON c.company_id = ci.company_id 
--          INNER JOIN job_industries ji ON TRIM(ci.industry) = (
--              SELECT i.industry_name 
--              FROM industries i 
--              WHERE i.industry_id = ji.industry_id LIMIT 1
--          )
--          WHERE ji.job_id = js.job_id LIMIT 1), 
--         1009  -- Default to IBM's company_id if no match found
--     ) as company_id,
--     -- Generate random dates in the past year for demo purposes
--     DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 365) DAY) as posted_date,
--     NOW() as created_at
-- FROM job_skills js
-- WHERE js.job_id IS NOT NULL;

-- --Adding few missing company_id into companies table
INSERT INTO companies (company_id, name, description)
SELECT DISTINCT 
    ec.company_id,
    CONCAT('Company_', ec.company_id) as name,
    'Auto-generated from employee_counts data' as description
FROM employee_counts ec
LEFT JOIN companies c ON ec.company_id = c.company_id
WHERE c.company_id IS NULL
  AND ec.company_id IS NOT NULL;

-- 3.2 Migrate Employee Counts to Company Metrics
INSERT INTO company_metrics (company_id, employee_count, follower_count, time_recorded, metric_date, year_mon)
SELECT 
    company_id,
    employee_count,
    follower_count,
    STR_TO_DATE(time_recorded, '%c/%e/%y %l:%i %p') as time_recorded,
    DATE(STR_TO_DATE(time_recorded, '%c/%e/%y %l:%i %p')) as metric_date,
    DATE_FORMAT(STR_TO_DATE(time_recorded, '%c/%e/%y %l:%i %p'), '%Y-%m') as year_mon
FROM employee_counts
WHERE company_id IS NOT NULL 
  AND time_recorded IS NOT NULL 
  AND time_recorded != '';