-- 1, What was the total quantity sold for all products?
SELECT
    p.product_name,
    SUM(s.qty) AS total_sold
FROM sales s
INNER JOIN product_details p 
ON p.product_id = s.prod_id
GROUP BY p.product_name;

-- 2, What is the total generated revenue for all products before discounts?
SELECT
    p.product_name,
    SUM(s.qty) * SUM(s.price) AS total_revenue
FROM sales s
INNER JOIN product_details p 
ON p.product_id = s.prod_id
GROUP BY p.product_name;

-- 3,What was the total discount amount for all products?
SELECT
    p.product_name,
    ROUND(SUM(s.qty * s.price * (s.discount/100)), 0) AS total_discount
FROM sales s
INNER JOIN product_details p 
ON p.product_id = s.prod_id
GROUP BY p.product_name;