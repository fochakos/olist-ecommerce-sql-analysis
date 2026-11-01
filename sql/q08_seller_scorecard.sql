-- Q8. Seller scorecard: revenue, rating and late-delivery rate for sellers with 50+ orders.
-- Aggregate to one row per seller per order first, so an order with several items
-- from the same seller doesn't count its review more than once.
WITH seller_orders AS (
    SELECT seller_id, order_id, SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id, order_id
),
seller_stats AS (
    SELECT
        so.seller_id,
        COUNT(*)             AS orders,
        SUM(so.revenue)      AS revenue,
        AVG(d.review_score)  AS avg_review_score,
        AVG(d.is_late)       AS late_rate
    FROM seller_orders AS so
    JOIN delivered_orders AS d
        ON d.order_id = so.order_id
    GROUP BY so.seller_id
)
SELECT
    RANK() OVER (ORDER BY st.revenue DESC)              AS revenue_rank,
    st.seller_id,
    s.seller_state,
    st.orders,
    ROUND(st.revenue, 2)                                AS revenue,
    ROUND(st.avg_review_score, 2)                       AS avg_review_score,
    ROUND(100.0 * st.late_rate, 1)                      AS late_pct,
    CASE WHEN st.avg_review_score < 3.8 THEN 'review' ELSE 'ok' END AS flag
FROM seller_stats AS st
JOIN sellers AS s
    ON s.seller_id = st.seller_id
WHERE st.orders >= 50
ORDER BY st.revenue DESC;
