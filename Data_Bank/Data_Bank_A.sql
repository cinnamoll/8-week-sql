# 1, How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id)
FROM customer_nodes;

-- 2, What is the number of nodes per region?
SELECT
    region_id,
    COUNT(DISTINCT node_id)
FROM customer_nodes
GROUP BY region_id;

-- 3, How many customers are allocated to each region?
SELECT
    region_name,
    COUNT(DISTINCT customer_id)
FROM customer_nodes
JOIN regions USING(region_id)
GROUP BY region_name;

-- 4, How many days on average are customers reallocated to a different node?
WITH
    node_days AS (
        SELECT
            customer_id,
            region_id,
            node_id,
            DATEDIFF(end_date, start_date) AS days
        FROM customer_nodes
        WHERE end_date != '9999-12-31'
        GROUP BY customer_id, region_id, node_id, end_date, start_date
    ),
    total_days AS (
        SELECT
            customer_id,
            region_id,
            node_id,
            SUM(days) AS total
        FROM node_days
        GROUP BY customer_id, region_id, node_id
    )
SELECT ROUND(AVG(total)) FROM total_days;

-- 5, What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
