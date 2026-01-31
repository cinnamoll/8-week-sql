-- CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, 
	   SUM(m.price) AS total
FROM sales s
RIGHT JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
	   COUNT(DISTINCT order_date) AS visit_day
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales AS (
	SELECT s.customer_id,
		   s.order_date,
		   m.product_name,
		   DENSE_RANK() OVER (
			  PARTITION BY s.customer_id
			  ORDER BY s.order_date) AS ranking		   
    FROM sales s
    INNER JOIN menu m
    ON m.product_id = s.product_id
)

SELECT customer_id, product_name
FROM ordered_sales
WHERE ranking = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	m.product_name,
    COUNT(s.product_id) AS most_purchased_food
FROM 
	sales s
INNER JOIN 
	menu m
ON
	s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased_food DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH popular_item AS (
	SELECT
		s.customer_id,
        m.product_name,
        COUNT(m.product_id) AS order_count,
        DENSE_RANK() OVER (
			PARTITION BY s.customer_id
            ORDER BY COUNT(s.product_id) DESC
        ) AS ranks
	FROM
		sales s
	INNER JOIN
		menu m
	ON
		s.product_id = m.product_id
	GROUP BY 
		s.customer_id,
        m.product_name
)

SELECT 
	customer_id,
    product_name,
    order_count
FROM 
	popular_item
WHERE ranks = 1;