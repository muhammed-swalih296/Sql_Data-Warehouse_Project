/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT 
      MIN(order_date) AS first_order_date,
      MAX(order_date) AS last_order_date,
      DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_date_range_in_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT 
      MAX(birthdate) AS youngest_customer,
      DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age,
      MIN(birthdate) AS oldest_customer,
      DATEDIFF(year,MIN(birthdate), GETDATE()) AS oldest_age
FROM gold.dim_customers;
