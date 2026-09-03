/*
=================================================================================
Product Report
=================================================================================

Purpose : 
		- This report consolidates key product metrics and behaviours.

Highlights :
		1. Gathers essential fields such as product names, catagory, subcatagory and cost.
		2. Segments product by revenue to identify High performers, Mid range or Low performeres.
		3. Aggregates product - level metrics :
			- Total orders
			- Total sales
			- Total quantity sold
			- Total customers (unique)
			- Lifespan (in months)
		4. Calculate valuable KPI's :
			- Recency (Months since last sale)
			- Average order revenue
			- Average monthly revenue

=================================================================================
*/

DROP VIEW IF EXISTS gold.report_products 
GO

WITH base_query AS(
/*
---------------------------------------------------------------------------------
1.) Base Query : Retrieve core columns from the tables
---------------------------------------------------------------------------------
*/
SELECT
  	f.order_number,
  	f.customer_key,
  	f.order_date,
  	f.sales_amount,
  	f.quantity,
  	p.product_key,
  	p.product_id,
  	p.product_number,
  	p.product_name,
  	p.category,
  	p.subcategory,
  	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL -- Only consider valid order dates
),

product_aggregation AS(
/*
---------------------------------------------------------------------------------
2.) Product Aggregation : Summarise key metrics at product level
---------------------------------------------------------------------------------
*/
SELECT 
  	product_key,
  	product_id,
  	product_number,
  	product_name,
  	category,
  	subcategory,
  	cost,
  	COUNT(DISTINCT order_number) AS total_orders,
  	SUM(sales_amount) AS total_sales,
  	SUM(quantity) AS total_quantity,
  	COUNT(DISTINCT customer_key) AS total_customers,
  	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF (quantity,0)),2) AS avg_selling_price,
  	MIN(order_date) AS first_order_date,
  	MAX(order_date) AS last_order_date,
  	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	product_key,
	product_id,
	product_number,
	product_name,
	category,
	subcategory,
	cost
)

/*
---------------------------------------------------------------------------------
3.) Final Query : Combine all product result into one output
---------------------------------------------------------------------------------
*/

SELECT
  	product_key,
  	product_id,
  	product_number,
  	product_name,
  	category,
  	subcategory,
  	cost,
  	first_order_date,
  	last_order_date,
  	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
  	CASE
  		WHEN total_sales > 50000 THEN 'High performers'
  		WHEN total_sales >= 10000 THEN 'Mid range'
  		ELSE 'Low performers'
  	END product_group,
  	total_orders,
  	total_sales,
  	total_quantity,
  	total_customers,
  	avg_selling_price,
  	lifespan,
  	-- Computing Average Order Revenue
  	CASE
  		WHEN total_orders = 0 THEN 0
  		ELSE total_sales / total_orders 
  	END avg_order_revenue,
  	-- Computing Average Monthly Revenue
  	CASE 
  		WHEN lifespan = 0 THEN total_sales
  		ELSE total_sales / lifespan
  	END avg_monthly_revenue
FROM product_aggregation;
