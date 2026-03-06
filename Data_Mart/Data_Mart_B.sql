USE data_mart;
SELECT * FROM clean_weekly_sales;

-- 1, What day of the week is used for each week_date value?
SELECT DISTINCT DAYNAME(week_date) AS week_day
FROM clean_weekly_sales;

-- 2, What range of week numbers are missing from the dataset?
WITH RECURSIVE weekCnt AS (
   SELECT 1 AS n
   UNION ALL
   SELECT n + 1 FROM weekCnt WHERE n < 52  
)
SELECT w.n
FROM weekCnt w
LEFT JOIN clean_weekly_sales c
ON w.n = c.week_number
WHERE c.week_number IS NULL;

-- 3, How many total transactions were there for each year in the dataset?
SELECT 
    calendar_year,
    SUM(transactions) AS total_trans
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- 4, What is the total sales for each region for each month?
SELECT
    month_number,
    region,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY month_number, region
ORDER BY month_number, region;

-- 5, What is the total count of transactions for each platform
SELECT 
    platform,
    SUM(transactions) AS total_trans
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;