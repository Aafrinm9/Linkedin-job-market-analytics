-- PART 4: ADVANCED ANALYTICS STORED PROCEDURES  
-- ============================================================================

-- 4.1 Skill Demand Trend Analysis
DELIMITER $$
CREATE PROCEDURE AnalyzeSkillTrends(IN months_back INT)
BEGIN
    SELECT 
        s.skill_name,
        s.skill_category,
        COUNT(js.job_id) as job_count,
        COUNT(DISTINCT j.company_id) as company_count,
        ROUND(COUNT(js.job_id) * 100.0 / (
            SELECT COUNT(*) FROM jobs 
            WHERE posted_date >= DATE_SUB(NOW(), INTERVAL months_back MONTH)
        ), 2) as market_penetration_pct,
        -- Calculate trend (comparing first half vs second half of period)
        COUNT(CASE WHEN j.posted_date >= DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END) as recent_count,
        COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END) as earlier_count,
        CASE 
            WHEN COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END) > 0 THEN
                ROUND((COUNT(CASE WHEN j.posted_date >= DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END) - 
                       COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END)) * 100.0 /
                       COUNT(CASE WHEN j.posted_date < DATE_SUB(NOW(), INTERVAL months_back/2 MONTH) THEN 1 END), 2)
            ELSE 100.0
        END as trend_percentage
    FROM skills s
    INNER JOIN job_skills js ON s.skill_id = js.skill_id
    INNER JOIN jobs j ON js.job_id = j.job_id
    WHERE j.posted_date >= DATE_SUB(NOW(), INTERVAL months_back MONTH)
    GROUP BY s.skill_id, s.skill_name, s.skill_category
    HAVING job_count >= 5
    ORDER BY job_count DESC, trend_percentage DESC;
END$$

DELIMITER ;
