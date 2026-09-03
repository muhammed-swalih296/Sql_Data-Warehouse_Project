/*
=================================================================================
Customer Report
=================================================================================

Purpose : 
		- This report consolidates key customer metrics and behaviours.

Highlights :
		1. Gathers essential fields such as names, ages and transction details.
		2. Segments customers into catagories (VIP, Regular, New) and age groups.
		3. Aggregates customer - level metrics :
			- Total orders
			- Total sales
			- Total quantity purchased
			- Total products
			- Lifespan (in months)
		4. Calculate valuable KPI's :
			- Recency (Months since last order)
			- Average order value
			- Average monthly spend

=================================================================================
*/


WITH base_query AS(
/*
---------------------------------------------------------------------------------
1.) Base Query : Retrieve core columns from the tables
---------------------------------------------------------------------------------
*/
SELECT
  	f.order_number,
  	f.product_key,
  	f.order_date,
  	f.sales_amount,
  	f.quantity,
  	c.customer_key,
  	c.customer_number,
  	CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
  	DATEDIFF(YEAR,c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL -- Only consider valid order dates
),

customer_aggregation AS(
/*
---------------------------------------------------------------------------------
2.) Customer Aggregation : Summarise key metrics at customer level
---------------------------------------------------------------------------------
*/
SELECT
  	customer_key,
  	customer_number,
  	customer_name,
  	age,
  	COUNT(DISTINCT order_number) AS total_orders,
  	COUNT(DISTINCT product_key) AS total_products,
  	SUM(sales_amount) AS total_sales,
  	SUM(quantity) AS total_quantity,
  	MIN(order_date) AS first_order_date,
  	MAX(order_date) AS last_order_date,
  	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)

/*
---------------------------------------------------------------------------------
3.) Final Query : Combine all customer result into one output
---------------------------------------------------------------------------------
*/

SELECT
  	customer_key,
  	customer_number,
  	customer_name,
  	age,
  	CASE
  		WHEN age < 20 THEN 'Under 20'
  		WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
  		WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
  		WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
  		ELSE '50 and above'
  	END age_group,
  	CASE
  		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
  		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
  		ELSE 'New'
  	END cust_group,
  	first_order_date,
  	last_order_date,
  	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
  	total_orders,
  	total_products,
  	total_sales,
  	total_quantity,
  	lifespan,
  	-- Computing average order value (AOV)
  	CASE
  		WHEN total_orders = 0 THEN 0
  		ELSE total_sales / total_orders 
  	END avg_order_value,
  	-- Computing average monthly spend
  	CASE 
  		WHEN lifespan = 0 THEN total_sales
  		ELSE total_sales / lifespan
  	END avg_monthly_spend
FROM customer_aggregation;
