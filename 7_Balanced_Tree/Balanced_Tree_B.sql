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
) 
SELECT 
    txn_id,
    revenue,
    ROUND(PERCENT_RANK() OVER (
        ORDER BY revenue
    ),2) AS percentile_rank
FROM rev_per_trans;