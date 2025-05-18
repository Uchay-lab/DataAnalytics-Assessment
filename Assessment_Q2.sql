-- Q2: Transaction Frequency Analysis

WITH monthly_txn_counts AS (
    SELECT 
        owner_id,
        DATE_FORMAT(created_on, '%Y-%m-01') AS txn_month,
        COUNT(*) AS monthly_txns
    FROM savings_savingsaccount
    GROUP BY owner_id, DATE_FORMAT(created_on, '%Y-%m-01')
),
avg_txn_per_customer AS (
    SELECT 
        owner_id,
        AVG(monthly_txns) AS avg_transactions_per_month
    FROM monthly_txn_counts
    GROUP BY owner_id
),
frequency_buckets AS (
    SELECT 
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        COUNT(*) AS customer_count,
        ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
    FROM avg_txn_per_customer
    GROUP BY frequency_category
)

SELECT * FROM frequency_buckets
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
