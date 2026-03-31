-- 1, Update the fresh_segments.interest_metrics table by 
-- modifying the month_year column to be a date data type with the start of the month

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year VARCHAR(10);

UPDATE interest_metrics
SET month_year = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y');

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year DATE;

-- 2, What is count of records in the fresh_segments.interest_metrics 
-- for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT
    month_year,
    COUNT(*) AS records
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;

-- 3, What do you think we should do with these null values in the fresh_segments.interest_metrics
-- drop due to not having interest_id

-- 4, How many interest_id values exist in the fresh_segments.interest_metrics table 
-- but not in the fresh_segments.interest_map table? What about the other way around?
SELECT 
    COUNT(DISTINCT inter.interest_id)
FROM interest_metrics inter
WHERE inter.interest_id IS NOT NULL
AND inter.interest_id NOT IN (SELECT id FROM interest_map);

-- 5, Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT 
    COUNT(DISTINCT id) 
FROM interest_map;

-- 6, What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined output 
-- and include all columns from fresh_segments.interest_metrics 
-- and all columns from fresh_segments.interest_map except from the id column.

-- interest_metrics LEFT JOIN interest_map
SELECT * 
FROM interest_metrics i1
RIGHT JOIN interest_map i2 
ON i1.interest_id = i2.id
WHERE i1.interest_id = '21246';

-- 7,Are there any records in your joined table where the month_year value is before the 
-- created_at value from the fresh_segments.interest_map table? 
-- Do you think these values are valid and why?
SELECT * 
FROM interest_metrics i1
RIGHT JOIN interest_map i2 
ON i1.interest_id = i2.id
WHERE i1.month_year < i2.created_at;