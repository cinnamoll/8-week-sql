USE pizza_runner;

-- 1, How many runners signed up for each 1 week period?
SELECT
    WEEK(registration_date) AS regis_week,
    COUNT(runner_id) AS sign_up
FROM runners
GROUP BY WEEK(registration_date);

-- 2, What was the average time in minutes it took for each runner
-- to arrive at the Pizza Runner HQ to pickup the order?
SELECT
    r.runner_id,
    AVG(MINUTE(TIMEDIFF(r.pickup_time, c.order_time))) AS avg_in_min
FROM runner_orders r
JOIN customer_orders c
ON c.order_id = r.order_id
GROUP BY r.runner_id
ORDER BY r.runner_id;

-- 3, Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
    c.order_id,
    COUNT(c.pizza_id),
    AVG(r.duration)
FROM customer_orders c
JOIN runner_orders r
ON r.order_id = c.order_id
WHERE r.duration IS NOT NULL
GROUP BY c.order_id
ORDER BY c.order_id;

-- 4, What was the average distance travelled for each customer?
SELECT
    c.customer_id,
    AVG(r.distance) AS length
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- 5, What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration)
FROM runner_orders;

-- 6, What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
    order_id,
    runner_id,
    distance / (duration / 60) AS speed
FROM runner_orders
WHERE duration IS NOT NULL;

-- 7, What is the successful delivery percentage for each runner?
SELECT
    runner_id,
    ROUND(100 * SUM(
        CASE
            WHEN distance IS NOT NULL THEN 1
            ELSE 0
            END
    )/COUNT(*) , 0) AS success_rate
FROM runner_orders
GROUP BY runner_id;