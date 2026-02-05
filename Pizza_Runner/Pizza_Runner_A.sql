USE pizza_runner;

-- 1, How many pizzas were ordered?
SELECT COUNT(*) AS total_order
FROM customer_orders;

-- 2, How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_order
FROM customer_orders;

SELECT * FROM runner_orders;

-- 3, How many successful orders were delivered by each runner?
SELECT runner_id,
       COUNT(order_id) AS success_orders
FROM runner_orders
WHERE distance IS NOT NULL
GROUP BY runner_id
ORDER BY runner_id;

-- 4, How many of each type of pizza was delivered?
SELECT p.pizza_name,
       COUNT(c.pizza_id) AS delivered
FROM customer_orders c
JOIN runner_orders r
ON r.order_id = c.order_id
JOIN pizza_names p
ON p.pizza_id = c.pizza_id
WHERE r.cancellation IS NULL
GROUP BY p.pizza_name;

-- 5, How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id,
       p.pizza_name,
       COUNT(c.pizza_id) AS total
FROM customer_orders c
JOIN pizza_names p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

-- 6, What was the maximum number of pizzas delivered in a single order?
