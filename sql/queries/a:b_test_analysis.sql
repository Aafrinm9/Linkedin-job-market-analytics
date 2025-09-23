-- 3.3 Analyze A/B Test Results
DELIMITER $$

CREATE PROCEDURE AnalyzeABTestResults(IN test_id INT)
BEGIN
    SELECT 
        atg.group_name,
        atg.group_type,
        COUNT(ata.entity_id) as sample_size,
        AVG(atr.metric_value) as avg_metric_value,
        STDDEV(atr.metric_value) as std_deviation,
        MIN(atr.metric_value) as min_value,
        MAX(atr.metric_value) as max_value,
        -- Calculate confidence interval (approximate)
        AVG(atr.metric_value) - (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_lower,
        AVG(atr.metric_value) + (1.96 * STDDEV(atr.metric_value) / SQRT(COUNT(ata.entity_id))) as ci_upper
    FROM ab_test_groups atg
    LEFT JOIN ab_test_assignments ata ON atg.group_id = ata.group_id
    LEFT JOIN ab_test_results atr ON atg.group_id = atr.group_id
    WHERE atg.test_id = test_id
    GROUP BY atg.group_id, atg.group_name, atg.group_type
    ORDER BY atg.group_type;
END$$

DELIMITER ;