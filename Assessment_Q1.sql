-- Q1: High-Value Customers with Both Funded Savings and Investment Plans

WITH savings_funded AS (
    SELECT DISTINCT p.owner_id
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.owner_id = p.owner_id
    WHERE p.is_regular_savings = 1
    GROUP BY p.owner_id
    HAVING SUM(s.confirmed_amount) > 0
),
investment_funded AS (
    SELECT DISTINCT p.owner_id
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.owner_id = p.owner_id
    WHERE p.is_a_fund = 1
    GROUP BY p.owner_id
    HAVING SUM(s.confirmed_amount) > 0
),
total_deposits AS (
    SELECT owner_id, SUM(confirmed_amount) / 100.0 AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
)

SELECT 
    u.id AS owner_id,
    u.name,
    (
        SELECT COUNT(*) FROM plans_plan 
        WHERE owner_id = u.id AND is_regular_savings = 1
    ) AS savings_count,
    (
        SELECT COUNT(*) FROM plans_plan 
        WHERE owner_id = u.id AND is_a_fund = 1
    ) AS investment_count,
    COALESCE(t.total_deposits, 0) AS total_deposits
FROM users_customuser u
JOIN savings_funded sf ON sf.owner_id = u.id
JOIN investment_funded inf ON inf.owner_id = u.id
LEFT JOIN total_deposits t ON t.owner_id = u.id
ORDER BY total_deposits DESC;
