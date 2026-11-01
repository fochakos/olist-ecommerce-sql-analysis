-- Q13. RFM customer segmentation (recency, frequency, monetary value).
-- About 97% of customers order once, so frequency is used as "1 vs 2+ orders"
-- rather than a quintile; recency and spend are scored 1-5 with NTILE.
WITH snapshot AS (
    SELECT CAST(MAX(purchased_at) AS DATE) + 1 AS as_of FROM delivered_orders
),
per_customer AS (
    SELECT
        d.customer_unique_id,
        (SELECT as_of FROM snapshot) - CAST(MAX(d.purchased_at) AS DATE) AS recency_days,
        COUNT(*)                                                         AS frequency,
        SUM(d.item_revenue)                                              AS monetary
    FROM delivered_orders AS d
    GROUP BY d.customer_unique_id
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- 5 = most recent
        NTILE(5) OVER (ORDER BY monetary)          AS m_score    -- 5 = highest spend
    FROM per_customer
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN frequency >= 2 AND r_score >= 4 THEN 'Loyal, recent'
            WHEN frequency >= 2                  THEN 'Repeat, lapsing'
            WHEN r_score >= 4 AND m_score >= 4   THEN 'New, high value'
            WHEN r_score >= 4                    THEN 'New, low value'
            WHEN m_score >= 4                    THEN 'Lapsed, high value'
            ELSE                                      'Lapsed, low value'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*)                                                   AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)         AS pct_of_customers,
    ROUND(AVG(recency_days), 0)                                AS avg_days_since_last_order,
    ROUND(AVG(monetary), 2)                                    AS avg_spend,
    ROUND(SUM(monetary), 2)                                    AS revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_of_revenue
FROM segmented
GROUP BY segment
ORDER BY revenue DESC;
