USE pizza_runner;

-- 1,What are the standard ingredients for each pizza?
CREATE TEMPORARY TABLE standard_ingredients AS
SELECT
    pizza_id,
    pizza_name,
    GROUP_CONCAT(DISTINCT topping_name) AS standard
FROM pizza_recipes_split
INNER JOIN pizza_names USING(pizza_id)
INNER JOIN pizza_toppings
ON pizza_recipes_split.pizza_toppings = pizza_toppings.topping_id
GROUP BY pizza_id, pizza_name
ORDER BY pizza_id;

SELECT * FROM standard_ingredients;

-- 2, What was the most commonly added extra?
WITH extra_count_cte AS (
    SELECT
        TRIM(extras) AS extra_topping,
        COUNT(*) AS purchase
    FROM customer_orders_split
    WHERE extras IS NOT NULL
    GROUP BY extras
)
SELECT
    topping_name,
    purchase
FROM extra_count_cte e
INNER JOIN pizza_toppings p
ON e.extra_topping = p.topping_id
LIMIT 1;

-- 3, What was the most common exclusion?
WITH extra_count_cte AS (
    SELECT
        TRIM(exclusions) AS exclude,
        COUNT(*) AS purchase
    FROM customer_orders_split
    WHERE exclusions IS NOT NULL
    GROUP BY exclusions
)
SELECT
    topping_name,
    purchase
FROM extra_count_cte e
INNER JOIN pizza_toppings p
ON e.exclude = p.topping_id
LIMIT 1;

-- 4 Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH order_summary_cte AS (
    SELECT
        pizza_name,
        row_num,
        order_id,
        customer_id,
        excluded_topping,
        t2.topping_name AS extras_topping
   FROM
     (SELECT *,
             topping_name AS excluded_topping
      FROM customer_orders_split
      LEFT JOIN standard_ingredients USING (pizza_id)
      LEFT JOIN pizza_toppings ON topping_id = exclusions) t1
   LEFT JOIN pizza_toppings t2 ON t2.topping_id = extras
)
SELECT order_id,
       customer_id,
       CASE
           WHEN excluded_topping IS NULL
                AND extras_topping IS NULL
                THEN pizza_name
           WHEN extras_topping IS NULL
                AND excluded_topping IS NOT NULL
                THEN concat(pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
           WHEN excluded_topping IS NULL
                AND extras_topping IS NOT NULL
                THEN concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping))
           ELSE concat(pizza_name, ' - Include ', GROUP_CONCAT(DISTINCT extras_topping), ' - Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
       END AS order_item
FROM order_summary_cte
GROUP BY row_num;