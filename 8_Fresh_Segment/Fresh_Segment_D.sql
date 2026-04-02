-- 1, What is the top 10 interests by the average composition for each month?
WITH top_avg_comp AS (
    SELECT 
        im.month_year,
        m.interest_name,
        im.composition / im.index_value AS avg_comp,
        ROW_NUMBER() OVER (
            PARTITION BY im.month_year
            ORDER BY im.composition / im.index_value DESC
        ) AS rank_avg
    FROM interest_metrics im 
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1,2,3
)
SELECT 
    month_year,
    interest_name,
    ROUND(avg_comp, 2)
FROM top_avg_comp
WHERE rank_avg BETWEEN 1 AND 10
GROUP BY 1,2,3
ORDER BY 1 ASC

-- 2, For all of these top 10 interests - which interest appears the most often?
WITH top_avg_comp AS (
    SELECT 
        im.month_year,
        m.interest_name,
        im.composition / im.index_value AS avg_comp,
        ROW_NUMBER() OVER (
            PARTITION BY im.month_year
            ORDER BY im.composition / im.index_value DESC
        ) AS rank_avg
    FROM interest_metrics im 
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1,2,3
), top_10 AS (
    SELECT 
        interest_name,
        avg_comp
    FROM top_avg_comp
    WHERE rank_avg BETWEEN 1 AND 10
)
SELECT
    interest_name,
    COUNT(interest_name) AS freq
FROM top_10
GROUP BY 1
ORDER BY freq DESC

-- 3, What is the average of the average composition for the top 10 interests for each month?
WITH top_avg_comp AS (
    SELECT 
        im.month_year,
        m.interest_name,
        im.composition / im.index_value AS avg_comp,
        ROW_NUMBER() OVER (
            PARTITION BY im.month_year
            ORDER BY im.composition / im.index_value DESC
        ) AS rank_avg
    FROM interest_metrics im 
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1,2,3
), top_10 AS (
    SELECT 
        month_year,
        interest_name,
        avg_comp
    FROM top_avg_comp
    WHERE rank_avg BETWEEN 1 AND 10
)
SELECT
    month_year,
    ROUND(AVG(avg_comp),2)
FROM top_10
GROUP BY 1
ORDER BY 1 

-- 4, What is the 3 month rolling average of the max average composition value from September 2018 to August 2019
-- and include the previous top ranking interests in the same output shown below.
WITH get_max_index AS (
    SELECT 
        im.month_year,
        m.interest_name,
        ROUND(im.composition / im.index_value, 2) AS max_index_composition,
        ROW_NUMBER() OVER(
            PARTITION BY im.month_year
            ORDER BY im.composition / im.index_value DESC
        ) AS ranking
    FROM interest_metrics im
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
),
final AS (
    SELECT 
        month_year,
        interest_name,
        max_index_composition,
        ROUND(AVG(max_index_composition) OVER (
            PARTITION BY interest_name
            ORDER BY month_year
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),2) AS 3_month_moving_avg,
        CONCAT(LAG(interest_name,1) OVER (ORDER BY month_year), ": ",
               LAG(max_index_composition,1) OVER (ORDER BY month_year)) AS 1_month_ago,
        CONCAT(LAG(interest_name,2) OVER (ORDER BY month_year), ": ",
               LAG(max_index_composition,2) OVER (ORDER BY month_year)) AS 2_month_ago
    FROM get_max_index
    WHERE ranking = 1
    AND month_year BETWEEN "2018-07-01" AND "2019-08-01"
)
SELECT *
FROM final
WHERE 1_month_ago IS NOT NULL
AND 2_month_ago IS NOT NULL
ORDER BY month_year;