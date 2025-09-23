import pymysql
from sqlalchemy import create_engine
import pandas as pd

# AWS RDS Connection Configuration
RDS_HOSTNAME = ''
RDS_PORT = #enter your port
RDS_DB_NAME = 'linkedin_analysis'
RDS_USERNAME = ''
RDS_PASSWORD = ''

def test_aws_connection():
    try:
        engine = create_engine(
            f'mysql+pymysql://{RDS_USERNAME}:{RDS_PASSWORD}@{RDS_HOSTNAME}:{RDS_PORT}/{RDS_DB_NAME}'
        )
        
        # Test basic connection
        with engine.connect() as conn:
            result = conn.execute("SELECT COUNT(*) as job_count FROM jobs")
            job_count = result.fetchone()[0]
            print(f"Connected to AWS RDS! Found {job_count} jobs.")
            
        # Test cohort analysis
        query = "SELECT cohort_name, COUNT(*) as members FROM cohorts c JOIN cohort_memberships cm ON c.cohort_id = cm.cohort_id GROUP BY c.cohort_id"
        df = pd.read_sql(query, engine)
        print("Cohort Analysis Results:")
        print(df)
        
        return True
        
    except Exception as e:
        print(f"Connection failed: {e}")
        return False

if __name__ == "__main__":
    test_aws_connection()
