-- Reusable views that every analysis query builds on.
-- Written in standard SQL (CTEs, window functions) so it also runs on PostgreSQL.

-- Each order line with an English category name.
-- 13 products have Portuguese categories missing from the translation table,
-- so fall back to the Portuguese name, then to 'unknown'.
CREATE OR REPLACE VIEW order_items_enriched AS
SELECT
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
FROM order_items AS i
LEFT JOIN products AS p
    ON p.product_id = i.product_id
LEFT JOIN category_translation AS t
    ON t.product_category_name = p.product_category_name;


-- One row per order, January 2017 to August 2018.
-- Months before 2017 and after August 2018 hold only a handful of orders, so they are excluded.
CREATE OR REPLACE VIEW order_facts AS
WITH items AS (
    SELECT
        order_id,
        COUNT(*)           AS item_count,
        SUM(price)         AS item_revenue,
        SUM(freight_value) AS freight
    FROM order_items
    GROUP BY order_id
),
latest_review AS (
    -- About 550 orders have more than one review: keep the most recent.
    SELECT order_id, review_score
    FROM (
        SELECT
            order_id,
            review_score,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY review_answer_timestamp DESC, review_creation_date DESC
            ) AS rn
        FROM reviews
    ) AS ranked
    WHERE rn = 1
)
SELECT
    o.order_id,
    o.order_status,
    c.customer_unique_id,          -- customer_id changes with every order; this one doesn't
    c.customer_state,
    o.order_purchase_timestamp                                   AS purchased_at,
    CAST(DATE_TRUNC('month', o.order_purchase_timestamp) AS DATE) AS purchase_month,
    o.order_delivered_customer_date                              AS delivered_at,
    o.order_estimated_delivery_date                              AS estimated_at,
    CAST(o.order_delivered_customer_date AS DATE)
        - CAST(o.order_purchase_timestamp AS DATE)               AS delivery_days,
    CAST(o.order_delivered_customer_date AS DATE)
        - CAST(o.order_estimated_delivery_date AS DATE)          AS days_vs_estimate,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        WHEN CAST(o.order_delivered_customer_date AS DATE)
           > CAST(o.order_estimated_delivery_date AS DATE) THEN 1
        ELSE 0
    END                                                          AS is_late,
    i.item_count,
    i.item_revenue,
    i.freight,
    r.review_score
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
LEFT JOIN items AS i
    ON i.order_id = o.order_id
LEFT JOIN latest_review AS r
    ON r.order_id = o.order_id
WHERE o.order_purchase_timestamp >= TIMESTAMP '2017-01-01'
  AND o.order_purchase_timestamp <  TIMESTAMP '2018-09-01';


-- Completed sales: delivered orders with a delivery date.
-- Revenue in this project = item price (BRL), excluding freight.
CREATE OR REPLACE VIEW delivered_orders AS
SELECT *
FROM order_facts
WHERE order_status = 'delivered'
  AND delivered_at IS NOT NULL;
