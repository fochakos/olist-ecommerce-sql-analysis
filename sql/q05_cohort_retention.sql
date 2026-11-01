-- Q5. Monthly cohort retention: of the customers who first bought in a given month,
-- what share bought again 1, 2, ... 6 months later?
WITH first_purchase AS (
    SELECT customer_unique_id, MIN(purchase_month) AS cohort_month
    FROM delivered_orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT DISTINCT
        d.customer_unique_id,
        f.cohort_month,
        (EXTRACT(YEAR FROM d.purchase_month) - EXTRACT(YEAR FROM f.cohort_month)) * 12
          + (EXTRACT(MONTH FROM d.purchase_month) - EXTRACT(MONTH FROM f.cohort_month)) AS month_number
    FROM delivered_orders AS d
    JOIN first_purchase AS f
        ON f.customer_unique_id = d.customer_unique_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    s.cohort_customers,
    CAST(a.month_number AS INTEGER)                        AS month_number,
    COUNT(*)                                               AS active_customers,
    ROUND(100.0 * COUNT(*) / s.cohort_customers, 2)        AS retention_pct
FROM activity AS a
JOIN cohort_size AS s
    ON s.cohort_month = a.cohort_month
WHERE a.month_number BETWEEN 0 AND 6
GROUP BY a.cohort_month, s.cohort_customers, a.month_number
ORDER BY a.cohort_month, month_number;
