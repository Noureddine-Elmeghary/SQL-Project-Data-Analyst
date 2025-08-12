-- part-to-whole Analysis

--TASK : which categories contrebute the most to overall sales ?

WITH category_sales AS (
SELECT
   category,
  SUM (sales_amount) AS Total_Sales
FROM [gold.fact_sales] AS f
LEFT JOIN [gold.dim_products] AS p
ON p.product_key = f.product_key
GROUP BY category)

SELECT
category,
Total_Sales,
SUM(Total_Sales) OVER () overall_sales,
CONCAT (ROUND ((CAST (Total_Sales AS FLOAT) / SUM(Total_Sales) OVER ())*100, 2), '%') AS percentage_of_Total
FROM category_sales
ORDER BY Total_Sales DESC
