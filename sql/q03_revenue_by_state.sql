-- Q3. Where do customers and revenue come from geographically?
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id)                           AS customers,
    COUNT(*)                                                     AS orders,
    ROUND(SUM(item_revenue), 2)                                  AS revenue,
    ROUND(SUM(item_revenue) / COUNT(*), 2)                       AS avg_order_value,
    ROUND(100.0 * SUM(item_revenue) / SUM(SUM(item_revenue)) OVER (), 1) AS pct_of_revenue
FROM delivered_orders
GROUP BY customer_state
ORDER BY revenue DESC;
