/*
===========================================================================
DDL	Script : Create gold views
===========================================================================

Script purpose :
			 This script create the views for the gold layer in 
			 the data warehouse. The gold layer represents the final 
			 fact and dimension tables (Star schema).

			 Each views performs transformation and combines data from
			 silver layer to produce a clean, enriched and business ready 
			 dataset.

Usage :
			These views can be queried directly for analytics and reporting.

=============================================================================
*/

-- ===========================================================
-- Create Dimension : gold.dim_customers
-- ===========================================================


DROP VIEW IF EXISTS gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen,'n/a')
	END  AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON			ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON			ci.cst_key = la.cid

GO

-- ===========================================================
-- Create Dimension : gold.dim_products
-- ===========================================================

DROP VIEW IF EXISTS gold.dim_products
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pd.prd_start_date, pd.prd_key) AS product_key,
	pd.prd_id AS product_id,
	pd.prd_key AS product_number,
	pd.prd_nm AS product_name,
	pd.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pd.prd_cost AS cost,
	pd.prd_line AS product_line,
	pd.prd_start_date AS start_date
FROM silver.crm_prd_info AS pd
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON		  pd.cat_id = pc.id
WHERE pd.prd_end_date IS NULL --Filtering out historic data

GO

-- ===========================================================
-- Create Fact : gold.fact_sales
-- ===========================================================

DROP VIEW IF EXISTS gold.fact_sales
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON		  sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON		  sd.sls_cust_id = cu.customer_id

GO
