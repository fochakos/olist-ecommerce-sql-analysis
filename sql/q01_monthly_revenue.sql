-- Q1. How did revenue, order volume and average order value change month by month?
WITH monthly AS (
    SELECT
        purchase_month,
        COUNT(*)          AS orders,
        SUM(item_revenue) AS revenue
    FROM delivered_orders
    GROUP BY purchase_month
)
SELECT
    purchase_month,
    orders,
    ROUND(revenue, 2)          AS revenue,
    ROUND(revenue / orders, 2) AS avg_order_value,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY purchase_month))
        / LAG(revenue) OVER (ORDER BY purchase_month),
        1
    )                          AS revenue_growth_pct   -- vs. previous month
FROM monthly
ORDER BY purchase_month;
