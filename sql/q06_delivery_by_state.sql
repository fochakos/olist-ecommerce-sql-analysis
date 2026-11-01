-- Q6. How fast and how reliable is delivery in each state?
-- States with fewer than 100 delivered orders are left out.
SELECT
    customer_state,
    COUNT(*)                                                         AS delivered_orders,
    ROUND(AVG(delivery_days), 1)                                     AS avg_delivery_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_days)       AS median_delivery_days,
    ROUND(100.0 * AVG(is_late), 1)                                   AS late_pct,
    ROUND(AVG(review_score), 2)                                      AS avg_review_score
FROM delivered_orders
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;
