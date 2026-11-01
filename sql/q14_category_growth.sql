-- Q14. Which categories grew fastest? January-August 2018 vs. the same months of 2017.
-- Only categories with at least 20,000 BRL of revenue in 2017 are compared.
WITH category_year AS (
    SELECT
        e.category,
        EXTRACT(YEAR FROM d.purchased_at) AS yr,
        SUM(e.price)                      AS revenue
    FROM order_items_enriched AS e
    JOIN delivered_orders AS d
        ON d.order_id = e.order_id
    WHERE EXTRACT(MONTH FROM d.purchased_at) <= 8
    GROUP BY 1, 2
),
pivoted AS (
    SELECT
        category,
        SUM(CASE WHEN yr = 2017 THEN revenue ELSE 0 END) AS revenue_2017,
        SUM(CASE WHEN yr = 2018 THEN revenue ELSE 0 END) AS revenue_2018
    FROM category_year
    GROUP BY category
)
SELECT
    category,
    ROUND(revenue_2017, 2)                                         AS revenue_jan_aug_2017,
    ROUND(revenue_2018, 2)                                         AS revenue_jan_aug_2018,
    ROUND(100.0 * (revenue_2018 - revenue_2017) / revenue_2017, 1) AS growth_pct
FROM pivoted
WHERE revenue_2017 >= 20000
ORDER BY growth_pct DESC;
