# The Foodie-Fi team wants you to create a new payments table for the year 2020
# that includes amounts paid by each customer in the subscriptions table with the following requirements:
#
# - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
# - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
# - upgrades from pro monthly to pro annual are paid at the end of the current billing period
#   and also starts at the end of the month period
# - once a customer churns they will no longer make payments


DROP TABLE IF EXISTS payments;

CREATE TEMPORARY TABLE payments AS
WITH RECURSIVE date_series AS (
    SELECT
        s.customer_id,
        s.plan_id,
        p.plan_name,
        s.start_date,
        p.price AS amount,
        s.start_date AS payment_date,
        CASE
            WHEN s.plan_id = 3 THEN s.start_date -- end = start do chi xet 2020
            WHEN s.plan_id = 4 THEN NULL
            ELSE (
                SELECT MIN(s2.start_date)
                FROM subscriptions s2
                WHERE s2.customer_id = s.customer_id
                AND s2.start_date > s.start_date
            )
        END AS end_date
    FROM subscriptions s
    JOIN plans p
    ON p.plan_id = s.plan_id
    WHERE s.plan_id != 0
    AND s.start_date >= '2020-01-01'

UNION ALL # de quy
    SELECT
        ds.customer_id,
        ds.plan_id,
        ds.plan_name,
        ds.start_date,
        ds.amount,
        DATE_ADD(ds.payment_date, INTERVAL 1 MONTH) AS payment_date,
        ds.end_date
    FROM date_series ds #update payment date theo tung thang
    WHERE DATE_ADD(ds.payment_date, INTERVAL 1 MONTH) <= IFNULL(ds.end_date, '2020-12-31')
        AND DATE_ADD(ds.payment_date, INTERVAL 1 MONTH) < '2021-01-01'
        AND ds.plan_id NOT IN (3, 4)
),

ranked AS (
    SELECT
        customer_id,
        plan_id,
        plan_name,
        payment_date,
        amount,
        LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY plan_id) AS prev_plan,
        LAG(amount) OVER (PARTITION BY customer_id ORDER BY plan_id) AS prev_amount,
        LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY plan_id) AS prev_pay
    FROM date_series
)
SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    CASE
        WHEN prev_plan IS NOT NULL
        AND prev_plan != plan_id
        AND DATEDIFF(payment_date, prev_pay) < 30
    THEN amount - prev_amount
    ELSE amount
    END AS amount,
    RANK() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM ranked
ORDER BY customer_id;

SELECT * FROM payments;