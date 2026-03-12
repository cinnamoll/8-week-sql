-- 1, How many users are there?
SELECT COUNT(user_id)
FROM users;

-- 2, How many cookies does each user have on average?
WITH cookie AS (
    SELECT
        user_id,
        COUNT(cookie_id) AS cookie_count
    FROM users
    GROUP BY user_id
)
SELECT AVG(cookie_count) FROM cookie;

-- 3, What is the unique number of visits by all users per month?
SELECT 
    MONTH(event_time) AS m,
    COUNT (DISTINCT visit_id) AS unique_visit 
FROM events
GROUP BY m
ORDER BY m;

-- 4, What is the number of events for each event type?
SELECT 
    event_type,
    COUNT(*)
FROM events
GROUP BY event_type
ORDER BY event_type;

-- 5, What is the percentage of visits which have a purchase event?
SELECT
    100 * COUNT(DISTINCT visit_id) / (SELECT COUNT (DISTINCT visit_id) FROM events) AS percent_purchase
FROM events
WHERE 