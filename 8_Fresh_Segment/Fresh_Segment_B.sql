-- 1,Which interests have been present in all month_year dates in our dataset?
SELECT COUNT(DISTINCT month_year) FROM interest_metrics;

SELECT 
    i2.id,
    i2.interest_name
FROM interest_metrics i1
RIGHT JOIN interest_map i2
ON INT(i1.interest_id) = i2.id
GROUP BY i2.id, i2.interest_name
HAVING COUNT(i1.interest_id) = 14;

SELECT * FROM interest_metrics;
SELECT * FROM interest_map;

-- 2, Using this same total_months measure - 
-- calculate the cumulative percentage of all records starting at 14 months 
-- which total_months value passes the 90% cumulative percentage value?
WITH counted_month AS (
    SELECT
        interest_id,
        COUNT(interest_id) AS total_months,
        ROW_NUMBER() OVER (
            PARTITION BY COUNT(interest_id)
            ORDER BY COUNT(interest_id)
        ) AS ranking
    FROM interest_metrics
    GROUP BY interest_id
    HAVING COUNT(interest_id) > 0
)
SELECT 
    total_months,
    MAX(ranking) AS number_of_interests,
    ROUND(100 * SUM(MAX(ranking)) OVER (
        ORDER BY total_months
    ) / SUM(MAX(ranking)) OVER (), 2) AS cum_top
FROM counted_month
GROUP BY total_months
ORDER BY total_months;

-- 3, If we were to remove all interest_id values which are lower than the total_months value 
-- we found in the previous question - how many total data points would we be removing?
WITH remove_lower AS (
    SELECT
        interest_id
    FROM interest_metrics
    GROUP BY interest_id
    HAVING COUNT(interest_id) < 6
)
SELECT COUNT(interest_id) FROM remove_lower;

-- 4, Does this decision make sense to remove these data points from a business perspective?
-- Use an example where there are all 14 months present to a removed interest example for your arguments 
-- think about what it means to have less months present from a segment perspective.

SELECT 
    im.month_year,
    COUNT(interest_id) AS number_excluded,
    number_included,
    ROUND(100 * COUNT(interest_id) / number_included, 2) AS percent_excluded
FROM interest_metrics im
JOIN (
    SELECT
        month_year,
        COUNT(interest_id) AS number_included
    FROM interest_metrics
    WHERE month_year IS NOT NULL
    AND interest_id IN (
        SELECT
            interest_id
        FROM interest_metrics
        GROUP BY interest_id
        HAVING COUNT(interest_id) > 5
    )
    GROUP BY month_year
) AS i ON i.month_year = im.month_year
WHERE im.month_year IS NOT NULL
AND im.interest_id IN (
    SELECT
        interest_id
    FROM interest_metrics
    GROUP BY interest_id
    HAVING COUNT(interest_id) < 6
)
GROUP BY 1
ORDER BY 1;

-- 5, After removing these interests - how many unique interests are there for each month?
SELECT 
    month_year,
    COUNT(interest_id)
FROM interest_metrics
WHERE month_year IS NOT NULL
AND interest_id IN (
    SELECT
        interest_id
    FROM interest_metrics
    GROUP BY interest_id
    HAVING COUNT(interest_id) > 5
)
GROUP BY 1
ORDER BY 1;