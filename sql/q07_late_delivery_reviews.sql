-- Q7. How much does a late delivery hurt the customer's review?
-- Orders are grouped by how many days they arrived before or after the promised date.
WITH bucketed AS (
    SELECT
        CASE
            WHEN days_vs_estimate <= -7 THEN '1. 7+ days early'
            WHEN days_vs_estimate <=  0 THEN '2. 0-6 days early'
            WHEN days_vs_estimate <=  3 THEN '3. 1-3 days late'
            WHEN days_vs_estimate <=  7 THEN '4. 4-7 days late'
            ELSE                             '5. 8+ days late'
        END AS delivery_vs_promise,
        review_score
    FROM delivered_orders
    WHERE review_score IS NOT NULL
)
SELECT
    delivery_vs_promise,
    COUNT(*)                                                           AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)                 AS pct_of_orders,
    ROUND(AVG(review_score), 2)                                        AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_1_or_2_stars,
    ROUND(100.0 * AVG(CASE WHEN review_score = 5 THEN 1 ELSE 0 END), 1)  AS pct_5_stars
FROM bucketed
GROUP BY delivery_vs_promise
ORDER BY delivery_vs_promise;
