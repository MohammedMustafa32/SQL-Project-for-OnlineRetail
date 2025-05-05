# **📊 SQL Project for OnlineRetail**

## 📝 Project Overview
Customer has purchasing transaction that we shall be monitoring to get intuition behind each customer behavior to target the customers in the most efficient and proactive way, to increase sales/revenue, improve customer retention and decrease churn.

[Case Study](https://github.com/MohammedMustafa32/SQL-Project-for-OnlineRetail/blob/main/Analytical%20SQL%20Case%20Study.pdf)

## 📁 Dataset
[OnlineRetail](https://github.com/MohammedMustafa32/SQL-Project-for-OnlineRetail/blob/main/Dataset/OnlineRetail.zip)


## 🧹 Data Cleaning
- Removed invalid pricing records: Deleted 2,517 rows where UnitPrice was 0 or NULL.
- Filtered out placeholder stock entries: Removed 63 rows where StockCode = 'S' (e.g., samples or placeholders).
- Eliminated negative quantities: Deleted 9,227 rows with negative Quantity values, often indicating returns or data errors.
- Standardized country names: Updated "Israel" to "Palestine" in 295 rows to ensure consistency.
- Handled missing dates: Used a Python script to forward-fill NULL values in the InvoiceDate column by copying from the previous valid row.


## 🔍 Key Analytical Questions:
- Who are the Top 10 Customers generating the highest revenue ?
- Which are the Top 10 Best-Selling products by quantity sold ?
- How does monthly sales performance contribute to total revenue ?
- What are the Top 3 Selling products every year by Revenue ?
- How is revenue and customer distribution spread across different countries ?


## 📊 Customer Segmentation
- It is required to implement a Monetary model forcustomers behavior for product purchasing and segment each customer based on the below groups :

Champions - Loyal Customers - Potential Loyalists - Recent Customers - Promising - Customers Needing Attention - At Risk - Can't Lose Them - Hibernating - Lost

- The customers will be grouped based on 3 main values
  - Recency => how recent the last transaction (most recent purchase date in the dataset)
  - Frequency => how many times the customer has bought from our store
  - Monetary => how much each customer has paid for our products

- Finaly, Calculate the average scores of the Frequency and Monetary

## Expected Outputs
![image](https://github.com/user-attachments/assets/f1ddc7c3-1e8e-412e-b576-83dc45163d34)




