-- STEP 6: BASIC DATA QUALITY CHECKS
-- ============================================================================
-- Check for data quality issues
SELECT 'Data Quality Report:' as report;

-- Missing company associations
SELECT COUNT(*) as jobs_without_companies
FROM jobs j 
LEFT JOIN companies c ON j.company_id = c.company_id
WHERE c.company_id IS NULL;

-- Jobs without skills
SELECT COUNT(*) as jobs_without_skills
FROM jobs j
LEFT JOIN job_skills_normalized jsn ON j.job_id = jsn.job_id
WHERE jsn.job_id IS NULL;

-- Companies without industries
SELECT COUNT(*) as companies_without_industries
FROM companies c
LEFT JOIN company_industries_normalized cin ON c.company_id = cin.company_id  
WHERE cin.company_id IS NULL;  -- getting output 110 which means 110 companies are missing industries hence fixing it. 

-- First, see which companies are missing industry associations
SELECT c.company_id, c.name 
FROM companies c
LEFT JOIN company_industries_normalized cin ON c.company_id = cin.company_id  
WHERE cin.company_id IS NULL
LIMIT 10;

-- Check if these companies exist in our source companies_industries table
SELECT DISTINCT company_id 
FROM companies_industries 
WHERE company_id IN (
    SELECT c.company_id 
    FROM companies c
    LEFT JOIN company_industries_normalized cin ON c.company_id = cin.company_id  
    WHERE cin.company_id IS NULL
    LIMIT 10
);

INSERT INTO company_industries_normalized (company_id, industry_id, is_primary)
SELECT 
    mc.company_id,
    (SELECT industry_id FROM industries WHERE industry_category = 'Other' LIMIT 1) as industry_id,
    TRUE as is_primary
FROM missing_companies mc;

INSERT INTO company_industries_normalized (company_id, industry_id, is_primary)
SELECT 
    c.company_id,
    2 as industry_id,  -- Using the industry_id you found (2)
    TRUE as is_primary
FROM companies c
LEFT JOIN company_industries_normalized cin ON c.company_id = cin.company_id  
WHERE cin.company_id IS NULL;

SELECT COUNT(*) as companies_without_industries
FROM companies c
LEFT JOIN company_industries_normalized cin ON c.company_id = cin.company_id  
WHERE cin.company_id IS NULL;

-- Show the structure we've created
SHOW TABLES LIKE '%normalized';
SHOW TABLES LIKE 'industries';
SHOW TABLES LIKE 'skills';
SHOW TABLES LIKE 'benefit_types';
SHOW TABLES LIKE 'specialties';