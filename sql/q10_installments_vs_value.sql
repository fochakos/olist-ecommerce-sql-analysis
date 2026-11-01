-- Q10. For credit-card payments, do bigger purchases get split into more installments?
WITH card_payments AS (
    SELECT p.payment_installments, p.payment_value
    FROM payments AS p
    JOIN delivered_orders AS d
        ON d.order_id = p.order_id
    WHERE p.payment_type = 'credit_card'
)
SELECT
    CASE
        WHEN payment_installments <= 1 THEN '1. paid in full'
        WHEN payment_installments <= 3 THEN '2. 2-3 installments'
        WHEN payment_installments <= 6 THEN '3. 4-6 installments'
        ELSE                                '4. 7+ installments'
    END                                                   AS installment_plan,
    COUNT(*)                                              AS payments,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)    AS pct_of_card_payments,
    ROUND(AVG(payment_value), 2)                          AS avg_payment_value
FROM card_payments
GROUP BY 1
ORDER BY 1;
