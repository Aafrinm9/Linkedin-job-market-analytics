-- STEP 1: CREATE LOOKUP TABLES FROM EXISTING DATA (for quicker access)
-- ============================================================================

-- 1.1 Create Industries Lookup Table
CREATE TABLE industries (
    industry_id INT AUTO_INCREMENT PRIMARY KEY,
    industry_name VARCHAR(255) NOT NULL UNIQUE,
    industry_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Populate from existing companies_industries table
INSERT INTO industries (industry_name, industry_category)
SELECT DISTINCT 
    TRIM(industry) as industry_name,
    CASE 
        WHEN LOWER(industry) LIKE '%tech%' OR LOWER(industry) LIKE '%software%' OR LOWER(industry) LIKE '%information%' THEN 'Technology'
        WHEN LOWER(industry) LIKE '%health%' OR LOWER(industry) LIKE '%medical%' OR LOWER(industry) LIKE '%pharma%' THEN 'Healthcare'
        WHEN LOWER(industry) LIKE '%financ%' OR LOWER(industry) LIKE '%bank%' OR LOWER(industry) LIKE '%accounting%' THEN 'Finance'
        WHEN LOWER(industry) LIKE '%educat%' THEN 'Education'
        WHEN LOWER(industry) LIKE '%manufactur%' OR LOWER(industry) LIKE '%electric%' OR LOWER(industry) LIKE '%machinery%' OR LOWER(industry) LIKE '%automo%' OR LOWER(industry) LIKE '%energy%' THEN 'Manufacturing'
        WHEN LOWER(industry) LIKE '%market%' OR LOWER(industry) LIKE '%advertis%' THEN 'Marketing'
        WHEN LOWER(industry) LIKE '%retail%' OR LOWER(industry) LIKE '%consumer%' THEN 'Retail'
        WHEN LOWER(industry) LIKE '%logistics%' or LOWER(industry) LIKE '%supply%' THEN 'Supply Chain'
        WHEN LOWER(industry) LIKE '%civil%' OR LOWER(industry) LIKE '%building%' OR LOWER(industry) LIKE '%architecture%' THEN 'Construction'
        WHEN LOWER(industry) LIKE '%consulting%' THEN 'Consulting'
        ELSE 'Other'
    END as industry_category
FROM company_industries 
WHERE industry IS NOT NULL AND TRIM(industry) != ''
ORDER BY industry_name;

-- 1.2 Create Skills Lookup Table
CREATE TABLE skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_abr VARCHAR(20) UNIQUE NOT NULL,
    skill_name VARCHAR(255),
    skill_category ENUM('Finance', 'Management', 'Technical', 'Healthcare', 'Sales & Marketing', 'Creative', 'Education', 'Administrative', 'Research', 'General Business', 'Other') DEFAULT 'Other',
    skill_level ENUM('Entry', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Intermediate',
    demand_score INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Populate from job_skills table
INSERT INTO skills (skill_abr, skill_name, skill_category)
SELECT DISTINCT 
    skill_abr,
    CASE 
        WHEN skill_abr = 'ACCT' THEN 'Accounting'
        WHEN skill_abr = 'FIN' THEN 'Finance'
        WHEN skill_abr = 'MGMT' THEN 'Management'
        WHEN skill_abr = 'PRJM' THEN 'Project Management'
        WHEN skill_abr = 'STRA' THEN 'Strategy'
        WHEN skill_abr = 'BD' THEN 'Business Development'
        WHEN skill_abr = 'IT' THEN 'Information Technology'
        WHEN skill_abr = 'ENG' THEN 'Engineering'
        WHEN skill_abr = 'MNFC' THEN 'Manufacturing'
        WHEN skill_abr = 'QA' THEN 'Quality Assurance'
        WHEN skill_abr = 'PROD' THEN 'Production'
        WHEN skill_abr = 'SCI' THEN 'Science'
        WHEN skill_abr = 'ANLS' THEN 'Analytics'
        WHEN skill_abr = 'HCPR' THEN 'Healthcare Provider'
        WHEN skill_abr = 'SALE' THEN 'Sales'
        WHEN skill_abr = 'MRKT' THEN 'Marketing'
        WHEN skill_abr = 'CUST' THEN 'Customer Service'
        WHEN skill_abr = 'ADVR' THEN 'Advertising'
        WHEN skill_abr = 'PR' THEN 'Public Relations'
        WHEN skill_abr = 'PRCH' THEN 'Purchasing'
        WHEN skill_abr = 'DIST' THEN 'Distribution'
        WHEN skill_abr = 'DSGN' THEN 'Design'
        WHEN skill_abr = 'ART' THEN 'Art & Creative'
        WHEN skill_abr = 'WRT' THEN 'Writing'
        WHEN skill_abr = 'EDU' THEN 'Education'
        WHEN skill_abr = 'TRNG' THEN 'Training'
        WHEN skill_abr = 'ADM' THEN 'Administration'
        WHEN skill_abr = 'HR' THEN 'Human Resources'
        WHEN skill_abr = 'LGL' THEN 'Legal'
        WHEN skill_abr = 'SUPL' THEN 'Supply Chain'
        WHEN skill_abr = 'CNSL' THEN 'Consulting'
        WHEN skill_abr = 'RSCH' THEN 'Research'
        WHEN skill_abr = 'GENB' THEN 'General Business'
        WHEN skill_abr = 'OTHR' THEN 'Other Skills'
        WHEN skill_abr = 'PRDM' THEN 'Product Management'
        ELSE CONCAT(UPPER(LEFT(skill_abr, 1)), LOWER(SUBSTRING(skill_abr, 2)))
    END as skill_name,
    CASE 
        WHEN skill_abr IN ('ACCT', 'FIN') THEN 'Finance'
        WHEN skill_abr IN ('MGMT', 'PRJM', 'STRA', 'BD', 'CNSL') THEN 'Management'
        WHEN skill_abr IN ('IT', 'ENG', 'MNFC', 'QA', 'PROD', 'SCI', 'ANLS') THEN 'Technical'
        WHEN skill_abr IN ('HCPR') THEN 'Healthcare'
        WHEN skill_abr IN ('SALE', 'MRKT', 'CUST', 'ADVR', 'PR', 'PRCH', 'DIST') THEN 'Sales & Marketing'
        WHEN skill_abr IN ('DSGN', 'ART', 'WRT') THEN 'Creative'
        WHEN skill_abr IN ('EDU', 'TRNG') THEN 'Education'
        WHEN skill_abr IN ('ADM', 'HR', 'LGL', 'SUPL') THEN 'Administrative'
        WHEN skill_abr IN ('RSCH') THEN 'Research'
        WHEN skill_abr IN ('GENB', 'OTHR', 'PRDM') THEN 'General Business'
        ELSE 'Other'
    END as skill_category
FROM job_skills 
WHERE skill_abr IS NOT NULL AND skill_abr != '';

-- 1.3 Create Benefits Lookup Table
CREATE TABLE benefit_types (
    benefit_id INT AUTO_INCREMENT PRIMARY KEY,
    benefit_name VARCHAR(255) NOT NULL UNIQUE,
    benefit_category ENUM('Health', 'Financial', 'Time Off', 'Development', 'Wellness', 'Other') DEFAULT 'Other',
    benefit_value_score INT DEFAULT 1,
    popularity_rank INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Populate from benefits table 
INSERT INTO benefit_types (benefit_name, benefit_category, benefit_value_score)
SELECT DISTINCT 
    TRIM(SUBSTRING_INDEX(type, '-', -1)) as benefit_name,
    CASE 
        WHEN LOWER(type) LIKE '%medical%' OR LOWER(type) LIKE '%health%' THEN 'Health'
        WHEN LOWER(type) LIKE '%dental%' THEN 'Health'
        WHEN LOWER(type) LIKE '%vision%' THEN 'Health'
        WHEN LOWER(type) LIKE '%401%' OR LOWER(type) LIKE '%retirement%' THEN 'Financial'
        WHEN LOWER(type) LIKE '%leave%' OR LOWER(type) LIKE '%vacation%' OR LOWER(type) LIKE '%pto%' THEN 'Time Off'
        WHEN LOWER(type) LIKE '%disability%' OR LOWER(type) LIKE '%insurance%' THEN 'Health'
        WHEN LOWER(type) LIKE '%training%' OR LOWER(type) LIKE '%education%' THEN 'Development'
        ELSE 'Other'
    END as benefit_category,
    CASE 
        WHEN LOWER(type) LIKE '%medical%' THEN 9
        WHEN LOWER(type) LIKE '%401%' THEN 8
        WHEN LOWER(type) LIKE '%dental%' THEN 7
        WHEN LOWER(type) LIKE '%vision%' THEN 6
        WHEN LOWER(type) LIKE '%leave%' THEN 7
        WHEN LOWER(type) LIKE '%disability%' THEN 5
        ELSE 5
    END as benefit_value_score
FROM benefits 
WHERE type IS NOT NULL AND TRIM(type) != ''
ORDER BY benefit_name;
-- 1.4 Create Specialties Lookup Table  
CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(500) NOT NULL UNIQUE,
    specialty_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Populate from companies_specialities table
INSERT INTO specialties (specialty_name, specialty_category)
SELECT DISTINCT 
    TRIM(speciality) as specialty_name,
    CASE 
        WHEN LOWER(speciality) LIKE '%music%' OR LOWER(speciality) LIKE '%art%' THEN 'Arts & Culture'
        WHEN LOWER(speciality) LIKE '%education%' OR LOWER(speciality) LIKE '%learning%' THEN 'Education'
        WHEN LOWER(speciality) LIKE '%child%' OR LOWER(speciality) LIKE '%social%' THEN 'Social Services'
        WHEN LOWER(speciality) LIKE '%tech%' OR LOWER(speciality) LIKE '%software%' THEN 'Technology'
        WHEN LOWER(speciality) LIKE '%health%' OR LOWER(speciality) LIKE '%medical%' THEN 'Healthcare'
        ELSE 'Other'
    END as specialty_category
FROM company_specialities 
WHERE speciality IS NOT NULL AND TRIM(speciality) != '';
