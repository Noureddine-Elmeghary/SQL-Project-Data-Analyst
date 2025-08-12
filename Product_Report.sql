/*
=========================================
Product Report
=========================================
*/ 



WITH Base_Query AS (
SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM [gold.fact_sales] AS f
LEFT JOIN [gold.dim_products] AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL 
),

product_aggregation AS (
SELECT
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF (month, MIN (order_date), MAX(order_date)) AS lifespan,
MAX (order_date) AS Last_Sale_Date,
COUNT(DISTINCT order_number) AS Total_Orders,
COUNT (DISTINCT customer_key) AS Total_Customers,
SUM (sales_amount) AS Total_Sales,
SUM (quantity) AS Total_Quantity,
ROUND (AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),1) AS avg_selling_price
FROM Base_Query 

GROUP BY 
   product_key,
   product_name,
   category,
   subcategory,
   cost
)

SELECT 
   product_key,
   product_name,
   category,
   subcategory,
   cost,
   Last_Sale_Date,
   DATEDIFF (month, Last_Sale_Date, GETDATE()) AS recency_in_months,
CASE
       WHEN Total_Sales > 50000 THEN 'High_Performance'
	   WHEN Total_Sales >= 10000 THEN 'Min_Range'
	   ELSE 'Low_Performance'
END AS Product_Segment,
	lifespan,
	Last_Sale_Date,
	Total_Orders,
	Total_Customers,
	Total_Sales,
	Total_Quantity,
	avg_selling_price,
CASE 
	WHEN Total_Orders =0 THEN 0
	ELSE Total_Sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregation

