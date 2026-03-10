USE data_mart;

SELECT * FROM clean_weekly_sales;

-- 1, What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?
SELECT DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '20/06/15'
AND calendar_year = '2020';

WITH packaging_sales AS (
    SELECT
        week_number,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE (week_number BETWEEN 21 AND 28)
    AND calendar_year = 2020
    GROUP BY week_number
),
before_after_changes AS (
    SELECT
        SUM(
            CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales
            ELSE 0 END
        ) AS before_sales,
        SUM(
            CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales
            ELSE 0 END
        ) AS after_sales
    FROM packaging_sales
)
SELECT 
    after_sales - before_sales AS sales_std,
    ROUND(100 * (after_sales - before_sales) / before_sales, 2) AS percent_std
FROM before_after_changes;

-- 2, What about the entire 12 weeks before and after?
WITH packaging_sales AS (
    SELECT
        week_number,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE week_number BETWEEN 13 AND 36
    AND calendar_year = '2020'
    GROUP BY week_number
), before_after_changes AS (
    SELECT
        SUM(
            CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales
            ELSE 0 END
        ) AS before_sales,
        SUM(
            CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales
            ELSE 0 END
        ) AS after_sales
    FROM packaging_sales
)
SELECT
    after_sales - before_sales AS sale_var,
    ROUND((after_sales - before_sales) / before_sales, 2) AS percent_var
FROM before_after_changes;

-- 3, How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH packaging_sales AS (
    SELECT
        calendar_year,
        week_number,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE week_number BETWEEN 21 AND 28
    GROUP BY calendar_year, week_number
), before_after_changes AS (
    SELECT
        calendar_year,
        SUM(
            CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales
            ELSE 0 END
        ) AS before_sales,
        SUM(
            CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales
            ELSE 0 END
        ) AS after_sales
    FROM packaging_sales
    GROUP BY calendar_year
)
SELECT
    calendar_year,
    after_sales - before_sales AS sale_var,
    ROUND((after_sales - before_sales) / before_sales, 2) AS percent_var
FROM before_after_changes;

WITH packaging_sales AS (
    SELECT
        calendar_year,
        week_number,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE week_number BETWEEN 13 AND 36
    GROUP BY calendar_year, week_number
), before_after_changes AS (
    SELECT
        calendar_year,
        SUM(
            CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales
            ELSE 0 END
        ) AS before_sales,
        SUM(
            CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales
            ELSE 0 END
        ) AS after_sales
    FROM packaging_sales
    GROUP BY calendar_year
)
SELECT
    calendar_year,
    after_sales - before_sales AS sale_var,
    ROUND((after_sales - before_sales) / before_sales, 2) AS percent_var
FROM before_after_changes;