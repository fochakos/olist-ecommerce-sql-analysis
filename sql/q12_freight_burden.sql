-- Q12. Which states pay the most for shipping relative to what they buy?
SELECT
    customer_state,
    COUNT(*)                                          AS delivered_orders,
    ROUND(AVG(item_revenue), 2)                       AS avg_order_value,
    ROUND(AVG(freight), 2)                            AS avg_freight,
    ROUND(100.0 * SUM(freight) / SUM(item_revenue), 1) AS freight_pct_of_price,
    ROUND(AVG(delivery_days), 1)                      AS avg_delivery_days
FROM delivered_orders
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY freight_pct_of_price DESC;
