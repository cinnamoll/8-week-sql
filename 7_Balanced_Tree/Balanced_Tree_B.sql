-- 1, How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id)
FROM sales;

-- 2, What is the average unique products purchased in each transaction?
SELECT ROUND(AVG(total_quantity))
FROM (
    SELECT 
        txn_id,
        SUM(qty) AS total_quantity
    FROM sales
    GROUP BY txn_id
) AS total_quantities;

-- 3, What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH rev_per_trans AS (
    SELECT
        txn_id,
        ROUND(SUM(qty* price * (1 - (discount / 100))), 2) AS revenue
    FROM sales 
    GROUP BY txn_id
), percentile AS (
    SELECT
        txn_id,
        revenue,
        PERCENT_RANK() OVER (
            ORDER BY revenue
        ) AS percentile_rank
    FROM rev_per_trans
) 
SELECT 
    txn_id,
    revenue,
    percentile_rank
FROM percentile
WHERE percentile_rank >= 0.25 -- 0.5, 0.75
LIMIT 1;

-- 4, What is the average discount value per transaction?
SELECT 
    ROUND(AVG(discount_amt), 2) AS avg_discount
FROM (
    SELECT 
        txn_id,
        SUM(qty * price * (discount/100)) AS discount_amt
    FROM sales
    GROUP BY txn_id
) AS disc;

-- 5, What is the percentage split of all transactions for members vs non-members?
SELECT 
    member,
    ROUND(100 * COUNT(DISTINCT txn_id) / (SELECT COUNT(DISTINCT txn_id) FROM sales), 2) AS total 
FROM sales 
GROUP BY member

-- 6, What is the average revenue for member transactions and non-member transactions?
SELECT
    ROUND(AVG(total_rev), 2) AS total_revenue
FROM (
    SELECT
        member,
        SUM(qty * price * ((100 - discount) / 100)) AS total_rev
    FROM sales
    GROUP BY member
) AS rev_mem;
