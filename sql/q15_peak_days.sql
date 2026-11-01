-- Q15. What were the busiest days, and how far above a normal day were they?
-- Canceled and unavailable orders are left out.
WITH daily AS (
    SELECT
        CAST(purchased_at AS DATE) AS order_date,
        COUNT(*)                   AS orders,
        SUM(item_revenue)          AS revenue
    FROM order_facts
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY CAST(purchased_at AS DATE)
)
SELECT
    order_date,
    orders,
    ROUND(revenue, 2)                        AS revenue,
    ROUND(orders / AVG(orders) OVER (), 1)   AS times_average_day
FROM daily
ORDER BY orders DESC
LIMIT 10;
