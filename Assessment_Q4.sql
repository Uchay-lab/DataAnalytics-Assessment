-- Q4: Customer Lifetime Value (CLV) Estimation

WITH transaction_summary AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) / 100.0 AS total_transaction_value_naira
    FROM savings_savingsaccount s
    WHERE confirmed_amount > 0
    GROUP BY s.owner_id
),
tenure_calc AS (
    SELECT 
        id AS customer_id,
        name,
        TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months
    FROM users_customuser
),
clv_calc AS (
    SELECT 
        t.customer_id,
        t.name,
        t.tenure_months,
        ts.total_transactions,
        ROUND(((ts.total_transaction_value_naira / ts.total_transactions) * 0.001) * (ts.total_transactions / t.tenure_months) * 12, 2) AS estimated_clv
    FROM tenure_calc t
    JOIN transaction_summary ts ON t.customer_id = ts.owner_id
    WHERE t.tenure_months > 0
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;
