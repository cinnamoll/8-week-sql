USE pizza_runner;

-- 1, If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and
-- there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
    SUM(
        CASE
            WHEN c.pizza_id = 1 THEN 12
            ELSE 10
        END
    ) AS total_cost
FROM customer_orders c
INNER JOIN runner_orders r
ON c.order_id = r.order_id
WHERE cancellation IS NULL;

-- 2, What if there was an additional $1 charge for any pizza extras?
SELECT (total_pizza + total_toppings)
FROM
(SELECT
    SUM(
        CASE
            WHEN pizza_id = 1 THEN 12
            ELSE 10
        END
    ) AS total_pizza,
    SUM(topping_count) AS total_toppings
FROM
    (
        SELECT *,
               LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1 AS topping_count
        FROM customer_orders c
        INNER JOIN runner_orders r USING(order_id)
        INNER JOIN pizza_names USING(pizza_id)
        WHERE r.cancellation IS NULL
        ORDER BY order_id
    )t1
)t2;

-- 3, The Pizza Runner team now wants to add an additional ratings system that
-- allows customers to rate their runner, how would you design an additional table for this new dataset
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
    order_id INT,
    rating INT
);

INSERT INTO ratings
VALUES (1, 2),
       (2, 5),
       (3, 4),
       (4, 1),
       (5, 2),
       (6, 3),
       (7, 4),
       (8, 5),
       (9, 1),
       (10, 4);

SELECT * FROM ratings;

-- 4, Using your newly generated table - can you join all of the information together to
-- form a table which has the following information for successful deliveries?

SELECT
    customer_id,
    order_id,
    runner_id,
    rating,
    order_time,
    pickup_time,
    TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS time_order_pickup,
    duration,
    distance / (duration / 60) AS speed,
    COUNT(pizza_id) AS total_pizza
FROM customer_orders
INNER JOIN runner_orders USING(order_id)
INNER JOIN ratings USING(order_id)
WHERE cancellation IS NULL
GROUP BY customer_id, order_id, runner_id, rating, order_time, pickup_time, pickup_time, order_time, duration, distance, duration;