-- STEP 5: VERIFY YOUR DATA MIGRATION
-- ============================================================================
-- Check the results of your migration
SELECT 'Industries' as table_name, COUNT(*) as records FROM industries
UNION ALL
SELECT 'Skills' as table_name, COUNT(*) as records FROM skills  
UNION ALL
SELECT 'Benefit Types' as table_name, COUNT(*) as records FROM benefit_types
UNION ALL
SELECT 'Specialties' as table_name, COUNT(*) as records FROM specialties
UNION ALL
SELECT 'Jobs' as table_name, COUNT(*) as records FROM jobs
UNION ALL
SELECT 'Company Metrics' as table_name, COUNT(*) as records FROM company_metrics
UNION ALL
SELECT 'Job Skills (Normalized)' as table_name, COUNT(*) as records FROM job_skills_normalized
UNION ALL
SELECT 'Job Benefits (Normalized)' as table_name, COUNT(*) as records FROM job_benefits_normalized
UNION ALL
SELECT 'Company Industries (Normalized)' as table_name, COUNT(*) as records FROM company_industries_normalized
UNION ALL
SELECT 'Company Specialties (Normalized)' as table_name, COUNT(*) as records FROM company_specialties_normalized;

-- Sample the normalized data to verify
SELECT 'Top 5 Industries:' as info;
SELECT industry_name, industry_category FROM industries LIMIT 5;

SELECT 'Top 5 Skills:' as info;
SELECT skill_abr, skill_name, skill_category FROM skills LIMIT 5;

SELECT 'Sample Job with Skills:' as info;
SELECT j.job_id, j.company_id, GROUP_CONCAT(s.skill_name) as skills
FROM jobs j
INNER JOIN job_skills_normalized jsn ON j.job_id = jsn.job_id
INNER JOIN skills s ON jsn.skill_id = s.skill_id
GROUP BY j.job_id
LIMIT 3;