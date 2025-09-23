-- Query 1: Top Skills by Industry with Growth Trends
SELECT 
    i.industry_name,
    s.skill_name,
    COUNT(j.job_id) as total_jobs,
    COUNT(CASE WHEN j.posted_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 1 END) as recent_jobs,
    ROUND((COUNT(CASE WHEN j.posted_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 1 END) - 
           COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 1 END)) * 100.0 / 
           NULLIF(COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 1 END), 0), 2) as growth_rate_pct,
    RANK() OVER (PARTITION BY i.industry_name ORDER BY COUNT(j.job_id) DESC) as skill_rank_in_industry
FROM industries i
INNER JOIN job_industries ji ON i.industry_id = ji.industry_id
INNER JOIN jobs j ON ji.job_id = j.job_id
INNER JOIN job_skills js ON j.job_id = js.job_id
INNER JOIN skills s ON js.skill_abr = s.skill_abr
WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY i.industry_id, s.skill_id
HAVING total_jobs >= 3
ORDER BY i.industry_name, skill_rank_in_industry;

-- Query 2: Company Hiring Velocity vs Employee Growth Correlation
SELECT
    c.name AS company_name,
    c.company_size,
    COUNT(j.job_id) AS jobs_posted_last_year,
    ROUND(COUNT(j.job_id) / 12.0, 1) AS avg_jobs_per_month,
    cm_first.employee_count AS initial_employees,
    cm_last.employee_count AS current_employees,
    ROUND((cm_last.employee_count - cm_first.employee_count) * 100.0 / NULLIF(cm_first.employee_count, 0), 2) AS employee_growth_pct,
    ROUND(COUNT(j.job_id) * 100.0 / NULLIF(cm_first.employee_count, 0), 2) AS hiring_ratio,
    CASE
        WHEN COUNT(j.job_id) * 100.0 / NULLIF(cm_first.employee_count, 0) > 50 THEN 'High Growth'
        WHEN COUNT(j.job_id) * 100.0 / NULLIF(cm_first.employee_count, 0) > 20 THEN 'Moderate Growth'
        ELSE 'Stable'
    END AS growth_category
FROM companies c
LEFT JOIN jobs j ON c.company_id = j.company_id AND j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
JOIN (
    SELECT company_id, MIN(metric_date) AS min_date, MAX(metric_date) AS max_date
    FROM company_metrics
    GROUP BY company_id
) AS cm_dates ON c.company_id = cm_dates.company_id
LEFT JOIN company_metrics cm_first ON c.company_id = cm_first.company_id AND cm_first.metric_date = cm_dates.min_date
LEFT JOIN company_metrics cm_last ON c.company_id = cm_last.company_id AND cm_last.metric_date = cm_dates.max_date
WHERE cm_first.employee_count IS NOT NULL
    AND cm_last.employee_count IS NOT NULL
GROUP BY c.company_id, c.company_size, cm_first.employee_count, cm_last.employee_count
HAVING jobs_posted_last_year > 0
ORDER BY hiring_ratio DESC;

-- Query 3: Job Success Rate by Benefits Package Analysis
WITH benefit_packages AS (
    SELECT 
        j.job_id,
        GROUP_CONCAT(bt.benefit_category ORDER BY bt.benefit_category) as benefit_package,
        COUNT(bt.benefit_id) as benefit_count,
        SUM(bt.benefit_value_score) as total_benefit_score
    FROM jobs j
    LEFT JOIN job_benefits_normalized jb ON j.job_id = jb.job_id
    LEFT JOIN benefit_types bt ON jb.benefit_id = bt.benefit_id
    GROUP BY j.job_id
)
SELECT 
    bp.benefit_package,
    bp.benefit_count,
    COUNT(j.job_id) as total_jobs,
    COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) as filled_jobs,
    ROUND(COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(j.job_id), 2) as fill_rate_pct,
    AVG(j.applications_count) as avg_applications,
    AVG(DATEDIFF(j.filled_date, j.posted_date)) as avg_time_to_fill,
    AVG(bp.total_benefit_score) as avg_benefit_score
FROM jobs j
INNER JOIN benefit_packages bp ON j.job_id = bp.job_id
WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY bp.benefit_package, bp.benefit_count
HAVING total_jobs >= 5
ORDER BY fill_rate_pct DESC, avg_applications DESC;

-- Query 4: Geographic Job Distribution with Market Competitiveness
WITH company_job_counts AS (
    SELECT
        company_id,
        COUNT(*) AS job_count,
        AVG(applications_count) AS avg_applications
    FROM jobs
    WHERE posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY company_id
),
company_skills_counts AS (
    SELECT
        j.company_id,
        COUNT(DISTINCT js.skill_abr) AS unique_skills
    FROM jobs j
    INNER JOIN job_skills js ON j.job_id = js.job_id
    WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY j.company_id
),
regional_totals AS (
    -- Calculate regional totals first
    SELECT
        c.state,
        c.country,
        COUNT(DISTINCT c.company_id) AS unique_companies,
        SUM(cjc.job_count) AS total_jobs,
        SUM(csc.unique_skills) AS unique_skills_demanded,
        AVG(cjc.avg_applications) AS avg_competition
    FROM companies c
    INNER JOIN company_job_counts cjc ON c.company_id = cjc.company_id
    LEFT JOIN company_skills_counts csc ON c.company_id = csc.company_id
    WHERE c.state IS NOT NULL
    GROUP BY c.state, c.country
    HAVING SUM(cjc.job_count) >= 10
)
SELECT
    rt.state,
    rt.country,
    rt.unique_companies,
    rt.total_jobs,
    rt.unique_skills_demanded,
    rt.avg_competition,
    ROUND(rt.total_jobs * 1.0 / rt.unique_companies, 1) AS jobs_per_company,
    -- Calculate market concentration using the pre-calculated total
    ROUND(SUM(POWER(cjc.job_count * 100.0 / rt.total_jobs, 2)), 4) AS market_concentration_index
FROM regional_totals rt
INNER JOIN companies c ON c.state = rt.state AND c.country = rt.country
INNER JOIN company_job_counts cjc ON c.company_id = cjc.company_id
WHERE c.state IS NOT NULL
GROUP BY rt.state, rt.country, rt.unique_companies, rt.total_jobs, rt.unique_skills_demanded, rt.avg_competition
ORDER BY rt.total_jobs DESC;

-- Query 5: Cohort Retention Analysis with Statistical Significance
INSERT INTO cohort_metrics (cohort_id, metric_name, metric_value, measurement_date, period_number)
VALUES 
(1, 'job_fill_rate', 65.5, '2024-09-01', 0),
(1, 'job_fill_rate', 58.2, '2024-12-01', 3),
(1, 'job_fill_rate', 52.1, '2025-03-01', 6);

WITH cohort_performance AS (
    SELECT 
        c.cohort_name,
        c.cohort_type,
        c.start_date,
        COUNT(cm.entity_id) as cohort_size,
        AVG(CASE WHEN co_m.period_number = 0 THEN co_m.metric_value END) as period_0_value,
        AVG(CASE WHEN co_m.period_number = 3 THEN co_m.metric_value END) as period_3_value,
        AVG(CASE WHEN co_m.period_number = 6 THEN co_m.metric_value END) as period_6_value
    FROM cohorts c
    INNER JOIN cohort_memberships cm ON c.cohort_id = cm.cohort_id
    LEFT JOIN cohort_metrics co_m ON c.cohort_id = co_m.cohort_id
    WHERE c.is_active = TRUE
    GROUP BY c.cohort_id
)
SELECT 
    cohort_name,
    cohort_type,
    cohort_size,
    ROUND(period_0_value, 2) as initial_performance,
    ROUND(period_6_value, 2) as six_month_performance,
    ROUND(((period_6_value - period_0_value) / NULLIF(period_0_value, 0)) * 100, 2) as performance_change_pct
FROM cohort_performance
WHERE period_0_value IS NOT NULL;

-- SELECT COUNT(*) as total_jobs, 
--        COUNT(filled_date) as filled_jobs,
--        COUNT(applications_count) as jobs_with_applications
-- FROM jobs;

-- -- Check date ranges in your data
-- SELECT MIN(posted_date), MAX(posted_date) FROM jobs;

-- SET SQL_SAFE_UPDATES = 0;

-- UPDATE jobs SET 
--     filled_date = DATE_ADD(posted_date, INTERVAL FLOOR(RAND() * 45) + 15 DAY)
-- WHERE RAND() < 0.7;

-- SET SQL_SAFE_UPDATES = 1;

-- First, generate cohort metrics
CALL AnalyzeCohortPerformance(1, 'job_fill_rate');
