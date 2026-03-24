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