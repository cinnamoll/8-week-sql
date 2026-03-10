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

-- 6, What is the percentage of sales for Retail vs Shopify for each month?
WITH monthly_trans AS (
    SELECT
        calendar_year,
        month_number,
        platform,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    GROUP BY calendar_year, month_number, platform
)
SELECT
    calendar_year,
    month_number,
    ROUND(100 * MAX(CASE 
        WHEN platform = 'Retail' THEN total_sales 
        ELSE 0 END
    ) / SUM(total_sales), 2) AS retail_percent,
    ROUND(100 * MAX(CASE 
        WHEN platform = 'Shopify' THEN total_sales 
        ELSE 0 END
    ) / SUM(total_sales), 2) AS shopify_percent
FROM monthly_trans
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;

-- 7, What is the percentage of sales by demographic for each year in the dataset?
WITH monthly_trans AS (
    SELECT 
        calendar_year,
        demographic,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
)
SELECT
    calendar_year,
    ROUND(100 * MIN(CASE
        WHEN demographic = 'Couples' THEN total_sales
        ELSE 0 END
    ) / SUM(total_sales), 2) AS couple_percent,
    ROUND(100 * MIN(CASE
        WHEN demographic = 'Families' THEN total_sales
        ELSE 0 END
    ) / SUM(total_sales), 2) AS famililes_percent,
    ROUND(100 * MIN(CASE
        WHEN demographic = 'unknown' THEN total_sales
        ELSE 0 END
    ) / SUM(total_sales), 2) AS unknown_percent
FROM monthly_trans
GROUP BY calendar_year
ORDER BY calendar_year;

-- 8, Which age_band and demographic values contribute the most to Retail sales?
SELECT
    age_band,
    demographic,
    SUM(sales) AS retail_sales,
    ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (), 1) AS contribute_percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY contribute_percent DESC;

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?
SELECT
    calendar_year,
    platform,
    SUM(sales) / SUM(transactions) AS avg_trans_size
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;