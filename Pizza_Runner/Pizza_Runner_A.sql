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
WITH pizza_cte AS (
    SELECT
        c.order_id,
        COUNT(c.pizza_id) AS max_pizza
    FROM customer_orders c
    JOIN runner_orders r
    ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL
    GROUP BY c.order_id
)
SELECT
    order_id,
    max_pizza
FROM pizza_cte
ORDER BY max_pizza DESC
LIMIT 1;

SELECT * FROM customer_orders;

-- 7, For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
    c.customer_id,
    SUM(
        CASE
            WHEN exclusions IS NULL AND extras IS NULL THEN 1
            ELSE 0
            END
    ) AS no_change,
    SUM(
        CASE
            WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1
            ELSE 0
            END
    ) AS at_least_1_change
FROM customer_orders c
JOIN runner_orders r
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 8, How many pizzas were delivered that had both exclusions and extras?
SELECT
    c.customer_id,
    SUM(
        CASE
            WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
            ELSE 0
            END
    ) AS have_both
FROM customer_orders c
JOIN runner_orders r
ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 9, What was the total volume of pizzas ordered for each hour of the day?
SELECT
    HOUR(order_time) AS hour_in_day,
    SUM(pizza_id) AS total_vol
FROM customer_orders
GROUP BY hour_in_day
ORDER BY hour_in_day;

-- 10, What was the volume of orders for each day of the week?
SELECT
    DAYOFWEEK(order_time) AS day_in_week,
    COUNT(order_id) AS total_order
FROM customer_orders
GROUP BY day_in_week
ORDER BY day_in_week;