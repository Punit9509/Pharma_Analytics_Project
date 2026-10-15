SELECT * FROM dbo.Pharma_staging;

--Calculate big numbers for the business--
SELECT 
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
CAST(SUM(Profit)AS DECIMAL (12,2)) Total_Profit,
COUNT(DISTINCT Order_id) Total_Orders,
SUM(Quantity) Total_Quantity_sold
FROM dbo.Pharma_staging;

--calculate how revenue has changed month by month.
SELECT 
Year(Order_date) AS Order_Year,
DATENAME(MONTH, Order_date) AS Month_name,
DATEPART(MONTH, Order_date) AS Order_Month,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue
FROM dbo.Pharma_staging
WHERE Order_date IS NOT NULL
GROUP BY 
Year(Order_date),
DATENAME(MONTH, Order_date),
DATEPART(MONTH, Order_date)
ORDER BY Order_Year, Order_Month;

--Which stores are generating the highest revenue, and how much profit are they generating?
SELECT 
Store_id,
Store_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) Total_Profit
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,Store_name
ORDER BY Total_Revenue DESC;

--Which are the top 5 products by revenue?
SELECT TOP 5
Product_id,
Product_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue 
FROM dbo.Pharma_staging 
GROUP BY
Product_id, Product_name
ORDER BY Total_revenue DESC;

--Which customers are repeat customers, and how much revenue have they generated?
SELECT 
Customer_id,
Customer_name,
COUNT(DISTINCT Order_id) Customer_count,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue 
FROM dbo.Pharma_staging 
GROUP BY Customer_id, customer_name
HAVING COUNT(DISTINCT Order_id) > 1;

--Which product categories generate the highest revenue, 
--and what percentage of total revenue does each category contribute?
WITH CTE_Category_Revenue AS
(
SELECT 
Category,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Category_Revenue
FROM dbo.Pharma_staging 
GROUP BY Category
)
SELECT 
Category,
Category_Revenue,
SUM(Category_Revenue) OVER() Overall_Revenue,
CAST(Category_Revenue / SUM(Category_Revenue) OVER() * 100 AS DECIMAL (12,2)) AS Contribution_Percentage
FROM CTE_Category_Revenue
ORDER BY Category_Revenue DESC;

--Which salesperson generated the highest revenue, and how much profit did each salesperson generate?”
SELECT 
Salesperson_id,
Salesperson_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) Total_Profit
FROM dbo.Pharma_staging 
GROUP BY 
Salesperson_id, salesperson_name
ORDER BY Total_Revenue DESC;

--For each store, show its revenue and also the store's rank based on revenue within the business.
WITH CTE_Store_Revenue AS
(
SELECT 
Store_id,
Store_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue
FROM dbo.Pharma_staging
GROUP BY 
Store_id,
Store_name
)
SELECT 
Store_id,
Store_name,
Total_Revenue,
DENSE_RANK() OVER(ORDER BY Total_Revenue DESC) Rank_Revenue
FROM CTE_Store_Revenue;

--For each month, how much revenue did we generate, and how did it compare with the previous month?
WITH CTE_Monthly_Revenue AS
(
SELECT 
DATEPART(YEAR, Order_date) Order_year,
DATEPART(MONTH, Order_date) Month_Number,
DATENAME(MONTH, Order_date) Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue
FROM dbo.Pharma_staging
GROUP BY 
DATEPART(YEAR, Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date) 
)
SELECT 
Order_year,
Month_number,
Month_name,
Total_Revenue,
LAG(Total_Revenue) OVER(PARTITION BY Order_year ORDER BY Month_Number ASC) Previous_month_Revenue
FROM CTE_Monthly_Revenue
WHERE Order_year IS NOT NULL;

--For each category, show the total revenue and total profit. Which category has the highest profit?
SELECT 
Category,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) Total_Profit
FROM dbo.Pharma_staging
GROUP BY Category
ORDER BY Total_Profit DESC;

--Which products have not been sold in the last 6 months?
SELECT 
Product_id,
Product_name,
MAX(Order_date) Last_order_date
FROM dbo.Pharma_staging 
GROUP BY Product_id, Product_name
HAVING MAX(Order_date) < DATEADD(MONTH, -6,MAX(Order_date))

--For each store, calculate Average Order Value (AOV).
SELECT 
Store_id,
Store_name,
CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,2)) AS Store_AOV
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,
Store_name;

--For each store, calculate Average Selling Price (ASP)
SELECT 
Store_id,
Store_name,
CAST(SUM(Revenue) / SUM(Quantity) AS DECIMAL (12,2)) AS Store_ASP
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,
Store_name;

--Identify the top 10 customers by total revenue
SELECT TOP 10
Customer_id,
Customer_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Customer_Revenue
FROM dbo.Pharma_staging 
GROUP BY 
Customer_id, Customer_name
ORDER BY Customer_revenue DESC;

--Which customers have placed more than 3 orders, and what is their total revenue?
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) Order_count,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Customer_Revenue
FROM dbo.Pharma_staging 
GROUP BY Customer_id
HAVING COUNT(DISTINCT Order_id) > 3;

--For each customer, calculate their Average Order Value (AOV) and show only customers whose AOV is greater than ₹5,000.
SELECT 
Customer_id,
CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,2)) AS Customer_AOV
FROM dbo.Pharma_staging 
GROUP BY Customer_id
HAVING SUM(Revenue) / COUNT(DISTINCT Order_id) > 5000;

--Management wants to identify customers who are generating high revenue but have placed relatively few orders, 
--so the sales team can investigate whether these are high-value, infrequent customers.
--High revenue means 10000 and few orders means less then 3

SELECT 
Customer_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
COUNT(DISTINCT Order_id) Number_of_orders
FROM dbo.Pharma_staging
GROUP BY Customer_id
HAVING SUM(Revenue) > 10000 AND COUNT(DISTINCT Order_id) < 3;

--What percentage of the company's total revenue comes from the top 10 customers?
WITH CTE_Customer_Revenue AS 
(
SELECT 
Customer_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Customer_Revenue
FROM dbo.Pharma_staging 
GROUP BY Customer_id
)
SELECT TOP 10 
Customer_id,
Customer_Revenue,
CAST(SUM(Customer_Revenue) OVER() AS DECIMAL (12,2)) Company_Revenue,
CAST(Customer_Revenue / SUM(Customer_Revenue) OVER() * 100 AS DECIMAL (12,2)) AS Contribution_Percentage
FROM CTE_Customer_Revenue
ORDER BY Customer_Revenue DESC;

--Management noticed that some customers may be placing many orders but generating relatively low revenue per order.
--at least 5 orders but have an AOV below ₹3,000.
SELECT 
Customer_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Customer_Revenue,
COUNT(DISTINCT Order_id) Order_Count,
CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,2)) AS Customer_AOV
FROM dbo.Pharma_staging
GROUP BY Customer_id
HAVING COUNT(DISTINCT Order_id) >= 5 AND SUM(Revenue) / COUNT(DISTINCT Order_id) < 3000
ORDER BY Customer_AOV DESC;

--Management wants to identify products that generate high revenue but have low profitability.
--total revenue is above ₹50,000 but profit margin is below 10%.
SELECT 
Product_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Total_Revenue,
CAST(SUM(Profit) / SUM(Revenue) AS DECIMAL (12,2)) AS Profit_Margin
FROM dbo.Pharma_staging 
GROUP BY Product_id
HAVING SUM(Revenue) > 50000 AND SUM(Profit) / SUM(Revenue) < 0.10;

--Management wants to identify stores that have high sales volume but poor profitability
--total revenue is above ₹1,000,000 but profit margin is below 8%
SELECT 
Store_id,
Store_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Sales_Volume,
CAST(SUM(Profit) / SUM(Revenue) AS DECIMAL (12,2)) * 100 Profit_Margin
FROM dbo.Pharma_staging
GROUP BY 
Store_id,
Store_name
HAVING SUM(Revenue) > 1000000 AND SUM(Profit) / SUM(Revenue) < 0.08;

--Identify the products that together contribute to the first 80% of total company revenue.
WITH CTE_Product_Revenue AS
(
SELECT 
Product_id,
Product_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Product_Revenue
FROM dbo.Pharma_staging
GROUP BY Product_id, Product_name
),
CTE_Cumulative_Percentage AS 
(
SELECT 
Product_id,
Product_name,
Product_Revenue,
SUM(Product_Revenue) OVER() Company_Revenue,
SUM(Product_Revenue) OVER(ORDER BY Product_Revenue DESC) Cumulative_Revenue,
CAST(SUM(Product_Revenue) OVER(ORDER BY Product_Revenue DESC) / SUM(Product_Revenue) OVER() * 100 AS DECIMAL (12,2)) Revenue_contribution_Percentage
FROM CTE_Product_Revenue
)
SELECT 
Product_id,
Product_name,
Product_Revenue,
Cumulative_Revenue,
Company_Revenue,
Revenue_Contribution_Percentage
FROM CTE_Cumulative_Percentage
WHERE Revenue_Contribution_Percentage <=80;

--Management wants to identify customers whose purchasing frequency is increasing.
WITH CTE_Orderdate AS
(
SELECT 
Customer_id,
Order_date,
LAG(order_date) OVER(PARTITION BY Customer_id ORDER BY order_date ASC) Previous_Orderdate
FROM dbo.Pharma_staging
),
CTE_Daydiff AS
(
SELECT 
Customer_id,
Order_date,
Previous_orderdate,
DATEDIFF(DAY, Previous_orderdate, Order_date) Days_between_orders
FROM CTE_Orderdate
),
CTE_Rank AS
(
SELECT 
Customer_id,
Order_date,
Previous_orderdate,
Days_between_orders,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_date
FROM CTE_Daydiff
)
SELECT 
Customer_id,
Order_date,
Previous_orderdate,
Days_between_orders
FROM CTE_Rank
WHERE Rank_date = 1;

--Management wants to identify customers whose latest order value is significantly higher than their previous order value.
WITH CTE_Revenue AS
(
SELECT
Customer_id,
Order_date,
CAST(Revenue AS DECIMAL (12,2))Current_Revenue,
CAST(LAG(Revenue) OVER(PARTITION BY Customer_id ORDER BY Order_date ASC) AS DECIMAL (12,2)) Previous_Revenue
FROM dbo.Pharma_staging
),
CTE_Increase_percentage AS
(
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
(Current_Revenue - Previous_Revenue) / Previous_revenue * 100 AS Revenue_Increase_per
FROM CTE_Revenue
),
CTE_Rank AS
(
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
Revenue_Increase_per,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_date
FROM CTE_Increase_percentage
)
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
Revenue_Increase_per
FROM CTE_Rank
WHERE Revenue_Increase_per >= 50 AND Rank_date = 1;

--Find customers whose last order was more than 180 days before the dataset's latest order date.
WITH CTE_Orderdate AS
(
SELECT 
Customer_id,
MAX(Order_date) OVER(PARTITION BY Customer_id) Last_orderdate_Customer,
MAX(Order_date) OVER() Last_overall_date
FROM dbo.Pharma_staging
)
SELECT DISTINCT
Customer_id,
Last_orderdate_customer,
Last_overall_date
FROM CTE_Orderdate
WHERE last_orderdate_customer < DATEADD(DAY, -180, Last_overall_date);

--how much revenue did each customer generate historically?, who were also inactive from last 180 days
WITH CTE_Customer AS
(
SELECT 
Customer_id,
CAST(SUM(Revenue) OVER(PARTITION BY Customer_id) AS DECIMAL(12,2)) AS Total_Revenue,
MAX(Order_date) OVER(PARTITION BY Customer_id) AS Customer_date,
MAX(Order_date) OVER() Overall_date
FROM dbo.Pharma_staging
)
SELECT DISTINCT
Customer_id,
Customer_date AS Customer_last_orderdate,
Overall_date AS Overall_lastorderdate,
Total_Revenue
FROM CTE_Customer
WHERE Customer_date < DATEADD(DAY, -180,Overall_date);

--identify customers whose latest order revenue dropped by more than 30% compared with their immediately previous order.
WITH CTE_customer AS 
(
SELECT 
Customer_id,
Order_date,
CAST(Revenue AS DECIMAL (12,2)) Current_Revenue,
CAST(LAG(Revenue) OVER(PARTITION BY Customer_id ORDER BY Order_date) AS DECIMAL(12,2)) Previous_Revenue
FROM dbo.Pharma_staging
),
CTE_Revenue_Percentage AS
(
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
CAST((Current_Revenue - Previous_Revenue) / Previous_Revenue * 100 AS DECIMAL (12,2)) AS Revenue_Percentage
FROM CTE_customer
),
CTE_Rank AS
(
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
Revenue_Percentage,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_date
FROM CTE_Revenue_Percentage
)
SELECT 
Customer_id,
Order_date,
Current_Revenue,
Previous_Revenue,
Revenue_Percentage,
Rank_date
FROM CTE_Rank
WHERE Rank_date = 1 AND Revenue_percentage < -30;

--Which products generated more than ₹50,000 revenue overall, 
--but had a decline in quantity sold in their latest month compared with the previous month?
WITH CTE_Product AS 
(
SELECT 
Product_id,
Product_name,
YEAR(Order_date) Order_Year,
MONTH(Order_date) Month_Number,
DATENAME(MONTH, Order_date) Month_Name,
SUM(Quantity) Total_Quantity,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue
FROM dbo.Pharma_staging
GROUP BY 
Product_id,
Product_name,
YEAR(Order_date),
MONTH(Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previousmonth AS 
(
SELECT 
Product_id,
Product_name,
Order_Year,
Month_number,
Month_Name,
SUM(Total_Revenue) OVER(PARTITION BY Product_id) Total_Revenue,
Total_Quantity AS Current_month_Quantity_sold,
LAG(Total_Quantity) OVER(PARTITION BY Product_id, Order_year ORDER BY Order_Year, Month_number) Previous_month_quantity_sold
FROM CTE_Product
),
CTE_Rank_Month AS 
(
SELECT 
Product_id,
Product_name,
Order_Year,
Month_number,
Month_Name,
DENSE_RANK() OVER(PARTITION BY Product_id, Order_Year ORDER BY Month_number DESC) Rank_month,
Total_Revenue,
Current_month_Quantity_sold,
Previous_month_quantity_sold
FROM CTE_Previousmonth
)
SELECT 
Product_id,
Product_name,
Order_Year,
Month_Name,
Total_Revenue,
Current_month_Quantity_sold,
Previous_month_quantity_sold
FROM CTE_Rank_Month
WHERE 
Rank_month = 1 AND 
Total_Revenue > 50000 AND 
Current_month_Quantity_sold < Previous_month_quantity_sold 
AND Order_year IS NOT NULL
ORDER BY Order_year ASC;

--Stores where revenue increased in the latest month compared with the previous month, but profit margin decreased.
WITH CTE_Store AS 
(
SELECT 
Store_id,
Store_name,
YEAR(Order_date) AS Order_year,
MONTH(Order_date) AS Month_number,
DATENAME(MONTH, Order_date) AS Month_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Store_Revenue,
CAST(SUM(Profit) / SUM(Revenue) AS DECIMAL (12,2)) AS Profit_Margin_current
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,
Store_name,
YEAR(Order_date),
MONTH(Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_month AS
(
SELECT 
Store_id,
Store_name,
Order_year,
Month_number,
Month_name,
Store_Revenue AS Current_month_Revenue,
LAG(Store_Revenue) OVER(PARTITION BY Store_id, Order_year ORDER BY Order_year, Month_number) Previous_month_Revenue,
Profit_margin_Current,
LAG(Profit_margin_current) OVER(PARTITION BY Store_id, order_year ORDER BY Order_year, Month_number) Profit_margin_Previous
FROM CTE_Store
),
CTE_Rank_month AS 
(
SELECT 
Store_id,
Store_name,
Order_year,
Month_number,
DENSE_RANK() OVER(PARTITION BY Store_id ORDER BY Order_year DESC, month_number DESC) Rank_Month,
Month_name,
Current_month_Revenue,
Previous_month_Revenue,
Profit_margin_current,
Profit_margin_Previous
FROM CTE_Previous_month
)
SELECT 
Store_id,
Store_name,
Order_year,
Month_number,
Rank_Month,
Month_name,
Current_month_Revenue,
Previous_month_Revenue,
Profit_margin_current,
Profit_margin_Previous
FROM CTE_Rank_month
WHERE
Rank_Month = 1 AND
Order_year IS NOT NULL AND
Current_month_revenue > Previous_month_revenue AND
Profit_margin_current < Profit_margin_Previous;

--Find customers who placed at least 4 orders overall, 
--but whose latest order was more than 180 days after their previous order.
WITH CTE_Customer AS 
(
SELECT 
Customer_id,
Order_id,
Order_date,
LAG(Order_date) OVER(PARTITION BY Customer_id ORDER BY Order_date) Previous_order_date
FROM dbo.Pharma_staging
),
CTE_Order_count AS 
(
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) Order_count
FROM CTE_Customer
GROUP BY Customer_id
),
CTE_Day_difference AS 
(
SELECT 
COC.Customer_id,
COC.Order_count,
CC.Order_date,
CC.Previous_order_date,
DENSE_RANK() OVER(PARTITION BY COC.Customer_id ORDER BY CC.Order_date DESC) Rank_date,
DATEDIFF(DAY,Previous_order_date, Order_date) Days_diff
FROM CTE_Customer AS CC
JOIN CTE_Order_count AS COC
ON CC.Customer_id = COC.Customer_id
)
SELECT 
Customer_id,
Order_count,
Order_date,
Previous_order_date,
Days_diff,
Rank_date
FROM CTE_Day_difference
WHERE Rank_date = 1 AND Order_count >= 4 AND Days_diff > 180;

--The business wants to identify customers whose latest order represents more than 50% of their total historical revenue.
WITH CTE_Latest_orderRevenue AS
(
SELECT 
Customer_id,
Order_date,
CAST(Revenue AS DECIMAL (12,2)) AS Revenue,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_Revenue
FROM dbo.Pharma_staging
),
CTE_Total_Revenue AS
(
SELECT 
Customer_id,
Order_date,
Revenue,
Rank_Revenue,
SUM(Revenue) OVER(PARTITION BY Customer_id) Total_Revenue
FROM CTE_Latest_orderRevenue
)
SELECT 
Customer_id,
Order_date,
Revenue,
Total_Revenue
FROM CTE_Total_Revenue
WHERE Rank_revenue = 1 AND
Revenue / Total_Revenue * 100 > 50;

--The business wants to identify customers who have placed at least 5 orders,
--but whose latest order value is less than 20% of their total historical revenue.
WITH CTE_Customer AS 
(
SELECT 
Customer_id,
Order_id,
Order_date,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_date,
CAST(Revenue AS DECIMAL (12,2)) AS Revenue
FROM dbo.Pharma_staging
),
CTE_Order_count AS
(
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) AS Order_count,
SUM(Revenue) AS Total_revenue
FROM CTE_Customer
GROUP BY Customer_id
)
SELECT 
CC.Customer_id,
CC.Order_date,
CC.Rank_date,
CC.Revenue,
COC.Order_count,
COC.Total_Revenue,
CAST(CC.Revenue/COC.Total_Revenue * 100  AS DECIMAL (12,2)) AS Percentage_revenue
FROM CTE_Customer AS CC
JOIN CTE_Order_count AS COC
ON CC.Customer_id = COC.Customer_id
WHERE
CC.Rank_date = 1 AND 
COC.Order_count >=5 AND
CC.Revenue/COC.Total_Revenue * 100 < 20;

--The business wants to identify products where the latest month's revenue is more than 40% of the product's 
--total historical revenue, AND the latest month had higher revenue than the previous month.
WITH CTE_Monthly_Revenue AS
(
SELECT 
Product_id,
Product_name,
YEAR(Order_date) AS Order_Year,
DATEPART(MONTH, Order_date) AS Month_number,
DATENAME(MONTH, Order_date) AS Month_Name,
SUM(Revenue) Monthly_Revenue
FROM dbo.Pharma_staging
GROUP BY 
Product_id,
Product_name,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Total_Revenue AS
(
SELECT 
Product_id,
Product_name,
Order_year,
Month_number,
Month_name,
Monthly_Revenue,
CAST(SUM(Monthly_revenue) OVER(PARTITION BY Product_id) AS DECIMAL (12,2)) Product_revenue
FROM CTE_Monthly_Revenue
),
CTE_Previous_month AS
(
SELECT 
Product_id,
Product_name,
Order_year,
Month_number,
Month_name,
Monthly_revenue,
Product_Revenue,
CAST(LAG(Monthly_revenue) OVER(PARTITION BY Product_id, Order_Year ORDER BY Order_year, Month_number) AS DECIMAL (12,2)) Previous_month_revenue
FROM CTE_Total_Revenue
),
CTE_Rankmonth AS
(
SELECT 
Product_id,
Product_name,
Order_year,
Month_number,
DENSE_RANK() OVER(PARTITION BY Product_id, Order_year ORDER BY Order_year, month_number DESC) Rank_month,
Month_name,
Monthly_revenue,
Product_Revenue,
Previous_month_revenue
FROM CTE_Previous_month
)
SELECT 
Product_id,
Product_name,
Order_year,
Month_number,
Month_name,
Monthly_revenue,
Product_Revenue,
Previous_month_revenue
FROM CTE_Rankmonth
WHERE Order_year IS NOT NULL 
AND Rank_month = 1
AND Monthly_revenue / Product_revenue * 100 > 40
AND Monthly_Revenue > Previous_month_revenue;

--business wants to identify high-value customers who have both:placed at least 5 order & generated at least ₹20,000 total revenue.
WITH CTE_CustomerKPI AS
(
SELECT 
Customer_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
COUNT(DISTINCT Order_id) Order_count
FROM dbo.Pharma_staging
GROUP BY Customer_id
)
SELECT 
*
FROM CTE_CustomerKPI
WHERE Order_count >= 5 AND Total_Revenue >=20000;

--The business wants to identify customers who are becoming less valuable over time.
--They have placed at least 4 orders
--Their latest order revenue is less than 20% of their total historical revenue
WITH CTE_Rank AS 
(
SELECT 
Customer_id,
Order_id,
CAST(Revenue AS DECIMAL (12,2)) Revenue,
Order_date,
DENSE_RANK() OVER(PARTITION BY Customer_id ORDER BY Order_date DESC) Rank_date
FROM dbo.Pharma_staging
),
CTE_Total_Revenue AS
(
SELECT 
Customer_id,
Order_id,
Revenue,
CAST(SUM(Revenue) OVER(PARTITION BY Customer_id) AS DECIMAL (12,2)) Total_Revenue,
Order_date,
Rank_date
FROM CTE_Rank
),
CTE_Count_order AS
(
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) AS Order_count
FROM CTE_Total_Revenue
GROUP BY Customer_id
)
SELECT 
CCO.Customer_id,
CCO.Order_count,
CTR.Revenue,
CTR.Total_revenue,
CTR.Order_date
FROM CTE_Count_order AS CCO
JOIN CTE_Total_Revenue AS CTR
ON CCO.Customer_id = CTR.Customer_id
WHERE 
Rank_date = 1 AND
Order_count >= 4 AND
Revenue / Total_Revenue * 100 < 20;

--The business wants to identify products with strong overall sales but weak profitability., Total Revenue > ₹75,000,Profit Margin < 12%
WITH CTE_ProductKPI AS
(
SELECT 
Product_id,
Product_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) Total_Profit,
CAST(SUM(Profit) / SUM(Revenue) * 100 AS DECIMAL (12,2)) AS Profit_Margin
FROM dbo.pharma_staging 
GROUP BY 
Product_id,
Product_name
)
SELECT * FROM CTE_ProductKPI
WHERE Total_Revenue > 75000 AND Profit_Margin < 12;

--The business wants to find customers who are highly dependent on a small number of orders.
---They have at least 3 orders, Their highest single order revenue is more than 50% of their total historical revenue
WITH CTE_Highest_revenue AS
(
SELECT 
Customer_id,
Order_id,
CAST(Revenue AS DECIMAL (12,2)) Revenue,
CAST(MAX(Revenue) OVER(PARTITION BY Customer_id) AS DECIMAL (12,2)) Highest_revenue
FROM dbo.Pharma_staging
),
CTE_Total_Revenue AS
(
SELECT 
Customer_id,
Order_id,
Revenue,
SUM(Revenue) OVER(PARTITION BY Customer_id) Total_Revenue,
Highest_Revenue
FROM CTE_Highest_revenue
),
CTE_Order_count AS
(
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) Order_count
FROM CTE_Total_Revenue
GROUP BY Customer_id
)
SELECT 
CTR.Customer_id,
CTR.Revenue,
CTR.Total_Revenue,
CTR.Highest_revenue,
COC.Order_count,
CAST(CTR.Highest_revenue / CTR.Total_revenue * 100 AS DECIMAL (12,2)) AS Contribution_percentage
FROM CTE_Total_revenue AS CTR
JOIN CTE_Order_count AS COC
ON CTR.Customer_id = COC.Customer_id
WHERE
COC.Order_count >= 3 AND 
CTR.Highest_revenue / CTR.Total_revenue * 100 > 50;

--The business wants to identify products that have broad sales volume but low average selling price.
--Total quantity sold is at least 500 units, ASP is below ₹300
WITH CTE_ProductKPI AS
(
SELECT 
Product_id,
Product_name,
SUM(Quantity) AS Total_Quantity_Sold,
CAST(SUM(Revenue) / SUM(Quantity) AS DECIMAL (12,2)) AS Product_ASP
FROM dbo.Pharma_staging 
GROUP BY 
Product_id,
Product_name
)
SELECT 
*
FROM CTE_ProductKPI 
WHERE Total_Quantity_sold >= 500 AND Product_ASP < 300;

--The business wants to find stores that generate high revenue but have low customer spending per order.
--Total Revenue more than ₹1,000,000, AOV less than ₹2,500
	WITH CTE_StoreKPI AS 
	(
	SELECT 
	Store_id,
	Store_name,
	CAST(SUM(Revenue) AS DECIMAL (12,3)) Store_Revenue,
	CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,3)) AS Store_AOV
	FROM dbo.Pharma_staging 
	GROUP BY 
	Store_id,
	Store_name
	)
	SELECT * FROM CTE_StoreKPI 
	WHERE Store_Revenue > 100000 AND Store_AOV < 2500;

--The business wants to understand which products contribute significantly to overall revenue.
--Each product generates more than ₹50,000 in total revenue.
--Each product contributes at least 2% of the company's total revenue
WITH CTE_Product_Revenue AS
(
SELECT
Product_id,
Product_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Product_Revenue
FROM dbo.Pharma_staging 
GROUP BY 
Product_id,
Product_name
),
CTE_Company_Revenue AS
(
SELECT 
Product_id,
Product_name,
Product_Revenue,
SUM(Product_revenue) OVER() AS Company_Revenue
FROM CTE_Product_Revenue
)
SELECT 
Product_id,
Product_name,
Product_Revenue,
Company_Revenue,
CAST(Product_Revenue / Company_revenue * 100 AS DECIMAL (12,2)) AS Contribution_Percentage
FROM CTE_Company_Revenue
WHERE Product_Revenue > 50000 AND Product_Revenue / Company_revenue * 100 > 2;

--Identify customers who have purchased from at least 3 different product categories and 
--generated more than ₹25,000 in total revenue.
WITH CTE_Customer AS
(
SELECT 
Customer_id,
COUNT(DISTINCT Category) Category_Count,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Total_Revenue
FROM dbo.Pharma_staging 
GROUP BY 
Customer_id
)
SELECT * FROM CTE_Customer
WHERE Total_revenue > 25000 AND Category_count >= 3;

--The business wants to identify customers whose top two orders together account for at least 70% of their total historical revenue.
WITH CTE_Rank AS
(
SELECT 
Customer_id,
Order_id,
CAST(Revenue AS DECIMAL (12,2)) AS Revenue,
Row_number() OVER(PARTITION BY Customer_id ORDER BY Revenue DESC) Rank_Revenue
FROM dbo.Pharma_staging
),
CTE_Customer_Revenue AS
(
SELECT 
Customer_id,
Order_id,
Revenue,
Rank_Revenue,
SUM(Revenue) OVER(PARTITION BY Customer_id) Customer_Revenue
FROM CTE_Rank
),
CTE_Top2_Revenue AS
(
SELECT 
Customer_id,
SUM(Revenue) Single_order_revenue,
Customer_revenue
FROM CTE_Customer_Revenue
WHERE Rank_Revenue BETWEEN 1 AND 2
GROUP BY 
Customer_id,
Customer_revenue
)
SELECT 
Customer_id,
Single_order_revenue,
Customer_Revenue,
CAST(Single_order_revenue / Customer_revenue * 100 AS DECIMAL (12,2)) AS TOP2_Contribution
FROM CTE_Top2_Revenue
WHERE Single_order_revenue / Customer_revenue * 100 >= 70;

--The business wants to compare completed sales with returned sales for each product category.
WITH CTE_Category AS
(
SELECT
Category,
Revenue,
Order_id,
Order_status
FROM dbo.Pharma_staging
)
SELECT 
Category,
SUM(CASE WHEN Order_status = 'Completed' THEN Revenue ELSE 0 END) AS Completed_Revenue,
COUNT(DISTINCT CASE WHEN Order_status = 'Completed' THEN Order_id END) AS Completed_Order,
SUM(CASE WHEN Order_status = 'Returned' THEN Revenue ELSE 0 END) AS Returned_Revenue,
COUNT(DISTINCT CASE WHEN Order_status = 'Returned' THEN Order_id END) AS Returned_Order
FROM CTE_Category
GROUP BY Category;

--The business wants to compare completed-order revenue against returned-order revenue for each region, 
--and identify regions where returned revenue exceeds 10% of completed revenue.
WITH CTE_Revenue_comparison AS
(
SELECT 
Region,
CAST(SUM(CASE WHEN Order_status = 'Completed' THEN Revenue ELSE 0 END) AS DECIMAL (12,2)) Complete_order_Revenue,
CAST(SUM(CASE WHEN Order_status = 'Returned' THEN Revenue ELSE 0 END) AS DECIMAL (12,2)) Returned_Order_Revenue
FROM dbo.Pharma_staging
GROUP BY Region
)
SELECT 
Region,
Complete_order_Revenue,
Returned_Order_Revenue,
Returned_Order_Revenue/NULLIF(Complete_order_Revenue, 0) * 100 Revenue_Comparison
FROM CTE_Revenue_comparison
WHERE Returned_Order_Revenue/NULLIF(Complete_order_Revenue,0) * 100 > 10;

--The business wants to identify customers who have placed orders across at least 3 different months 
--and generated more than ₹15,000 in total revenue.
SELECT 
Customer_id,
Customer_name,
COUNT(DISTINCT DATEFROMPARTS(YEAR(Order_date), Month(Order_date), 1)) AS Active_Months,	
COUNT(DISTINCT Order_id) AS Order_count,
CAST(SUM(Revenue) AS DECIMAL(12,2)) AS Total_Revenue
FROM dbo.Pharma_staging
GROUP BY
Customer_id,
Customer_name
HAVING COUNT(DISTINCT DATEFROMPARTS(YEAR(Order_date), Month(Order_date), 1)) >=3 AND
SUM(Revenue)  > 15000;

--The business wants to identify regions where:
-- Regional revenue per store is above the company-wide average revenue per store.
--Regional profit margin is below the overall company profit margin.
WITH CTE_Store AS
(
SELECT 
Region,
Store_id,
Store_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Store_revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) AS Store_profit
FROM dbo.pharma_staging
GROUP BY 
Region,
Store_id,
Store_name
),
CTE_Region AS 
(
SELECT 
Region,
Store_id,
Store_name,
Store_Revenue,
SUM(Store_revenue) OVER(PARTITION BY Region) Regional_revenue,
Store_Profit,
SUM(Store_profit) OVER(PARTITION BY Region) Regional_Profit
FROM CTE_Store
),
CTE_Store_count AS
(
SELECT 
Region,
COUNT(DISTINCT Store_id) Store_count
FROM CTE_Region 
GROUP BY Region
),
CTE_Regional_metrics AS
(
SELECT 
CR.Region,
CR.Store_id,
CR.Store_name,
CR.Store_Revenue,
CR.Store_Profit,
CR.Regional_Revenue,
CR.Regional_Profit,
CSC.Store_count,
CR.Regional_Revenue / CSC.Store_count AS Revenue_Per_store,
CR.Regional_Profit / CR.Regional_Revenue * 100 AS Profit_margin_Percentage
FROM CTE_Region AS CR
JOIN CTE_Store_count AS CSC
ON CR.Region = CSC.Region
),
CTE_Final_metric AS
(
SELECT 
Region,
Store_id,
Store_name,
Store_revenue,
Regional_revenue,
AVG(Store_Revenue) OVER() Overall_company_AVG,
Regional_profit,
CAST(SUM(Store_profit) OVER() AS DECIMAL (12,2)) / NULLIF(SUM(Store_revenue) Over(), 0) * 100 Overall_Profit_margin,
Store_count,
Revenue_per_store,
Profit_margin_percentage
FROM CTE_Regional_metrics
)
SELECT 
Region,
Store_count,
Regional_Revenue,
Revenue_per_store,
Profit_margin_percentage
FROM CTE_Final_metric
WHERE 
 Revenue_Per_store > Overall_company_AVG
AND Profit_margin_percentage < Overall_Profit_margin;

--Management wants to identify stores that are growing revenue but losing profitability.
--Revenue increased in the latest month compared with the previous month.
--Profit margin decreased in the latest month compared with the previous month.
--Total historical revenue exceeds ₹100,000.
WITH CTE_Store AS 
(
SELECT 
Store_id,
Store_name,
YEAR(Order_date) AS Order_year,
DATEPART(MONTH, Order_date) AS Month_Number,
DATENAME(MONTH, Order_date) AS Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Revenue,
CAST(SUM(Profit) AS DECIMAL (12,2)) AS Profit,
CAST(SUM(Profit) * 100.0 /SUM(Revenue) AS DECIMAL (12,2)) AS Profit_Margin
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,
Store_name,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_month AS
(
SELECT 
Store_id,
Store_name,
Order_year,
Month_Number,
Month_Name,
Revenue,
CAST(LAG(Revenue) OVER(PARTITION BY Store_id ORDER BY Order_year, Month_number) AS DECIMAL (12,2)) Previous_Month_Revenue,
Profit_Margin,
CAST(LAG(Profit_Margin) OVER(PARTITION BY Store_id ORDER BY Order_year, Month_Number) AS DECIMAL (12,2)) Previous_month_pf,
CAST(SUM(Revenue) OVER(PARTITION BY Store_id) AS DECIMAL (12,2)) AS Overall_revenue
FROM CTE_Store
)
SELECT 
Store_id,
Store_name,
Order_Year,
Month_Number,
Month_Name,
Revenue,
Previous_month_revenue,
Profit_Margin,
Previous_month_pf,
Overall_Revenue
FROM CTE_Previous_month
WHERE 
Order_year IS NOT NULL AND 
Revenue > Previous_month_revenue AND
Profit_margin < Previous_month_pf AND
Overall_revenue > 100000;

--identify customers who generate a disproportionately large share of their own historical revenue through their two highest-value orders.
--Have placed at least 4 distinct orders.
--Their top two orders combined account for at least 60% of their total historical revenue.
--Their total historical revenue exceeds ₹20,000.
WITH CTE_Revenue AS
(
SELECT 
Customer_id,
Order_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Revenue
FROM dbo.Pharma_staging
GROUP BY 
Customer_id, Order_id
),
CTE_Rank AS
(
SELECT 
Customer_id,
Order_id,
Revenue,
SUM(Revenue) OVER(PARTITION BY Customer_id) Total_customer_revenue,
ROW_NUMBER() OVER(PARTITION BY Customer_id ORDER BY Revenue DESC) Rank_Revenue
FROM CTE_Revenue
),
CTE_Order_Count AS
(
    SELECT
        Customer_ID,
        COUNT(*) AS Total_Orders
    FROM CTE_Revenue
    GROUP BY Customer_ID
),
CTE_Top2_Revenue AS
(
    SELECT
        Customer_ID,
        MAX(Total_Customer_Revenue) AS Total_Customer_Revenue,
        SUM(Revenue) AS Top2_Orders_Revenue
    FROM CTE_Rank
    WHERE Rank_Revenue BETWEEN 1 AND 2
    GROUP BY Customer_ID
	)
	SELECT
    T.Customer_ID,
    O.Total_Orders,
    T.Total_Customer_Revenue,
    T.Top2_Orders_Revenue,
    T.Top2_Orders_Revenue * 100.0
        / NULLIF(T.Total_Customer_Revenue, 0) AS Top2_Contribution_Percentage
FROM CTE_Top2_Revenue AS T
JOIN CTE_Order_Count AS O
    ON T.Customer_ID = O.Customer_ID
    WHERE Total_orders >= 4 AND 
        T.Top2_Orders_Revenue * 100.0
        / NULLIF(T.Total_Customer_Revenue, 0) >= 60 AND
        Total_Customer_Revenue > 20000;

--identify customers whose purchasing activity has weakened.
--Have placed at least 4 distinct orders historically.
--Their latest order's revenue is at least 30% lower than their immediately previous order's revenue.
--Their total historical revenue exceeds ₹25,000. 
WITH CTE_Revenue AS
(
SELECT 
Customer_id,
Order_id,
Order_date,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Revenue
FROM dbo.Pharma_staging
GROUP BY 
Customer_id,
Order_id,
Order_date
),
CTE_Overall_Revenue AS
(
SELECT 
Customer_id,
Order_id,
Order_date,
Revenue,
SUM(Revenue) OVER(PARTITION BY Customer_id) Overall_Revenue,
LAG(Revenue) OVER(PARTITION BY Customer_id ORDER BY Order_date) Previous_Revenue
FROM CTE_Revenue
),
CTE_Rank AS
(
SELECT 
Customer_id,
Order_id,
Order_date,
ROW_NUMBER() OVER(PARTITION BY Customer_id ORDER BY Order_date, Order_id DESC) Rank_Revenue,
Revenue,
Previous_revenue,
Overall_revenue
FROM CTE_Overall_Revenue
),
CTE_Order_count AS
(
SELECT 
Customer_id,
COUNT(DISTINCT Order_id) Order_count
FROM CTE_Overall_Revenue
GROUP BY Customer_id
)
SELECT 
CR.Customer_id,
CR.Order_date,
CR.Revenue,
CR.Previous_revenue,
CR.Overall_revenue,
CR.Rank_Revenue,
CO.Order_count,
(CR.Revenue - CR.Previous_revenue) * 100.0 / NULLIF(CR.Previous_revenue, 0)  AS Revenue_Percentage
FROM CTE_Rank AS CR
JOIN CTE_Order_count AS CO
ON CR.Customer_id = CO.Customer_id
WHERE 
Rank_Revenue = 1 AND
Order_count >=4 AND 
Overall_revenue > 25000 AND 
(CR.Revenue - CR.Previous_revenue) * 100.0 / NULLIF(CR.Previous_revenue, 0) >= 30;

--identify products that meet all these conditions:
--1. Total historical revenue exceeds ₹75,000.
--2. Revenue in the latest available month is higher than in the immediately preceding calendar month.
--3. Profit margin in the latest month is lower than in the preceding month.
--4. The latest month's profit margin is below 10%.
WITH CTE_Product AS
(
SELECT 
Product_id,
Product_Name,
DATEPART(YEAR, Order_date) Order_Year,
DATEPART(MONTH, Order_date) Month_Number,
DATENAME(MONTH, Order_date) Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Product_Revenue,
CAST(SUM(Profit) * 100 / NULLIF(SUM(Revenue), 0) AS DECIMAL (12,2)) Product_PF
FROM dbo.Pharma_staging
GROUP BY 
Product_id,
Product_Name,
DATEPART(YEAR, Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_month AS
(
SELECT 
Product_id,
Product_name,
Order_year,
Month_Number,
Month_Name,
Product_Revenue,
CAST(LAG(Product_Revenue) OVER(PARTITION BY Product_id ORDER BY Order_year, Month_number) AS DECIMAL (12,2)) Previous_month_revenue,
Product_PF,
CAST(LAG(Product_PF) OVER(PARTITION BY Product_id ORDER BY Order_year, Month_number) AS DECIMAL (12,2)) Previous_Month_PF,
CAST(SUM(Product_Revenue) OVER(PARTITION BY Product_id) AS DECIMAL (12,2)) Overall_Revenue
FROM CTE_Product
),
CTE_Rank AS
(
SELECT 
Product_id,
Product_name,
Order_year,
Month_Number,
Month_Name,
ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Order_Year DESC, Month_Number DESC) AS Rank_Month,
Product_Revenue,
Previous_month_revenue,
Product_PF,
Previous_month_PF,
Overall_revenue
FROM CTE_Previous_month
)
SELECT 
Product_id,
Product_name,
Order_year,
Month_Number,
Month_Name,
Product_Revenue,
Previous_month_revenue,
Product_PF,
Previous_month_PF,
Overall_revenue,
Rank_Month
FROM CTE_Rank
WHERE 
Order_year IS NOT NULL AND
Rank_month = 1 AND
Overall_revenue > 75000 AND
Product_PF < 10 AND
Product_PF < Previous_month_PF AND
Product_Revenue > Previous_month_revenue;

--identify customers who meet all these conditions:
--1. Have placed at least 5 distinct orders.
--2. Total historical revenue exceeds ₹30,000.
--3. Their overall profit margin is below 12%.
--4. They purchased products from at least 3 distinct categories.

SELECT 
Customer_id,
COUNT(DISTINCT Order_id) AS Order_count,
COUNT(DISTINCT Category) AS Category_Count,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Customer_revenue,
CAST(SUM(Profit) * 100.0 / NULLIF(SUM(Revenue), 0) AS DECIMAL (12,2)) AS Profit_margin_percentage
FROM dbo.Pharma_staging 
GROUP BY 
Customer_id
HAVING
COUNT(DISTINCT Order_id)>=5 AND
COUNT(DISTINCT Category)>=3 AND
SUM(Revenue) > 30000 AND
SUM(Profit) * 100.0 / NULLIF(SUM(Revenue), 0) < 12;

--Management wants to identify stores whose revenue has grown faster than the company's overall revenue growth.
--Store revenue increased in 2025 compared with 2024.
--The store's year-over-year revenue growth percentage is greater than the company's overall year-over-year revenue growth percentage.
--The store generated more than ₹100,000 in total historical revenue.
WITH CTE_Store AS
(
SELECT 
Store_id,
Store_name,
YEAR(Order_date) Order_year,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Store_Revenue
FROM dbo.Pharma_staging 
GROUP BY 
Store_id,
Store_name,
YEAR(Order_date)
),
CTE_Overall AS
(
SELECT 
Store_id,
Store_name,
Order_year,
Store_Revenue,
LAG(Store_Revenue) OVER(PARTITION BY Store_id ORDER BY Order_year) Previous_year_store
FROM CTE_Store
),
CTE_Company_revenue AS
(
SELECT 
Order_year,
SUM(Store_revenue) Company_revenue
FROM CTE_Overall
GROUP BY Order_year
),
CTE_Previous_year_company AS
(
SELECT 
Order_year,
Company_revenue,
LAG(Company_revenue) OVER(ORDER BY Order_year ASC) Previous_revenue_company
FROM CTE_Company_revenue
),
CTE_Join AS
(
SELECT 
CO.Store_id,
CO.Store_name,
CO.Order_year,
CO.Store_Revenue,
CO.Previous_year_store,
CPY.Company_revenue,
CPY.Previous_revenue_company
FROM CTE_Overall AS CO
JOIN CTE_Previous_year_company AS CPY
ON CO.Order_year = CPY.Order_year
),
CTE_Final AS
(
SELECT 
Store_id,
Store_name,
Order_year,
Store_Revenue,
Previous_year_store,
CAST((Store_revenue - Previous_year_store) * 100.0 / NULLIF(Previous_year_store, 0) AS DECIMAL (12,2)) Store_YOYGrowth,
Company_revenue,
Previous_revenue_company,
CAST((Company_revenue - Previous_revenue_company)*100.0 / NULLIF(Previous_revenue_company,0) AS DECIMAL (12,2)) Company_YOYGrowth
FROM CTE_Join
WHERE Order_year IN(2024, 2025)
)
SELECT 
Store_id,
Store_name,
Order_year,
Store_Revenue,
Previous_year_store,
Store_YOYGrowth,
Company_revenue,
Previous_revenue_company,
Company_YOYGrowth
FROM CTE_Final
WHERE 
Order_year IS NOT NULL AND
Store_revenue > Previous_year_store AND
Store_YOYGrowth > Company_YOYGrowth AND
Store_Revenue > 100000;

--stores whose monthly revenue has declined compared with the previous month.
WITH CTE_Store AS
(
SELECT 
Store_id,
Store_name,
YEAR(Order_date) AS Order_year,
DATEPART(MONTH, Order_date) Month_number,
DATENAME(MONTH, Order_date) Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Store_Revenue
FROM dbo.Pharma_staging
GROUP BY 
Store_id,
Store_name,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_month AS 
(
SELECT
Store_id,
Store_name,
Order_year,
Month_number,
Month_name,
Store_Revenue AS Current_month_revenue,
LAG(Store_revenue) OVER(PARTITION BY Store_id ORDER BY Order_year ASC, Month_number ASC) Previous_month_revenue
FROM CTE_Store
)
SELECT
Store_id,
Store_name,
Order_year,
Month_number,
Month_name,
Current_month_revenue,
Previous_month_revenue
FROM CTE_Previous_month
WHERE Order_year IS NOT NULL 
AND
Current_month_revenue < previous_month_revenue;

--identify customers whose average order value is higher than the 
--average order value of other customers in their respective cities.
WITH CTE_Customer AS
(
SELECT 
City,
Customer_id,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Customer_revenue,
COUNT(DISTINCT Order_id) AS Order_count,
CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,2)) Customer_AOV
FROM dbo.Pharma_staging
GROUP BY 
City,
Customer_id
),
CTE_City AS
(
SELECT 
City,
Customer_id,
Customer_revenue,
Order_count,
Customer_AOV,
SUM(Customer_AOV) OVER(PARTITION BY City) Total_customer_AOV,
COUNT(Customer_id) OVER(PARTITION BY City) Number_of_customers
FROM CTE_Customer
)
SELECT 
City,
Customer_id,
Customer_AOV,
Total_customer_AOV / Number_of_customers AS Average_Of_Customer_AOV
FROM CTE_City
WHERE Customer_AOV > (Total_customer_AOV / Number_of_customers);

--identify products whose monthly revenue has declined for two consecutive months within each region.
WITH CTE_Regionwise AS
(
SELECT 
Region,
Product_id,
Product_name,
YEAR(Order_date) AS Order_year,
DATEPART(MONTH, Order_date) AS Month_number,
DATENAME(MONTH, Order_date) AS Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Revenue
FROM dbo.Pharma_staging
GROUP BY 
Region,
Product_id,
Product_name,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_revenue AS
(
SELECT 
Region,
Product_id,
Product_name,
Order_year,
Month_number,
Month_name,
Revenue,
LAG(Revenue) OVER(PARTITION BY Region, Product_id ORDER BY Order_year ASC, Month_number ASC) Revenue_one_month_ago,
LAG(Revenue, 2) OVER(PARTITION BY Region, Product_id ORDER BY Order_year ASC, Month_number ASC) Revenue_two_month_ago
FROM CTE_Regionwise
)
SELECT 
Region,
Product_id,
Product_name,
Order_year,
Month_number,
Month_name,
Revenue,
Revenue_one_month_ago,
Revenue_two_month_ago
FROM CTE_Previous_revenue
WHERE 
Order_year IS NOT NULL AND 
Revenue < Revenue_one_month_ago AND 
Revenue_one_month_ago < Revenue_two_month_ago;

--identify stores whose average order value (AOV) is increasing while their
--total monthly revenue is declining for three consecutive months.
WITH CTE_Store AS 
(
SELECT
Store_id,
Store_name,
YEAR(Order_date) Order_year,
DATEPART(MONTH, Order_date) AS Month_number,
DATENAME(MONTH, Order_date) AS Month_Name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Store_Revenue,
COUNT(DISTINCT Order_id) AS Order_count,
CAST(SUM(Revenue) / COUNT(DISTINCT Order_id) AS DECIMAL (12,2)) AS Store_AOV
FROM dbo.Pharma_staging
GROUP BY 
Store_id,
Store_name,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Previous_months AS 
(
SELECT 
Store_id,
Store_name,
Order_year,
Month_number,
Month_Name,
Store_revenue,
LAG(Store_revenue) OVER(PARTITION BY Store_id ORDER BY Order_year ASC, Month_number ASC) Revenue_one_month,
LAG(Store_revenue, 2) OVER(PARTITION BY Store_id ORDER BY  Order_year ASC, Month_number ASC) Revenue_two_month,
LAG(Store_revenue, 3) OVER(PARTITION BY Store_id ORDER BY  Order_year ASC, Month_number ASC) Revenue_three_month,
Order_count,
Store_AOV,
LAG(Store_AOV) OVER(PARTITION BY Store_id ORDER BY Order_year ASC, Month_number ASC) AOV_one_month,
LAG(Store_AOV, 2) OVER(PARTITION BY Store_id ORDER BY  Order_year ASC, Month_number ASC) AOV_two_month,
LAG(Store_AOV, 3) OVER(PARTITION BY Store_id ORDER BY  Order_year ASC, Month_number ASC) AOV_three_month
FROM CTE_Store
)
SELECT 
Store_id,
Store_name,
Order_year,
Month_number,
Month_Name,
Store_revenue,
Revenue_one_month,
Revenue_two_month,
Revenue_three_month,
Store_AOV,
AOV_One_month,
AOV_two_month,
AOV_three_month
FROM CTE_Previous_months
WHERE Order_year IS NOT NULL AND 
Store_revenue < Revenue_one_month AND
Revenue_one_month < Revenue_two_month AND
Revenue_two_month < Revenue_three_month AND
Store_AOV > AOV_one_month AND
AOV_one_month > AOV_two_month AND
AOV_two_month > AOV_three_month;

--identify products that generate 80% of total revenue within each region.
WITH CTE_Region AS 
(
SELECT 
Region,
Product_id,
Product_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) Product_revenue
FROM dbo.Pharma_staging
GROUP BY 
Region,
Product_id,
Product_name
),
CTE_Regional_revenue AS
(
SELECT 
Region,
Product_id,
Product_name,
Product_revenue,
SUM(Product_revenue) OVER(PARTITION BY Region) Regional_revenue,
SUM(Product_revenue) OVER(PARTITION BY Region ORDER BY Product_revenue DESC) Cumulative_Revenue
FROM CTE_Region
),
CTE_Cumulative_percentage AS
(
SELECT 
Region,
Product_id,
Product_name,
Product_revenue,
Cumulative_revenue,
CAST(Cumulative_revenue / Regional_revenue * 100 AS DECIMAL (12,2)) AS Cumulative_percentage,
Regional_revenue
FROM CTE_Regional_revenue
)
SELECT 
Region,
Product_id,
Product_name,
Product_revenue,
Cumulative_revenue,
Cumulative_percentage
FROM CTE_Cumulative_percentage
WHERE Cumulative_percentage <= 80;

--identify customers whose spending has increased for three consecutive months, 
--even though their order frequency has decreased over the same period.
WITH CTE_Calendar AS
(
SELECT CAST('2025-01-01' AS DATE) AS Month_start
UNION ALL
SELECT DATEADD(MONTH, 1, Month_start) 
FROM CTE_Calendar
WHERE Month_start < '2025-12-01'
),
CTE_Customer AS
(
SELECT 
Customer_id,
YEAR(Order_date) Order_year,
DATEPART(MONTH, Order_date) Month_number,
DATENAME(MONTH, Order_date) Month_name,
CAST(SUM(Revenue) AS DECIMAL (12,2)) AS Total_Revenue,
COUNT(DISTINCT Order_id) Order_count 
FROM dbo.Pharma_staging
GROUP BY 
Customer_id,
YEAR(Order_date),
DATEPART(MONTH, Order_date),
DATENAME(MONTH, Order_date)
),
CTE_Customer_calendar AS
( 
 SELECT
        C.Customer_id,
        YEAR(CA.Month_Start) AS Order_year,
        MONTH(CA.Month_Start) AS Month_number,
        COALESCE(M.Total_Revenue, 0) AS Total_Revenue,
        COALESCE(M.Order_count, 0) AS Order_count
    FROM
        (SELECT DISTINCT Customer_id
         FROM dbo.Pharma_staging) C
    CROSS JOIN CTE_Calendar CA
    LEFT JOIN CTE_Customer M
        ON M.Customer_id = C.Customer_id
        AND M.Order_year = YEAR(CA.Month_Start)
        AND M.Month_number = MONTH(CA.Month_Start)
),
CTE_Previous_months AS 
(
SELECT 
Customer_id,
Order_year,
Month_number,
Total_Revenue,
LAG(Total_revenue) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Revenue_one_month,
LAG(Total_revenue, 2) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Revenue_two_month,
LAG(Total_revenue, 3) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Revenue_three_month,
Order_count,
LAG(Order_count) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Order_count_One_month,
LAG(Order_count, 2) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Order_count_two_month,
LAG(Order_count, 3) OVER(PARTITION BY Customer_id ORDER BY Order_year ASC, Month_number ASC) Order_count_three_month
FROM CTE_Customer_Calendar
)
SELECT 
Customer_id,
Order_year,
Month_number,
Total_Revenue,
Revenue_one_month,
Revenue_two_month,
Revenue_three_month,
Order_count,
Order_count_One_month,
Order_count_two_month,
Order_count_three_month
FROM CTE_Previous_months
WHERE 
Total_revenue > Revenue_one_month AND
Revenue_one_month > Revenue_two_month AND
Revenue_two_month > Revenue_three_month AND
Order_count < Order_count_One_month
AND Order_count_One_month < Order_count_two_month
AND Order_count_two_month < Order_count_three_month;
































































