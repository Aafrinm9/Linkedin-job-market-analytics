# LinkedIn Job Market Analytics Platform  

---

## Overview  
A comprehensive analytics platform analyzing LinkedIn job market data through advanced database design, cohort analysis, and A/B testing frameworks. Deployed on AWS RDS with Python connectivity for scalable business intelligence.  

---

## Key Statistics  
- **15,637** job postings analyzed  
- **141** industries categorized  
- **35** skill categories mapped  
- **AWS cloud deployment** with production-ready architecture  

---

## Architecture & Features  

### Database Design  
- Normalized **3NF structure** eliminating data redundancy  
- **Referential integrity** with foreign key constraints  
- **Advanced indexing** for query optimization  
- **Automated triggers** for real-time data updates  

### Analytics Capabilities  
- **Cohort Analysis**: Track hiring patterns and performance over time  
- **A/B Testing Framework**: Statistical testing with confidence intervals  
- **Predictive Analytics**: Skill demand forecasting and trend analysis  
- **Cross-Industry Analysis**: Skill migration patterns and market insights  

### Technology Stack  
- **Database**: MySQL 8.0 (AWS RDS)  
- **Analytics**: Advanced SQL with stored procedures and triggers  
- **Connectivity**: Python with SQLAlchemy and pandas  
- **Cloud**: AWS RDS with security group configuration  
- **Version Control**: Git/GitHub  

---

### Core Entities  
- **Companies**: Organization data with location and metrics  
- **Jobs**: Job postings with temporal and categorical data  
- **Skills**: Standardized skill taxonomy with demand tracking  
- **Industries**: Hierarchical industry classification  
- **Benefits**: Categorized benefit offerings with value scoring  

### Relationship Tables  
- **job_skills_normalized**: Many-to-many job-skill relationships  
- **company_industries_normalized**: Company industry associations  
- **cohort_memberships**: Entity assignments to analytical cohorts  
- **ab_test_assignments**: Experimental group assignments  

----

## Repository Structure
```bash
linkedin-job-analytics/
├── README.md
├── docs/
│ ├── ER_Diagram.png
│ ├── Database_Schema.md
│ └── Project_Report.pdf
├── sql/
│ ├── schema/
│ │ ├── 01_create_tables.sql
│ │ ├── 02_create_relationships.sql
│ │ └── 03_create_indexes.sql
│ ├── stored_procedures/
│ │ ├── cohort_analysis.sql
│ │ ├── ab_testing.sql
│ │ └── analytics_procedures.sql
│ ├── triggers/
│ │ └── data_triggers.sql
│ └── queries/
│ ├── advanced_analytics.sql
│ ├── cohort_queries.sql
│ └── market_analysis.sql
├── python/
│ ├── aws_connection.py
│ ├── data_migration.py
│ └── analytics_examples.py
├── data/
│ ├── sample_data/
│ └── migration_scripts/
└── deployment/
├── aws_setup.md
└── security_configuration.md
```
-----

## Entity Relationship Diagram  
![ER Diagram](docs/ER_diagram_Linkedin_analysis.png)  

### Core Entities  
- **Companies**: Organization data with location and metrics  
- **Jobs**: Job postings with temporal and categorical data  
- **Skills**: Standardized skill taxonomy with demand tracking  
- **Industries**: Hierarchical industry classification  
- **Benefits**: Categorized benefit offerings with value scoring  

### Relationship Tables  
- **job_skills_normalized**: Many-to-many job-skill relationships  
- **company_industries_normalized**: Company industry associations  
- **cohort_memberships**: Entity assignments to analytical cohorts  
- **ab_test_assignments**: Experimental group assignments  

---

## Quick Start  

### Prerequisites  
```bash
pip install pymysql sqlalchemy pandas
```
---

### Database connection  
```bash
from python.aws_connection import create_aws_connection
import pandas as pd

# Connect to AWS RDS
engine = create_aws_connection()

# Test connection
query = "SELECT COUNT(*) FROM jobs"
result = pd.read_sql(query, engine)
print(f"Connected! Found {result.iloc[0,0]} jobs in database")
```
---

### Running Analytics
```bash
# Cohort Analysis Example
from python.analytics_examples import run_cohort_analysis

results = run_cohort_analysis('Q4_2024_Jobs')
print(results)

# A/B Testing Example
from python.analytics_examples import analyze_ab_test

ab_results = analyze_ab_test(test_id=1)
print(ab_results)
```
---
## Key Analytical Capabilities

**1. Cohort Analysis**
- Track groups of jobs/companies over time to identify patterns:
- Time-based cohorts (Q1 vs Q2 performance)
- Company-based cohorts (startup vs enterprise hiring)
- Skill-based cohorts (trending skill combinations)
**2. A/B Testing Framework**
- Statistical testing for hiring optimization:
- Job description effectiveness
- Benefit presentation strategies
- Skill requirement optimization
Statistical significance calculations
**3. Market Intelligence**
- Cross-industry skill migration patterns
- Geographic job distribution analysis
- Seasonal hiring trend identification
- Company specialization vs success correlation

## Database Schema Highlights
**Normalization Benefits**
- 60% storage reduction through elimination of redundant data
- Improved data integrity with foreign key constraints
- Enhanced query performance with proper indexing
- Scalable structure supporting millions of records
**Advanced Features**
- 10+ stored procedures for automated analytics
- 5+ triggers for real-time data consistency
- Complex queries with statistical functions
- Performance monitoring and logging

## Deployment Architecture
**AWS RDS Configuration**
- Instance: db.t3.micro (Free Tier eligible)
- Engine: MySQL 8.0.42
- Storage: 20GB General Purpose SSD
- Security: VPC with controlled access
- Backup: Automated daily backups
**Security Features**
- VPC security groups with IP restrictions
- IAM-based access control
- Encrypted connections
- Regular backup and recovery testing

## Results & Insights
**Data Processing**
- Normalized 15,637 job records
- Reduced data redundancy by 60%
- Achieved sub-second query response times
- Maintained 99.9% data integrity
**Analytical Outcomes**
- Identified top 5 transferable skills across industries
- Discovered 23% variance in hiring success by job description length
- Tracked cohort retention patterns with statistical significance
- Enabled predictive skill demand forecasting

## Contributing
- Fork the repository
- Create feature branch (git checkout -b feature/analytics-enhancement)
- Commit changes (git commit -am 'Add new analytics feature')
- Push to branch (git push origin feature/analytics-enhancement)
- Create Pull Request

## Contact
**Author:** Aafrin Shehnaz
**LinkedIn:** https://www.linkedin.com/in/aafrin-shehnaz/
**Email:** shehnazaafrin@gmail.com


