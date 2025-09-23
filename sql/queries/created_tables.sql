-- STEP 2: CREATE ENHANCED MAIN TABLES
-- ============================================================================

-- 2.1 Enhanced Jobs Table (inferred from job_id patterns)
CREATE TABLE jobs (
    job_id BIGINT PRIMARY KEY,
    company_id BIGINT,
    job_title VARCHAR(500),
    job_description TEXT,
    employment_type ENUM('Full-time', 'Part-time', 'Contract', 'Internship', 'Temporary') DEFAULT 'Full-time',
    experience_level ENUM('Entry', 'Mid', 'Senior', 'Executive') DEFAULT 'Mid',
    location VARCHAR(255),
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    posted_date DATE,
    expires_date DATE,
    filled_date DATE,
    applications_count INT DEFAULT 0,
    views_count INT DEFAULT 0,
    is_remote BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    INDEX idx_posted_date (posted_date),
    INDEX idx_company_location (company_id, location),
    INDEX idx_job_status (is_active, posted_date)
);

-- 2.2 Enhanced Company Metrics Table (from your employee_counts)
CREATE TABLE company_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT,
    employee_count INT DEFAULT 0,
    follower_count INT DEFAULT 0,
    time_recorded DATETIME,
    metric_date DATE,
    year_mon VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    INDEX idx_company_time (company_id, time_recorded),
    INDEX idx_metric_date (metric_date),
    INDEX idx_year_month (year_mon)
);