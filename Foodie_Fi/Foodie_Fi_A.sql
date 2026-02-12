-- Based off the 8 sample customers provided in the sample from the subscriptions table,
-- write a brief description about each customer’s onboarding journey.

-- id = 1: trial - 7 days, monthly

SELECT
    customer_id,
    plan_id,
    start_date,
    plan_name
FROM subscriptions_sample
JOIN plans USING(plan_id)
WHERE customer_id = 1;

-- id = 2: trial - 7 days, annual

SELECT
    customer_id,
    plan_id,
    start_date,
    plan_name
FROM subscriptions_sample
JOIN plans USING(plan_id)
WHERE customer_id = 2;

-- id = 13: trial - 7 days, basic monthly - 3 month, pro monthly

SELECT
    customer_id,
    plan_id,
    start_date,
    plan_name
FROM subscriptions_sample
JOIN plans USING(plan_id)
WHERE customer_id = 13;