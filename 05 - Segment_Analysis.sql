/*task : Group customers into 3 segments 
   - VIP : Customers with at least 12 months of history and spending more than 5000$.
   - Regular : Customers with at least 12 months of history and spending 5000$ or less.
   - NEW : Customers with a lifespan less than 12months.
and find the total number of customers by each group*/ 

WITH Customer_Spending AS (
SELECT 
   c.customer_key,
   SUM (f.sales_amount) AS Total_Spending,
   MIN (order_date) AS First_year,
   MAX (order_date) AS Last_Order,
   DATEDIFF (month, MIN (order_date),MAX (order_date)) AS Lifespan
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key 
 )

 SELECT
 Customers_Segment,
 COUNT(customer_key) AS total_customers
 FROM (
 SELECT 
 customer_key,
 CASE WHEN Lifespan >= 12 AND Total_Spending > 5000 THEN 'VIP'
      WHEN Lifespan >= 12 AND Total_Spending <= 5000 THEN 'Regular'
	  ELSE 'New'
END Customers_Segment
 FROM Customer_Spending ) t
 GROUP BY Customers_Segment
 ORDER BY total_customers DESC
