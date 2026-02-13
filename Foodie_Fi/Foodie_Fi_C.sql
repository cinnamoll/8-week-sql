DROP TABLE IF EXISTS payments;

CREATE TABLE payments (
    customer_id INT,
    plan_id INT,
    plan_name INT,
    payment_date DATE,
    amount DECIMAL(5, 2),
    payment_order INT
);

SELECT
    customer_id,
    plan_id,
    plan_name,
    IF(
        start_date < '2020-12-31' THEN

    ),
    price AS amount
FROM subscriptions_sample
JOIN plans USING (plan_id)
WHERE plan_id != 0;