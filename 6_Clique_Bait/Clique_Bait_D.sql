DROP TABLE campaign_analysis;
CREATE TABLE IF NOT EXISTS campaign_analysis (
    userr_id INT,
    visitt_id VARCHAR(10),
    visit_start_time INT,
    page_views INT,
    cart_adds INT,
    purchase BOOLEAN,
    campaign_name VARCHAR(50),
    impression INT,
    click INT,
    cart_products VARCHAR(100)
);

INSERT INTO campaign_analysis (
    userr_id, visitt_id, visit_start_time, page_views, cart_adds, purchase, 
    campaign_name, impression, click, cart_products
)
SELECT userr_id, visitt_id, visit_start_time, page_views, cart_adds, purchase, 
    campaign_name, impression, click, cart_products
FROM (
    SELECT 
        u.user_id AS userr_id,
        e.visit_id AS visitt_id,
        MIN(e.event_time) AS visit_start_time,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
        SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchase,
        c.campaign_name AS campaign_name,
        SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression,
        SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click,
        GROUP_CONCAT(
            CASE WHEN p.product_id IS NOT NULL AND e.event_type = 2
            THEN p.page_name
            ELSE NULL END
            ORDER BY e.sequence_number
            SEPARATOR ','
        ) AS cart_products
    FROM users u
    INNER JOIN events e
        ON e.cookie_id = u.cookie_id
    LEFT JOIN campaign_identifier c 
        ON e.event_time BETWEEN c.start_date AND c.end_date
    LEFT JOIN clique_bait.page_hierarchy AS p
        ON e.page_id = p.page_id
    GROUP BY u.user_id, e.visit_id, c.campaign_name
) AS campaign_metric;
