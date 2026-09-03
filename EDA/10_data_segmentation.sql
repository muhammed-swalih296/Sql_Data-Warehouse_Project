/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Segment products into cost range and  count how many product fall into each segment

WITH product_segment AS(
SELECT
  	product_name,
  	cost,
  	CASE	
  		WHEN cost < 100 THEN 'Below 100'
  		WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
  		WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
  		ELSE 'Above 1000'
  	END cost_range
FROM gold.dim_products
)

SELECT
  	cost_range,
  	COUNT(product_name) AS no_of_products
FROM product_segment
GROUP BY cost_range
ORDER BY no_of_products DESC;


/* Group customers into three groups based on thrie spending behaviours :
		- VIP : Customer with atleast 12 months of history and spending more than €5,000.
		- Regular : Customer with atleast 12 months of history but spending €5,000 or less.
		- New : Customer with a lifespan of less than 12 months
   And find the total number of customer by each group.
*/

WITH cust_history AS(
SELECT
  	c.customer_key,
  	MIN(f.order_date) AS first_order_date,
  	MAX(f.order_date) AS last_order_date,
  	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS cust_lifespan,
  	SUM(f.sales_amount) AS total_spending
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
),

cust_segment AS(
SELECT
  	customer_key,
  	CASE
  		WHEN cust_lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
  		WHEN cust_lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
  		ELSE 'New'
  	END cust_group
FROM cust_history
)

SELECT 
  	cust_group,
  	COUNT(customer_key) AS no_of_cust
FROM cust_segment
GROUP BY cust_group
ORDER BY no_of_cust DESC;
