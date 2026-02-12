-- 1, How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id)
FROM subscriptions;

-- 2, What is the monthly distribution of trial plan start_date values for our dataset
-- - use the start of the month as the group by value
SELECT
    MONTH(start_date),
    COUNT(DISTINCT customer_id) AS count_trial
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH(start_date);

-- 3, What plan start_date values occur after the year 2020 for our dataset?
-- Show the breakdown by count of events for each plan_name
SELECT
    plan_id,
    plan_name,
    COUNT(DISTINCT customer_id)
FROM subscriptions
JOIN plans USING(plan_id)
WHERE YEAR(start_date) > 2020
GROUP BY plan_id, plan_name;

-- 4, What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
    COUNT(DISTINCT customer_id) AS count_churn,
    ROUND(100 * COUNT(DISTINCT customer_id) / (
        SELECT COUNT(DISTINCT customer_id) AS count_total
        FROM subscriptions
        ), 2) AS churn_percent
FROM subscriptions
WHERE plan_id = 4;

-- 5, How many customers have churned straight after their initial free trial -
-- what percentage is this rounded to the nearest whole number?
WITH next_plan_cte AS (
    SELECT
        *,
        LEAD(plan_id, 1) OVER(PARTITION BY(customer_id) ORDER BY start_date) AS next_plan
    FROM subscriptions
),
    churners AS (
    SELECT *
    FROM next_plan_cte
    WHERE next_plan = 4
    AND plan_id = 0
)
SELECT
    COUNT(DISTINCT customer_id) AS count_churn,
    ROUND(100 * COUNT(DISTINCT customer_id) / (
        SELECT COUNT(DISTINCT customer_id) AS count_total
        FROM subscriptions
        ), 2) AS churn_percentage
FROM churners;

-- 6, What is the number and percentage of customer plans after their initial free trial?
SELECT
    plan_id,
    plan_name,
    COUNT(DISTINCT customer_id) AS total_plan,
    ROUND(100 * COUNT(DISTINCT customer_id) / (
        SELECT COUNT(DISTINCT customer_id) AS total_count
        FROM subscriptions
        ), 2) AS percent
FROM subscriptions
JOIN plans USING(plan_id)
WHERE plan_id != 0
GROUP BY plan_id, plan_name;

-- 7, What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH largest_plan_cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY start_date DESC
        ) AS latest_plan
    FROM subscriptions
    JOIN plans USING(plan_id)
    WHERE start_date <= '2020-12-31'
)
SELECT
    plan_id,
    plan_name,
    COUNT(DISTINCT customer_id) AS total_plan,
    ROUND(100 * COUNT(DISTINCT customer_id) / (
        SELECT COUNT(DISTINCT customer_id)
        FROM subscriptions
        ), 2) AS percent
FROM largest_plan_cte
WHERE latest_plan = 1
GROUP BY plan_id, plan_name
ORDER BY plan_id;