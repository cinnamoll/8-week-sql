-- 1, Update the fresh_segments.interest_metrics table by 
-- modifying the month_year column to be a date data type with the start of the month

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year VARCHAR(10);

UPDATE interest_metrics
SET month_year = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y');

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year DATE;

