-- STEP 4: CREATE RELATIONSHIP TABLES
-- ============================================================================
-- 4.1 Job-Skills Relationship (normalized)
-- --Before (Denormalized):
-- sqljob_skills table:[job_id, skill_abr] (mixed entity and relationship data)
-- After (Normalized):
-- sqlskills table (entity):[skill_id, skill_abr, skill_name, skill_category]
-- job_skills_normalized table (relationship):[job_id, skill_id, is_required, proficiency_level]
CREATE TABLE job_skills_normalized (
    job_id BIGINT,
    skill_id INT,
    is_required BOOLEAN DEFAULT TRUE,
    proficiency_level ENUM('Basic', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Intermediate',
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);
-- Populate from existing job_skills
INSERT INTO job_skills_normalized (job_id, skill_id, is_required)
SELECT 
    js.job_id,
    s.skill_id,
    TRUE as is_required
FROM job_skills js
INNER JOIN skills s ON s.skill_abr = js.skill_abr
WHERE js.job_id IS NOT NULL;

-- 4.2 Job-Benefits Relationship (normalized)
-- Before (Denormalized):
-- sqlbenefits table:[job_id, type](composite string with embedded data)
-- After (Normalized):
-- sqlbenefit_types table (entity):[benefit_id, benefit_name, benefit_category, benefit_value_score]
-- job_benefits_normalized table (relationship):[job_id, benefit_id, is_highlighted, display_order]
CREATE TABLE job_benefits_normalized (
    job_id BIGINT,
    benefit_id INT,
    is_highlighted BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    PRIMARY KEY (job_id, benefit_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (benefit_id) REFERENCES benefit_types(benefit_id) ON DELETE CASCADE
);

-- Populate from your existing benefits
INSERT IGNORE INTO job_benefits_normalized (job_id, benefit_id, is_highlighted)
SELECT 
    CAST(SUBSTRING_INDEX(b.job_id, '-', 1) AS UNSIGNED) as job_id,
    bt.benefit_id,
    TRUE as is_highlighted
FROM benefits b
INNER JOIN benefit_types bt ON bt.benefit_name = TRIM(SUBSTRING_INDEX(b.type, '-', -1))
WHERE b.job_id IS NOT NULL;

-- 4.3 Company-Industry Relationship (normalized)
-- Before (Denormalized):
-- sqlcompanies_industries table:[company_id, industry] (text field, no standardization)
-- After (Normalized):
-- sqlindustries table (entity):[industry_id, industry_name, industry_category]
-- company_industries_normalized table (relationship):[company_id, industry_id, is_primary]
CREATE TABLE company_industries_normalized (
    company_id BIGINT,
    industry_id INT,
    is_primary BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (company_id, industry_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    FOREIGN KEY (industry_id) REFERENCES industries(industry_id) ON DELETE CASCADE
);

-- Populate from your existing companies_industries
INSERT IGNORE INTO company_industries_normalized (company_id, industry_id, is_primary)
SELECT 
    ci.company_id,
    i.industry_id,
    TRUE as is_primary
FROM company_industries ci
INNER JOIN industries i ON i.industry_name = TRIM(ci.industry)
WHERE ci.company_id IS NOT NULL;

-- 4.4 Company-Specialties Relationship (normalized)
-- Before (Denormalized):
-- sqlcompanies_specialities table:[company_id, speciality ](text field with inconsistencies)
-- After (Normalized):
-- sqlspecialties table (entity):[ specialty_id, specialty_name, specialty_category]
-- company_specialties_normalized table (relationship):[company_id, specialty_id, expertise_level]
CREATE TABLE company_specialties_normalized (
    company_id BIGINT,
    specialty_id INT,
    expertise_level ENUM('Basic', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Advanced',
    PRIMARY KEY (company_id, specialty_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) ON DELETE CASCADE
);

-- Populate from your existing companies_specialities
INSERT IGNORE INTO company_specialties_normalized (company_id, specialty_id, expertise_level)
SELECT 
    cs.company_id,
    s.specialty_id,
    'Advanced' as expertise_level
FROM company_specialities cs
INNER JOIN specialties s ON s.specialty_name = TRIM(cs.speciality)
WHERE cs.company_id IS NOT NULL;