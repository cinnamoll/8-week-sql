-- 1, What are the top 3 products by total revenue before discount?
SELECT 
    p.product_name,
    SUM(s.qty * s.price) AS total_revenue
FROM sales s
INNER JOIN product_details p
ON p.product_id = s.prod_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 2, What is the total quantity, revenue and discount for each segment?
SELECT 
    p.segment_id,
    p.segment_name,
    SUM(s.qty) AS total_qty,
    SUM(s.qty * s.price * ((100 - s.discount) / 100)) AS total_revenue,
    SUM(s.qty * s.price * (s.discount / 100)) AS total_discount
FROM sales s
INNER JOIN product_details p 
ON s.prod_id = p.product_id
GROUP BY p.segment_id, p.segment_name
ORDER BY p.segment_id;

-- 3, What is the top selling product for each segment?
WITH top_selling AS (
    SELECT 
        p.segment_id,
        p.segment_name,
        p.product_id,
        p.product_name,
        SUM(s.qty) AS total_sold,
        RANK() OVER (
            PARTITION BY p.segment_id
            ORDER BY SUM(s.qty) DESC
        ) AS ranking
    FROM sales s
    INNER JOIN product_details p
    ON p.product_id = s.prod_id
    GROUP BY p.segment_id, p.segment_name, p.product_id, p.product_name
)
SELECT 
    segment_id,
    segment_name,
    product_id,
    product_name,
    total_sold
FROM top_selling
WHERE ranking = 1;

-- 4, What is the total quantity, revenue and discount for each category?
SELECT 
    p.category_id,
    p.category_name,
    SUM(s.qty) AS total_quantity,
    SUM(s.price * s.qty) AS total_rev,
    SUM(s.price * s.qty * (s.discount / 100)) AS total_discount
FROM sales s
INNER JOIN product_details p 
ON s.prod_id = p.product_id
GROUP BY p.category_id, p.category_name;

-- 5, What is the top selling product for each category?
WITH top_selling AS (
    SELECT
        p.product_id,
        p.product_name, 
        p.category_name,
        p.category_id,
        SUM(s.qty) As total_quantity,
        RANK() OVER(
            PARTITION BY p.category_id
            ORDER BY SUM(s.qty) DESC
        ) AS ranking
    FROM sales s
    INNER JOIN product_details p
    ON s.prod_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id, p.category_name
)
SELECT
    category_id,
    category_name,
    product_id,
    product_name,
    total_quantity
FROM top_selling
WHERE ranking = 1;

-- 6, What is the percentage split of revenue by product for each segment?
SELECT 
    p.segment_name,
    p.product_name,
    ROUND(
        100 * (SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) OVER (PARTITION BY p.segment_name))
    , 2) AS percent_value
FROM sales s
INNER JOIN product_details p
ON p.product_id = s.prod_id
GROUP BY p.segment_name, p.product_name
ORDER BY 1, 3 DESC;

-- 7, What is the percentage split of revenue by segment for each category?
SELECT 
    p.category_name,
    p.product_name,
    ROUND(
        100 * (SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) OVER (PARTITION BY p.category_name))
    , 2) AS percent_value
FROM sales s
INNER JOIN product_details p
ON p.product_id = s.prod_id
GROUP BY p.category_name, p.product_name
ORDER BY 1, 3 DESC;

-- 8, What is the percentage split of total revenue by category?
SELECT
    p.category_name,
    ROUND(100 * SUM(s.qty * s.price) / SUM(SUM(s.qty * s.price)) OVER(), 2) AS percent_value
FROM sales s
INNER JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.category_name;

-- 9, What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased 
-- divided by total number of transactions)
SELECT 
    p.product_id,
    p.product_name,
    ROUND(100 * (COUNT(p.product_name) / ss.total_txn), 2) AS penetration_percent
FROM sales s 
INNER JOIN product_details p 
ON p.product_id = s.prod_id
CROSS JOIN (
    SELECT COUNT(DISTINCT txn_id) AS total_txn FROM sales 
) AS ss
GROUP BY p.product_id, p.product_name, ss.total_txn
ORDER BY 3 DESC;

-- 10, What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH product_txn AS (
    SELECT
        s.txn_id,
        p.product_name
    FROM sales s
    INNER JOIN product_details p
    ON p.product_id = s.prod_id
), product_combination AS (
    SELECT
        p1.product_name AS prod_1,
        p2.product_name AS prod_2,
        p3.product_name AS prod_3,
        COUNT(*) AS time_bought_together
    FROM product_txn p1
    JOIN product_txn p2
    ON p1.txn_id = p2.txn_id 
    AND p1.product_name < p2.product_name
    JOIN product_txn p3
    ON p1.txn_id = p3.txn_id 
    AND p1.product_name < p3.product_name
    GROUP BY p1.product_name, p2.product_name, p3.product_name
)
SELECT 
    prod_1,
    prod_2,
    prod_3,
    time_bought_together
FROM product_combination
ORDER BY time_bought_together DESC
LIMIT 1;