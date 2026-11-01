-- Data-quality checks run before any analysis. Each row is one check.
SELECT 'orders in raw data' AS check_name, COUNT(*) AS value FROM orders
UNION ALL
SELECT 'orders with no items', COUNT(*)
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM order_items AS i WHERE i.order_id = o.order_id)
UNION ALL
SELECT 'delivered orders with no delivery date', COUNT(*)
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL
UNION ALL
SELECT 'customer_id values (one per order)', COUNT(DISTINCT customer_id) FROM customers
UNION ALL
SELECT 'real customers (customer_unique_id)', COUNT(DISTINCT customer_unique_id) FROM customers
UNION ALL
SELECT 'orders with more than one review', COUNT(*)
FROM (SELECT order_id FROM reviews GROUP BY order_id HAVING COUNT(*) > 1) AS d
UNION ALL
SELECT 'products with no category', COUNT(*) FROM products WHERE product_category_name IS NULL
UNION ALL
SELECT 'products with untranslated category', COUNT(*)
FROM products AS p
LEFT JOIN category_translation AS t ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL
UNION ALL
SELECT 'orders where payments differ from items + freight by > 1 BRL', COUNT(*)
FROM (SELECT order_id, SUM(payment_value) AS paid FROM payments GROUP BY order_id) AS p
JOIN (SELECT order_id, SUM(price + freight_value) AS billed FROM order_items GROUP BY order_id) AS b
    ON b.order_id = p.order_id
WHERE ABS(p.paid - b.billed) > 1
UNION ALL
SELECT 'orders in analysis window (Jan 2017 - Aug 2018)', COUNT(*) FROM order_facts
UNION ALL
SELECT 'delivered orders in analysis window', COUNT(*) FROM delivered_orders;
