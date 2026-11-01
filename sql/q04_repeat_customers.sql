-- Q4. How many customers come back, and how much revenue do repeat customers bring?
WITH per_customer AS (
    SELECT
        customer_unique_id,
        COUNT(*)          AS orders,
        SUM(item_revenue) AS spend
    FROM delivered_orders
    GROUP BY customer_unique_id
)
SELECT
    CASE
        WHEN orders = 1 THEN '1 order'
        WHEN orders = 2 THEN '2 orders'
        ELSE '3+ orders'
    END                                                        AS customer_segment,
    COUNT(*)                                                   AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)         AS pct_of_customers,
    ROUND(SUM(spend), 2)                                       AS revenue,
    ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 2)     AS pct_of_revenue,
    ROUND(AVG(spend), 2)                                       AS avg_lifetime_spend
FROM per_customer
GROUP BY 1
ORDER BY 1;
