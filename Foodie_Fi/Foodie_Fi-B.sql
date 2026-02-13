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

-- 8, How many customers have upgraded to an annual plan in 2020?
SELECT
    COUNT(DISTINCT customer_id) AS total_to_annual
FROM subscriptions
WHERE plan_id = 3
AND YEAR(start_date) = '2020';

-- 9, How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH
    trial_plan_cte AS (
        SELECT *
        FROM subscriptions
        WHERE plan_id = 0
    ),
    annual_plan_cte AS (
        SELECT *
        FROM subscriptions
        WHERE plan_id = 3
    )
SELECT ROUND(AVG(DATEDIFF(annual_plan_cte.start_date, trial_plan_cte.start_date)), 2) AS avg_to_annual
FROM trial_plan_cte
JOIN annual_plan_cte USING(customer_id);

-- 10, Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH
    next_plan_cte AS (
        SELECT
            *,
            LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan,
            LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_start_date
        FROM subscriptions
    ),
    window_date AS (
        SELECT
            *,
            ROUND(DATEDIFF(next_start_date, start_date) / 30) AS window_30_days
        FROM next_plan_cte
        WHERE next_plan = 3
    )
SELECT
    window_30_days,
    COUNT(DISTINCT customer_id) AS total_customer
FROM window_date
GROUP BY window_30_days
ORDER BY window_30_days;

-- 11, How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH
    next_plan_cte AS (
        SELECT
            *,
            LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
        FROM subscriptions
    )
SELECT
    COUNT(DISTINCT customer_id)
FROM next_plan_cte
WHERE plan_id = 2
AND next_plan = 1;