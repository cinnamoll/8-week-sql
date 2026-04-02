-- filtered dataset by removing the interests with less than 6 months worth of data,
WITH FrequentInterests AS (
    SELECT interest_id
    FROM interest_metrics
    GROUP BY interest_id
    HAVING COUNT(interest_id) < 6
)
DELETE FROM interest_metrics
WHERE interest_id IN (SELECT interest_id FROM FrequentInterests);

-- 1, Which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
-- Only use the maximum composition value for each interest but you must keep the corresponding month_year

WITH get_max_month_year AS (
    SELECT
        im.month_year,
        m.interest_name,
        im.composition,
        ROW_NUMBER() OVER (
            PARTITION BY m.interest_name
            ORDER BY im.composition DESC
        ) AS max_ranking
    FROM interest_metrics im
    JOIN interest_map m ON m.id = im.interest_id
    WHERE im.month_year IS NOT NULL
)
SELECT
    month_year,
    interest_name,
    composition
FROM get_max_month_year
WHERE max_ranking = 1
GROUP BY 1,2,3
ORDER BY composition DESC
LIMIT 10;

WITH get_min_month_year AS (
    SELECT
        im.month_year,
        m.interest_name,
        im.composition,
        ROW_NUMBER() OVER (
            PARTITION BY m.interest_name
            ORDER BY im.composition ASC
        ) AS min_ranking
    FROM interest_metrics im
    JOIN interest_map m ON m.id = im.interest_id
    WHERE im.month_year IS NOT NULL
)
SELECT
    month_year,
    interest_name,
    composition
FROM get_min_month_year
WHERE min_ranking = 1
GROUP BY 1,2,3
ORDER BY composition ASC
LIMIT 10;

-- 2, Which 5 interests had the lowest average ranking value?
WITH avg_rank AS (
    SELECT 
        m.interest_name,
        AVG(im.ranking) AS avg_ranking,
        ROW_NUMBER() OVER (
            ORDER BY AVG(im.ranking) DESC
        ) AS ranking_
    FROM interest_metrics im
    JOIN interest_map m 
    ON m.id = im.interest_id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1
)
SELECT
    interest_name,
    avg_ranking
FROM avg_rank
WHERE ranking_ BETWEEN 1 AND 5
GROUP BY 1,2;

-- 3, Which 5 interests had the largest standard deviation in their percentile_ranking value?
WITH std_percentile AS (
    SELECT
        m.interest_name,
        STD(im.percentile_ranking) AS std_per,
        ROW_NUMBER() OVER (
            ORDER BY STD(im.percentile_ranking) DESC
        ) AS std_ranking
    FROM interest_metrics im
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1
    HAVING std_per IS NOT NULL
)
SELECT
    interest_name,
    ROUND(std_per, 2)
FROM std_percentile
WHERE std_ranking BETWEEN 1 AND 5

-- 4, For the 5 interests found in the previous question 
-- what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
-- Can you describe what is happening for these 5 interests?
WITH std_percentile AS (
    SELECT
        im.interest_id,
        m.interest_name,
        ROUND(STD(im.percentile_ranking),2) AS std_per,
        ROW_NUMBER() OVER (
            ORDER BY STD(im.percentile_ranking) DESC
        ) AS std_ranking
    FROM interest_metrics im
    JOIN interest_map m
    ON im.interest_id = m.id
    WHERE im.month_year IS NOT NULL
    GROUP BY 1,2
), top5 AS (
    SELECT interest_id
    FROM std_percentile
    WHERE std_ranking BETWEEN 1 AND 5
), get_ranking AS (
    SELECT 
        im.month_year,
        m.id,
        m.interest_name,
        im.percentile_ranking,
        ROW_NUMBER() OVER(
            PARTITION BY m.id
            ORDER BY im.percentile_ranking DESC
        ) AS rank_max,
        ROW_NUMBER() OVER(
            PARTITION BY m.id
            ORDER BY im.percentile_ranking   
        ) AS rank_min
    FROM interest_metrics im
    JOIN interest_map m
    ON m.id = im.interest_id
    WHERE im.month_year IS NOT NULL 
    AND m.id IN (SELECT * FROM top5)
)
SELECT 
    month_year,
    id,
    interest_name,
    percentile_ranking
FROM get_ranking
WHERE rank_max = 1 OR rank_min = 1
GROUP BY 1,2,3,4
ORDER BY interest_name, percentile_ranking DESC

