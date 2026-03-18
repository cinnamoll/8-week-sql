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
WHERE event_type = 3;

-- 6, What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH checkout_purchase AS (
    SELECT 
        visit_id,
        MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
        MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
    FROM events
    GROUP BY visit_id
)
SELECT 
    ROUND(100 * (1 - (SUM(purchase) / SUM(checkout))), 2)
FROM checkout_purchase;

-- 7, What are the top 3 pages by number of views?
SELECT 
    page_id,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS total_view
FROM events
GROUP BY page_id
ORDER BY total_view DESC
LIMIT 3;

-- 8, What is the number of views and cart adds for each product category?
SELECT
    page_id,
    SUM(CASE WHEN event_type = 1 THEN 1 END) AS total_view,
    SUM(CASE WHEN event_type = 2 THEN 1 END) AS total_add
FROM events
WHERE page_id BETWEEN 3 AND 11
GROUP BY page_id
ORDER BY page_id;

-- 9, What are the top 3 products by purchases?
SELECT 
    p.page_name,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE END) AS total_purchase
FROM events e
LEFT JOIN page_hierarchy p 
ON e.page_id = p.page_id
WHERE e.visit_id IN (
    SELECT visit_id
    FROM events
    WHERE event_type = 3
)
AND p.product_id IS NOT NULL
GROUP BY 1
ORDER BY total_purchase DESC
LIMIT 3;