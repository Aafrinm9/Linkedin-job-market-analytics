-- Query 6: A/B Test Statistical Analysis with Effect Size

UPDATE ab_tests SET status = 'completed' WHERE test_id = 1;

SELECT 
    at.test_name,
    at.test_type,
    at.success_metric,
    atg.group_name,
    COUNT(ata.entity_id) as sample_size,
    AVG(atr.metric_value) as mean_value,
    STDDEV(atr.metric_value) as std_deviation,
    -- Confidence intervals
    AVG(atr.metric_value) - (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_lower,
    AVG(atr.metric_value) + (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_upper,
    -- Effect size calculation (will be completed with control group comparison)
    ROW_NUMBER() OVER (PARTITION BY at.test_id ORDER BY atg.group_type) as group_order
FROM ab_tests at
INNER JOIN ab_test_groups atg ON at.test_id = atg.test_id
INNER JOIN ab_test_assignments ata ON atg.group_id = ata.group_id
INNER JOIN ab_test_results atr ON atg.group_id = atr.group_id AND ata.entity_id = atr.entity_id
WHERE at.status = 'completed'
GROUP BY at.test_id, atg.group_id
HAVING sample_size >= 30;

-- Check current test status
SELECT * FROM ab_tests;
SELECT * FROM ab_test_assignments LIMIT 5;

-- If needed, add sample test results
INSERT INTO ab_test_results (test_id, group_id, entity_id, metric_name, metric_value)
SELECT 1, ata.group_id, ata.entity_id, 'application_rate', 
       CASE WHEN atg.group_type = 'control' THEN RAND() * 20 + 10
            ELSE RAND() * 25 + 15 END
FROM ab_test_assignments ata
INNER JOIN ab_test_groups atg ON ata.group_id = atg.group_id;

-- Query 6.1: A/B Test Statistical Analysis
SELECT 
    at.test_name,
    at.test_type,
    at.success_metric,
    atg.group_name,
    COUNT(ata.entity_id) as sample_size,
    AVG(atr.metric_value) as mean_value,
    STDDEV(atr.metric_value) as std_deviation,
    -- Confidence intervals
    AVG(atr.metric_value) - (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_lower,
    AVG(atr.metric_value) + (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_upper
FROM ab_tests at
INNER JOIN ab_test_groups atg ON at.test_id = atg.test_id
INNER JOIN ab_test_assignments ata ON atg.group_id = ata.group_id
INNER JOIN ab_test_results atr ON atg.group_id = atr.group_id AND ata.entity_id = atr.entity_id
WHERE at.status = 'completed'
GROUP BY at.test_id, atg.group_id
HAVING sample_size >= 30
ORDER BY atg.group_type;

-- Query 7: Cross-Industry Skill Migration Patterns
CREATE TEMPORARY TABLE temp_industry_skill_counts AS
SELECT
    ji.industry_id,
    COUNT(jsn.skill_id) AS total_skills
FROM job_industries ji
INNER JOIN job_skills_normalized jsn ON ji.job_id = jsn.job_id
GROUP BY ji.industry_id;

CREATE TEMPORARY TABLE temp_skill_overlaps AS
SELECT
    ji1.industry_id AS source_industry_id,
    ji2.industry_id AS target_industry_id,
    js1.skill_id,
    COUNT(*) AS overlap_count
FROM job_industries ji1
INNER JOIN job_industries ji2 ON ji1.job_id = ji2.job_id
INNER JOIN job_skills_normalized js1 ON ji1.job_id = js1.job_id
INNER JOIN job_skills_normalized js2 ON ji2.job_id = js2.job_id AND js1.skill_id = js2.skill_id
WHERE ji1.industry_id != ji2.industry_id
GROUP BY
    source_industry_id,
    target_industry_id,
    skill_id
HAVING
    overlap_count >= 3;
    
SELECT
    i1.industry_name AS source_industry,
    i2.industry_name AS target_industry,
    s.skill_name,
    tso.overlap_count AS skill_overlap_count,
    ROUND(tso.overlap_count * 100.0 / tisc.total_skills, 2) AS transferability_score,
    RANK() OVER (PARTITION BY i1.industry_id ORDER BY tso.overlap_count DESC) AS skill_rank
FROM temp_skill_overlaps tso
INNER JOIN industries i1 ON tso.source_industry_id = i1.industry_id
INNER JOIN industries i2 ON tso.target_industry_id = i2.industry_id
INNER JOIN skills s ON tso.skill_id = s.skill_id
INNER JOIN temp_industry_skill_counts tisc ON tso.source_industry_id = tisc.industry_id
ORDER BY source_industry, skill_rank
LIMIT 20;

-- Query 8: Company Specialization vs Hiring Success Correlation
-- Step 1: Create temp table for company job stats
CREATE TEMPORARY TABLE temp_company_stats AS
SELECT 
    c.company_id,
    COUNT(j.job_id) as total_jobs,
    COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) as filled_jobs,
    AVG(j.applications_count) as avg_applications
FROM companies c
INNER JOIN jobs j ON c.company_id = j.company_id
WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY c.company_id;

-- Step 2: Main query with pre-aggregated data
SELECT 
    sp.specialty_name,
    sp.specialty_category,
    COUNT(DISTINCT cs.company_id) as companies_with_specialty,
    SUM(tcs.total_jobs) as total_jobs_posted,
    SUM(tcs.filled_jobs) as jobs_filled,
    ROUND(SUM(tcs.filled_jobs) * 100.0 / NULLIF(SUM(tcs.total_jobs), 0), 2) as fill_rate_pct,
    AVG(tcs.avg_applications) as avg_applications_per_job
FROM specialties sp
INNER JOIN company_specialties_normalized cs ON sp.specialty_id = cs.specialty_id
INNER JOIN temp_company_stats tcs ON cs.company_id = tcs.company_id
GROUP BY sp.specialty_id
HAVING companies_with_specialty >= 2 AND total_jobs_posted >= 5
ORDER BY fill_rate_pct DESC;

-- Query 9: Temporal Job Posting Patterns with Seasonality Analysis
-- Direct aggregation without subqueries
SELECT 
    YEAR(posted_date) as year,
    MONTH(posted_date) as month,
    MONTHNAME(posted_date) as month_name,
    COUNT(job_id) as jobs_posted,
    AVG(applications_count) as avg_applications,
    COUNT(CASE WHEN filled_date IS NOT NULL THEN 1 END) as jobs_filled,
    ROUND(COUNT(CASE WHEN filled_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(job_id), 2) as fill_rate_pct
FROM jobs
WHERE posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY YEAR(posted_date), MONTH(posted_date)
ORDER BY year DESC, month DESC;

-- Query 10: Skill Combination Effectiveness Analysis
-- Step 1: Create skill profile temp table
CREATE TEMPORARY TABLE temp_skill_profiles AS
SELECT 
    j.job_id,
    COUNT(s.skill_id) as skill_count,
    MAX(CASE WHEN s.skill_category = 'Technical' THEN 1 ELSE 0 END) as has_technical,
    MAX(CASE WHEN s.skill_category = 'Management' THEN 1 ELSE 0 END) as has_management,
    MAX(CASE WHEN s.skill_category = 'Sales & Marketing' THEN 1 ELSE 0 END) as has_marketing
FROM jobs j
INNER JOIN job_skills_normalized js ON j.job_id = js.job_id
INNER JOIN skills s ON js.skill_id = s.skill_id
GROUP BY j.job_id;

-- Step 2: Analyze profiles
SELECT 
    CASE 
        WHEN tsp.has_technical AND tsp.has_management THEN 'Tech Leadership'
        WHEN tsp.has_technical THEN 'Technical Only'
        WHEN tsp.has_management THEN 'Management Only'
        ELSE 'Other'
    END as skill_profile,
    AVG(tsp.skill_count) as avg_skill_count,
    COUNT(j.job_id) as jobs_with_profile,
    AVG(j.applications_count) as avg_applications,
    ROUND(COUNT(CASE WHEN j.filled_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(j.job_id), 2) as fill_rate_pct
FROM temp_skill_profiles tsp
INNER JOIN jobs j ON tsp.job_id = j.job_id
GROUP BY skill_profile
HAVING jobs_with_profile >= 10
ORDER BY fill_rate_pct DESC;