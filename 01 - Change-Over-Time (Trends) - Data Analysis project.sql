--Change over time (trends)

SELECT 
DATETRUNC(year, order_date)AS Order_Year,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) AS Total_Quantity
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
ORDER BY DATETRUNC(year, order_date) 
