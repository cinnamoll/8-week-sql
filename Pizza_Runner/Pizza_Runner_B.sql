USE pizza_runner;

-- 1, How many runners signed up for each 1 week period?
SELECT
    WEEK(registration_date) AS regis_week,
    COUNT(runner_id) AS sign_up
FROM runners
GROUP BY WEEK(registration_date);

-- 2, What was the average time in minutes it took for each runner
-- to arrive at the Pizza Runner HQ to pickup the order?
