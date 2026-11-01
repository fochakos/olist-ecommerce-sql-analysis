-- Q9. How do customers pay, and how common are installments?
WITH delivered_payments AS (
    SELECT p.order_id, p.payment_type, p.payment_installments, p.payment_value
    FROM payments AS p
    JOIN delivered_orders AS d
        ON d.order_id = p.order_id
    WHERE p.payment_type <> 'not_defined'
)
SELECT
    payment_type,
    COUNT(DISTINCT order_id)                                         AS orders,
    ROUND(SUM(payment_value), 2)                                     AS amount_paid,
    ROUND(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 1) AS pct_of_amount,
    ROUND(AVG(payment_value), 2)                                     AS avg_payment,
    ROUND(AVG(payment_installments), 1)                              AS avg_installments
FROM delivered_payments
GROUP BY payment_type
ORDER BY amount_paid DESC;
