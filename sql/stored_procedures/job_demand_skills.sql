-- Predict Job Demand by Skills

DELIMITER $$

CREATE PROCEDURE PredictSkillDemand(IN prediction_months INT)
BEGIN
    -- Simple linear trend prediction based on historical data
    SELECT 
        s.skill_name,
        s.skill_category,
        -- Historical average
        AVG(monthly_counts.job_count) as historical_avg_monthly,
        -- Linear trend calculation
        (SUM(monthly_counts.job_count * monthly_counts.month_rank) - 
         COUNT(*) * AVG(monthly_counts.job_count) * AVG(monthly_counts.month_rank)) / 
        (SUM(monthly_counts.month_rank * monthly_counts.month_rank) - 
         COUNT(*) * AVG(monthly_counts.month_rank) * AVG(monthly_counts.month_rank)) as trend_slope,
        -- Predicted demand
        ROUND(AVG(monthly_counts.job_count) + 
              (SUM(monthly_counts.job_count * monthly_counts.month_rank) - 
               COUNT(*) * AVG(monthly_counts.job_count) * AVG(monthly_counts.month_rank)) / 
              (SUM(monthly_counts.month_rank * monthly_counts.month_rank) - 
               COUNT(*) * AVG(monthly_counts.month_rank) * AVG(monthly_counts.month_rank)) * 
              prediction_months, 0) as predicted_monthly_demand
    FROM (
        SELECT 
            s.skill_id,
            YEAR(j.posted_date) * 12 + MONTH(j.posted_date) as month_rank,
            COUNT(j.job_id) as job_count
        FROM skills s
        INNER JOIN job_skills js ON s.skill_id = js.skill_id  
        INNER JOIN jobs j ON js.job_id = j.job_id
        WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
        GROUP BY s.skill_id, YEAR(j.posted_date), MONTH(j.posted_date)
    ) monthly_counts
    INNER JOIN skills s ON monthly_counts.skill_id = s.skill_id
    GROUP BY s.skill_id, s.skill_name, s.skill_category
    HAVING COUNT(*) >= 6 -- At least 6 months of data
    ORDER BY predicted_monthly_demand DESC;
END$$

DELIMITER ;
