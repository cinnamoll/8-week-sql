USE data_mart;

DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TABLE IF NOT EXISTS clean_weekly_sales AS (
    SELECT 
        DATE_FORMAT(week_date, '%d/%m/%y') AS week_date,
        WEEKOFYEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
        MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
        YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
        region,
        platform,
        CASE 
            WHEN segment != 'null' THEN segment
            ELSE 'unknown'
        END AS segment,
        CASE 
            WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
            WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
            WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'retirees'
            ELSE 'unknown'
        END AS age_band,
        CASE 
            WHEN LEFT(segment, 1) = 'C' THEN 'Couples'  
            WHEN LEFT(segment, 1) = 'F' THEN 'Families'
            ELSE 'unknown'
        END AS demographic,
        transactions,
        sales,
        ROUND(CAST(sales AS DECIMAL(15, 4)) / transactions, 2) AS avg_transactions
    FROM weekly_sales
);

SELECT * FROM clean_weekly_sales;