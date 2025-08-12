/*
===============================================================
Customer Report 
===============================================================
*/

CREATE SCHEMA gold;
GO

CREATE VIEW gold.report_customers AS 
WITH base_query AS (
 SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, '  ', c.last_name) AS customer_name,
DATEDIFF (year, c.birthdate, GETDATE()) AS age
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL )

, customer_agregation AS (
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT (DISTINCT order_number ) AS Total_orders,
SUM(sales_amount) AS Total_sale,
SUM(quantity) AS Total_quantity,
COUNT (product_key) AS total_products,
MAX (order_date) AS Last_order,
DATEDIFF (Month, MIN(order_date), MAX(order_date) ) AS Lifespan
FROM base_query
GROUP BY 
   customer_key,
   customer_number,
   customer_name,
   age ) 

   SELECT
   customer_key,
   customer_number,
   customer_name,
   age,
   CASE WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 30 THEN '20-30'
		WHEN age BETWEEN 30 AND 40 THEN '30-40'
		WHEN age BETWEEN 40 AND 50 THEN '40-50'
		ELSE '50 and above'
END Age_Group,
    CASE WHEN Lifespan >= 12 AND Total_sale > 5000 THEN 'VIP'
      WHEN Lifespan >= 12 AND Total_sale <= 5000 THEN 'Regular'
	  ELSE 'New'
END Customers_Segmentation,
DATEDIFF (month, Last_order, GETDATE()) AS Recency,
   Total_orders,
   Total_sale,
   Total_quantity,
   total_products,
   Last_order,
   Lifespan,
   -- Compuate average value (AVO)
   CASE WHEN Total_orders = 0 THEN 0
        ELSE total_sale / total_orders 
   END AS vag_order_value,

   --Compuate average monthly spend
   CASE WHEN lifespan = 0 THEN total_sale
        ELSE total_sale / lifespan
	END AS avg_monthly_spend
   FROM customer_agregation
