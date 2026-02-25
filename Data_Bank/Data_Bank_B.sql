-- 1, What is the unique count and total amount for each transaction type?
SELECT
    txn_type,
    COUNT(customer_id) AS count_unique,
    SUM(txn_amount)
FROM customer_transactions
GROUP BY txn_type;

-- 2, What is the average total historical deposit counts and amounts for all customers?
WITH deposits AS (
    SELECT
        COUNT(customer_id) AS total_count,
        SUM(txn_amount) AS total_amt
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT
    ROUND(AVG(total_count), 2) AS avg_count,
    ROUND(AVG(total_amt), 2) AS avg_amt
FROM deposits;

-- 3, For each month - how many Data Bank customers
-- make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_trans AS (
    SELECT
        customer_id,
        MONTH(txn_date) AS mth,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_cnt,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS wth_cnt,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS pur_count
    FROM customer_transactions
    GROUP BY customer_id, mth
)
SELECT
    mth,
    COUNT(customer_id)
FROM monthly_trans
WHERE deposit_cnt > 1
AND (wth_cnt = 1 OR pur_count = 1)
GROUP BY mth
ORDER BY mth;

-- 4, What is the closing balance for each customer at the end of the month?