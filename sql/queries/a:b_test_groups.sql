-- 3.2 Assign Entities to A/B Test Groups
DELIMITER $$

CREATE PROCEDURE AssignToABTest(
    IN test_id INT,
    IN entity_type ENUM('job', 'company'),
    IN sample_size INT
)
BEGIN
    DECLARE control_group_id INT;
    DECLARE treatment_group_id INT;
    
    -- Get group IDs
    SELECT group_id INTO control_group_id 
    FROM ab_test_groups 
    WHERE ab_test_groups.test_id = test_id AND group_type = 'control' LIMIT 1;
    
    SELECT group_id INTO treatment_group_id 
    FROM ab_test_groups 
    WHERE ab_test_groups.test_id = test_id AND group_type = 'treatment' LIMIT 1;
    
    -- Assign entities (50/50 split)
    IF entity_type = 'job' THEN
        INSERT INTO ab_test_assignments (test_id, group_id, entity_type, entity_id)
        SELECT 
            test_id,
            CASE WHEN (@row_number := @row_number + 1) % 2 = 0 THEN control_group_id ELSE treatment_group_id END,
            'job',
            job_id
        FROM (
            SELECT job_id FROM jobs ORDER BY RAND() LIMIT sample_size
        ) random_jobs
        CROSS JOIN (SELECT @row_number := 0) r;
    END IF;
    
    SELECT CONCAT('Assigned ', sample_size, ' entities to A/B test') as Result;
END$$

DELIMITER ;