-- Q11. When do customers shop? Orders by day of week and hour of day.
-- day_of_week: 0 = Sunday ... 6 = Saturday (same convention in DuckDB and PostgreSQL).
SELECT
    CAST(EXTRACT(DOW  FROM purchased_at) AS INTEGER) AS day_of_week,
    CAST(EXTRACT(HOUR FROM purchased_at) AS INTEGER) AS hour_of_day,
    COUNT(*)                                         AS orders
FROM order_facts
GROUP BY 1, 2
ORDER BY 1, 2;
