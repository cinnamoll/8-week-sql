CREATE TABLE IF NOT EXISTS product_analysis (
    page_id INT,
    page_name VARCHAR(20),
    total_view INT,
    total_add INT,
    total_not_purchase INT,
    total_purchase INT
);

INSERT INTO product_analysis (
    page_id, page_name, total_view, total_add, total_not_purchase, total_purchase
)
SELECT
    page_id,
    page_name,
    total_view,
    total_add,
    (total_add - total_purchase) AS total_not_purchase,
    total_purchase
FROM (
    SELECT
        p.page_id,
        p.page_name,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS total_view,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS total_add,
        SUM(CASE WHEN e.event_type = 2 AND e.visit_id IN (
            SELECT visit_id FROM events WHERE event_type = 3
        ) THEN 1 ELSE 0 END) AS total_purchase
    FROM events e
    JOIN page_hierarchy p 
      ON p.page_id = e.page_id
    WHERE p.product_id IS NOT NULL
    GROUP BY p.page_id, p.page_name
) AS product_metric;

SELECT * FROM product_analysis;

DROP TABLE category_analysis;
CREATE TABLE IF NOT EXISTS category_analysis (
    category_name VARCHAR(20),
    total_view INT,
    total_add INT,
    total_not_purchase INT,
    total_purchase INT
);

INSERT INTO category_analysis (
    category_name, total_view, total_add, total_not_purchase, total_purchase
)
SELECT
    category_name,
    total_view,
    total_add,
    (total_add - total_purchase) AS total_not_purchase,
    total_purchase
FROM (
    SELECT
        p.product_category AS category_name, 
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS total_view,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS total_add,
        SUM(CASE WHEN e.event_type = 2 AND e.visit_id IN (
            SELECT visit_id FROM events WHERE event_type = 3
        ) THEN 1 ELSE 0 END) AS total_purchase
    FROM events e
    JOIN page_hierarchy p 
      ON p.page_id = e.page_id
    WHERE p.product_category IS NOT NULL
    GROUP BY 1
) AS category_metric;

SELECT * FROM category_analysis;