
-- 4.2 Company Hiring Pattern Analysis
DELIMITER $$
CREATE PROCEDURE AnalyzeHiringPatterns(IN company_id BIGINT)
BEGIN
    SELECT 
        YEAR(j.posted_date) as year,
        MONTH(j.posted_date) as month,
        COUNT(*) as jobs_posted,
        COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) as jobs_filled,
        ROUND(COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as fill_rate_pct,
        AVG(DATEDIFF(j.filled_date, j.posted_date)) as avg_time_to_fill,
        AVG(j.applications_count) as avg_applications,
        -- Skill distribution
        GROUP_CONCAT(DISTINCT s.skill_category) as skill_categories,
        -- Benefits offered
        COUNT(DISTINCT jb.benefit_id) as unique_benefits_offered
    FROM jobs j
    LEFT JOIN job_skills js ON j.job_id = js.job_id
    LEFT JOIN skills s ON js.skill_id = s.skill_id
    LEFT JOIN job_benefits jb ON j.job_id = jb.job_id
    WHERE j.company_id = company_id
    GROUP BY YEAR(j.posted_date), MONTH(j.posted_date)
    ORDER BY year DESC, month DESC;
END$$
DELIMITER ;


