WITH monthly_balance AS (
    SELECT
        customer_id,
        LAST_DAY(txn_date) AS closing_month,
        SUM(
        CASE
            WHEN txn_type = 'deposit' OR txn_type = 'purchase' THEN -txn_amount
            ELSE txn_amount
            END
        ) AS monthly_trans
    FROM customer_transactions
    GROUP BY customer_id, txn_date
),
month_end AS (
    SELECT
        DISTINCT customer_id,
        LAST_DAY(DATE_ADD('2020-01-01', INTERVAL seq.n MONTH)) AS ending_month
    FROM customer_transactions
    CROSS JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    ) AS seq
),
monthly_change AS (
    SELECT
        me.customer_id,
        me.ending_month,
        SUM(mb.monthly_trans) OVER  (
            PARTITION BY me.customer_id, me.ending_month
            ORDER BY me.ending_month
        ) AS total_month_change,
        SUM(mb.monthly_trans) OVER (
            PARTITION BY me.customer_id
            ORDER BY me.ending_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- dong dau den dong hien tai
        ) AS ending_balance
    FROM month_end me
    LEFT JOIN monthly_balance mb
    ON mb.customer_id = me.customer_id
    AND mb.closing_month = me.ending_month
)
SELECT
    customer_id,
    ending_month,
    COALESCE(total_month_change, 0) AS total_month_change,
    MIN(ending_balance) AS ending_balance -- lay dong trc khi cong them giao dich sau
FROM monthly_change
GROUP BY customer_id, ending_month, total_month_change
ORDER BY customer_id, ending_month;
