-- Q3: Account Inactivity Alert

WITH last_savings_txn AS (
    SELECT 
        owner_id,
        MAX(created_on) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY owner_id
),
plan_info AS (
    SELECT 
        id AS plan_id,
        owner_id,
        CASE 
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type
    FROM plans_plan
),
inactivity AS (
    SELECT 
        p.plan_id,
        p.owner_id,
        p.type,
        lst.last_transaction_date,
        DATEDIFF(CURRENT_DATE, lst.last_transaction_date) AS inactivity_days
    FROM plan_info p
    LEFT JOIN last_savings_txn lst ON p.owner_id = lst.owner_id
)

SELECT *
FROM inactivity
WHERE inactivity_days > 365
ORDER BY inactivity_days DESC;
