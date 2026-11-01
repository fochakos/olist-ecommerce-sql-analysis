-- Q2. Which product categories drive revenue, and how concentrated is it?
-- Running share of revenue (Pareto) shows how many categories make up 80%.
WITH category_revenue AS (
    SELECT
        e.category,
        COUNT(DISTINCT e.order_id) AS orders,
        SUM(e.price)               AS revenue
    FROM order_items_enriched AS e
    JOIN delivered_orders AS d
        ON d.order_id = e.order_id
    GROUP BY e.category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC)                     AS revenue_rank,
    category,
    orders,
    ROUND(revenue, 2)                                       AS revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 1)        AS pct_of_revenue,
    ROUND(
        100.0 * SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(revenue) OVER (),
        1
    )                                                       AS cumulative_pct
FROM category_revenue
ORDER BY revenue DESC;
