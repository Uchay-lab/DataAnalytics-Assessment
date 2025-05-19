**Q1: High-Value Customers with Both Funded Savings and Investment Plans**

Objective: To identify customers who have at least one funded savings plan and one funded investment plan. 
The result should also include total deposits and be sorted in descending order of deposits.

**My Approach:**

A "funded" plan was interpreted as one associated with non-zero deposits in the savings_savingsaccount table.

I created two CTEs:

savings_funded: Customers with is_regular_savings = 1 and confirmed deposits.

investment_funded: Customers with is_a_fund = 1 and confirmed deposits.

I then joined these CTEs to identify users who meet both criteria.

Total deposits were calculated by summing confirmed_amount, converted from kobo to naira (divided by 100).

Finally, I used subqueries to count the number of savings and investment plans per user that met the criteria.

**Challenge:**

Determining what qualifies a plan as "funded" required interpreting the available fields.





**Q2: Transaction Frequency Analysis**

Objective: To segment customers by how often they transact per month.

**My Approach:**

First, I calculated the number of transactions per user per month using DATE_FORMAT.

Then, I averaged the monthly transaction counts per user to get a true monthly average.

I used a CASE statement to divide users into the 3 buckets below:

High Frequency (≥10 txns/month)

Medium Frequency (3–9)

Low Frequency (≤2)

Finally, I aggregated the number of customers and average monthly transactions in each category.

**Challenge:**

Ensuring monthly average was representative (not skewed by inactive months), so I only included months with actual activity.





**Q3: Account Inactivity Alert**

Objective: To identify active savings or investment accounts with no inflow transactions in the last 365 days.

**My Approach:**

I first extracted the latest inflow transaction date per user from the savings_savingsaccount table using MAX(created_on), grouped by owner_id.

Next, I pulled all plan details from plans_plan, identifying whether each plan is a Savings or Investment using flags is_regular_savings and is_a_fund.

Then, I joined the plan data with the last known savings transaction date using LEFT JOIN on owner_id to capture users even if they had no transactions.

Finally, I calculated inactivity in days using DATEDIFF() and filtered for accounts with more than 365 days of inactivity.

**Challenge:**

My initial approach using union join made my query run for so long it caused connection timeouts.

I fixed it by summarizing transaction data before joining to reduce complexity and improve performance.





**Q4: Customer Lifetime Value (CLV) Estimation**

Objective: To estimate CLV using account tenure and average profit per transaction (0.1% of transaction value).

**My Approach:**

I first calculated the total number of transactions and the sum of confirmed transaction values (converted from kobo to naira) for each customer.

I computed tenure in months by calculating the difference between CURRENT_DATE and the date_joined field.

I then calculated the average profit per transaction and applied the CLV formula:

CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
Customers with tenure_months = 0 were excluded to avoid division errors.

Results were sorted by highest CLV to identify most valuable customers.

**Challenge:**

Dealing with data in kobo required converting to naira for realistic CLV.


