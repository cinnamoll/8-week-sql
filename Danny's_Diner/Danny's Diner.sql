CREATE SCHEMA dannys_diner;
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

-- 6. Which item was purchased first by the customer after they became a member?
WITH joined_member AS (
	SELECT me.customer_id,
		   s.product_id,
           ROW_NUMBER() OVER (
			  PARTITION BY me.customer_id
              ORDER BY s.order_date) AS row_num
	FROM members me
    INNER JOIN sales s
    ON me.customer_id = s.customer_id 
    AND s.order_date >= me.join_date
)

SELECT customer_id,
	   m.product_name
FROM joined_member j
INNER JOIN menu m
ON m.product_id = j.product_id
WHERE row_num = 1
ORDER BY customer_id;

-- 7. Which item was purchased just before the customer became a member?
WITH joined_mem AS (
	SELECT me.customer_id,
		   s.product_id,
           ROW_NUMBER() OVER (
		       PARTITION BY me.customer_id
               ORDER BY s.order_date DESC) AS row_num
	FROM members me
    INNER JOIN sales s
    ON me.customer_id = s.customer_id
    AND s.order_date < me.join_date
)

SELECT customer_id,
	   m.product_name
FROM joined_mem j
INNER JOIN menu m
ON m.product_id = j.product_id
WHERE row_num = 1
ORDER BY customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
	   COUNT(s.product_id) AS total_item,
       SUM(m.price) AS total_amt
FROM sales s
INNER JOIN members me
ON s.customer_id = me.customer_id
AND s.order_date < me.join_date
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
	SELECT product_id,
    CASE
		WHEN product_id = 1 THEN price*20
        ELSE price*10 
        END
	AS points
    FROM menu
)

SELECT s.customer_id,
	   SUM(p.points) AS total
FROM sales s
INNER JOIN points_cte p
ON s.product_id = p.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?
WITH dates_cte AS (
	SELECT customer_id,
		   join_date,
           DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date,
           LAST_DAY('2021-01-31') AS last_date
	FROM members
)

SELECT s.customer_id,
	   SUM(
		CASE
			WHEN m.product_id = 1 THEN m.price * 2 * 10
            WHEN s.order_date BETWEEN join_date AND valid_date THEN m.price * 20
            ELSE m.price * 10 END) AS points
FROM sales s
INNER JOIN dates_cte d
ON s.customer_id = d.customer_id
AND d.join_date <= s.order_date
AND s.order_date <= d.last_date
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- Join all the thing
SELECT s.customer_id,
	   s.order_date,
       m.product_name,
       m.price,
       CASE 
		WHEN s.order_date >= me.join_date THEN 'Y'
        ELSE 'N' END AS member_status
FROM sales s
INNER JOIN members me
ON s.customer_id = me.customer_id
LEFT JOIN menu m
ON s.product_id = m.product_id;

-- Rank all the thing
WITH customer_data AS (
	SELECT s.customer_id,
		   s.order_date,
		   m.product_name,
		   m.price,
		   CASE 
			WHEN s.order_date >= me.join_date THEN 'Y'
			ELSE 'N' END AS member_status
	FROM sales s
	INNER JOIN members me
	ON s.customer_id = me.customer_id
	LEFT JOIN menu m
	ON s.product_id = m.product_id
)

SELECT *,
	   CASE
		WHEN member_status = 'N' THEN NULL
        ELSE RANK() OVER (
			PARTITION BY member_status, customer_id
            ORDER BY order_date
        ) END AS ranking
FROM customer_data;
