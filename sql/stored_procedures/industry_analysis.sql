
-- 4.3 Industry Competition Analysis
DELIMITER $$
CREATE PROCEDURE AnalyzeIndustryCompetition(IN industry_name VARCHAR(255))
BEGIN
    SELECT 
        c.name as company_name,
        c.company_size_category,
        c.headquarters_location,
        COUNT(j.job_id) as total_jobs_posted,
        COUNT(CASE WHEN j.posted_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 1 END) as recent_jobs,
        AVG(j.applications_count) as avg_applications_per_job,
        COUNT(DISTINCT js.skill_id) as unique_skills_required,
        COUNT(DISTINCT jb.benefit_id) as unique_benefits_offered,
        -- Calculate hiring velocity
        COUNT(j.job_id) / GREATEST(DATEDIFF(MAX(j.posted_date), MIN(j.posted_date)), 1) * 30 as jobs_per_month,
        -- Market share in this industry
        ROUND(COUNT(j.job_id) * 100.0 / (
            SELECT COUNT(*) 
            FROM jobs j2 
            INNER JOIN job_industries ji2 ON j2.job_id = ji2.job_id
            INNER JOIN industries i2 ON ji2.industry_id = i2.industry_id
            WHERE i2.industry_name = industry_name
        ), 2) as market_share_pct
    FROM companies c
    INNER JOIN company_industries ci ON c.company_id = ci.company_id
    INNER JOIN industries i ON ci.industry_id = i.industry_id
    INNER JOIN jobs j ON c.company_id = j.company_id
    LEFT JOIN job_skills js ON j.job_id = js.job_id
    LEFT JOIN job_benefits jb ON j.job_id = jb.job_id
    WHERE i.industry_name = industry_name
      AND j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY c.company_id, c.name, c.company_size_category, c.headquarters_location
    HAVING total_jobs_posted >= 1
    ORDER BY recent_jobs DESC, total_jobs_posted DESC;
END$$

DELIMITER ;
