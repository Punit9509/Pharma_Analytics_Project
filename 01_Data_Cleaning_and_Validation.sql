SELECT * FROM dbo.Pharma_raw

--CREATE A Staging table and upload all the data from pharma_raw to Pharma_staging
SELECT * INTO dbo.Pharma_staging FROM dbo.Pharma_raw;

SELECT * FROM dbo.Pharma_staging

-- Check for the Grain of the table and for the duplicate rows
-- Order_id - Find out all values unique or not
-- Order_date - Find out that all dates should be in the same format and datatype should be date
-- Customer_id - Find out all customer_id unique or not
-- Customer name - Check the Leading or trailing space and all name should be in the same punctuation
-- Product_id - Check all the Product_id are unique or not
-- Product_name - Check and count all the distinct Product name, leading and trailing space and text punctuation
-- Category - Check all the distinct categories, leading and trailing space and text punctuation
-- Quantity - Check the data type, it should be Int and quantity should not be les than zero
-- List_Price - Check for the data type, it should be as INT and price should not be less than zero
-- Discount - Check the discount it should not be greater than 1 and less than zero
-- Cost_price - The data type should be INT, and should not be less than zero
-- Revenue - The data type should be INT
-- Profit - The data type should be INT
-- Salesperson_id - Check the ID, It should be unique
-- Salesperson name - Check for the Leading and trailing space, and punctuation
-- Store_id - Check for the Uniqueness
-- Store_name - Check for the distinct name
-- Region - Check for the distinct Region name, leading & trailing space and punctuation
-- City - Check for the Unique city name, leading and trailing space, punctuation
-- Payment Method - Check for the Distinct Payment method
-- Order_status - Check for the Distinct Order status

--Check whether the order id is unique or not--
SELECT * FROM Pharma_staging;

SELECT 
COUNT(Order_id) Cnt,
COUNT(DISTINCT Order_id) D_Cnt
FROM dbo.pharma_staging;

-- FIND THE GRAIN 
SELECT 
Order_id,
Product_id
FROM dbo.Pharma_staging

SELECT 
Order_id,
COUNT(DISTINCT Product_id) Product_Count
FROM dbo.Pharma_staging
GROUP BY Order_id
HAVING COUNT(DISTINCT Product_id) > 1;

SELECT 
Order_id,
Product_id,
COUNT(*) AS occurance_cnt
FROM dbo.Pharma_staging 
GROUP BY 
Order_id,
Product_id
HAVING COUNT(*) > 1

WITH CTE_Duplicate AS 
(
SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY 
Order_id,
Order_date,
Customer_id,
Customer_name,
Product_id,
Product_Name,
Category,
Quantity,
List_Price,
Discount,
Cost_Price,
Revenue,
Profit,
Salesperson_id,
Salesperson_name,
Store_id,
Store_name,
Region,
'State',
City,
Payment_Method,
Order_status
ORDER BY (SELECT NULL)) ROW_NUM
FROM dbo.Pharma_staging
)
SELECT 
ROW_NUM,
COUNT(*) AS Row_count
FROM CTE_Duplicate
WHERE ROW_NUM > 1
GROUP BY ROW_NUM;

SELECT COUNT(*) AS Cnt FROM dbo.Pharma_staging

SELECT 
Order_id,
COUNT(DISTINCT Product_id) P_Count
FROM dbo.Pharma_staging
GROUP BY Order_id
HAVING COUNT(DISTINCT Product_id) > 1

SELECT * FROM dbo.Pharma_staging

SELECT DISTINCT Order_status FROM dbo.Pharma_staging

SELECT 
order_id,
COUNT(Order_id) Cnt
FROM dbo.Pharma_staging 
GROUP BY Order_id
HAVING COUNT(Order_id) > 1;

--We have identified that 120 rows are duplicate, delete those 120 rows--

WITH CTE_Duplicate AS 
(
SELECT 
*,
row_number() OVER( PARTITION BY
Order_id,
Order_date,
Customer_id,
Customer_name,
Product_id,
Product_Name,
Category,
Quantity,
List_Price,
Discount,
Cost_Price,
Revenue,
Profit,
Salesperson_id,
Salesperson_name,
Store_id,
Store_name,
Region,
'State',
City,
Payment_Method,
Order_status
ORDER BY (SELECT NULL)) Row_num
FROM dbo.Pharma_staging
)
SELECT * FROM CTE_Duplicate WHERE Row_num > 1;

SELECT COUNT (*) FROM dbo.Pharma_staging

--Find the Null values --
SELECT 
Order_id
FROM dbo.Pharma_staging 
WHERE Order_id IS NULL

SELECT 
Order_date
FROM dbo.Pharma_staging 
WHERE Order_date IS NULL

SELECT 
Customer_id
FROM dbo.Pharma_staging
WHERE Customer_id IS NULL

SELECT
Customer_name 
FROM dbo.Pharma_staging 
WHERE Customer_name IS NULL

SELECT * FROM dbo.Pharma_staging
SELECT 
Customer_id,
COUNT(*) Customer_id_count,
COUNT(Customer_name)
FROM dbo.Pharma_staging 
GROUP BY Customer_id
HAVING COUNT(*) > COUNT(Customer_name) AND COUNT(Customer_name) > 0

SELECT 
Customer_id,
Customer_name,
COUNT (*) Cnt,
COUNT(Customer_name) non_null_count 
FROM dbo.pharma_staging WHERE Customer_id = 3913
GROUP BY 
Customer_id,
Customer_name;

SELECT 
Customer_id,
COUNT(DISTINCT Customer_name) 
FROM dbo.pharma_staging 
GROUP BY Customer_id
HAVING COUNT(DISTINCT Customer_name) > 1

SELECT 
Customer_id,
Customer_name,
COUNT(DISTINCT Customer_name) 
FROM dbo.Pharma_staging 
GROUP BY Customer_id, Customer_name
HAVING COUNT(DISTINCT Customer_name) >1

SELECT 
COUNT(DISTINCT UPPER(Customer_name)) Cnt_Upper
FROM dbo.pharma_staging

SELECT COUNT(LOWER(Customer_name)) Cnt_Lower FROM dbo.Pharma_staging

SELECT DISTINCT
A.Customer_id,
A.Customer_name AS Missing_name,
B.Customer_name AS Available_name
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.Customer_id = B.Customer_id
WHERE A.Customer_name IS NULL AND B.Customer_name IS NOT NULL

SELECT 
B.Customer_id,
COUNT(DISTINCT B.Customer_name) AS Name_count
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.customer_id = B.Customer_id
WHERE A.Customer_name IS NULL AND B.Customer_name IS NOT NULL 
GROUP BY B.Customer_id 
HAVING COUNT(DISTINCT B.Customer_name) > 1

UPDATE A 
SET A.Customer_name = B.Customer_name
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.Customer_id = B.customer_id 
WHERE A.Customer_name IS NULL AND B.customer_name IS NOT NULL

SELECT * FROM dbo.Pharma_staging
SELECT List_price FROM dbo.Pharma_staging WHERE List_price IS NULL

SELECT DISTINCT
A.Product_id,
A.List_price,
B.List_price
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.Product_id = B.Product_id 
WHERE A.List_price IS NULL AND B.List_price IS NOT NULL

SELECT 
AVG(List_price) FROM dbo.Pharma_staging

SELECT * FROM dbo.Pharma_staging

SELECT Store_name, store_id FROM dbo.Pharma_staging WHERE Store_id IS NULL

SELECT DISTINCT
A.Store_name,
A.Store_id,
B.Store_id
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.Store_name = B.Store_name
WHERE A.Store_id IS NULL AND B.Store_id IS NOT NULL

UPDATE A
SET A.Store_id = B.Store_id
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
ON A.Store_name = B.store_name
WHERE A.Store_id IS NULL;

-- check the datatypes for all columns--
SELECT 
COLUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Pharma_staging'
ORDER BY ORDINAL_POSITION;

SELECT 
Order_date,
TRY_CONVERT(DATE, Order_date) New_date
FROM dbo.pharma_staging
WHERE Order_date IS NOT NULL AND TRY_CONVERT(DATE, Order_date, 103) IS NULL

SELECT DISTINCT Discount
FROM dbo.Pharma_staging 

SELECT 
Discount,
COUNT(*) Cnt
FROM dbo.pharma_staging 
WHERE Discount = '-0.1'
GROUP BY Discount

SELECT
AVG(Quantity) FROM dbo.Pharma_staging 

SELECT 
Order_status,
COUNT(*) AS Row_cnt
FROM dbo.Pharma_staging 
WHERE Quantity < 0
GROUP BY Order_status

SELECT 
COUNT(*) AS Row_cnt
FROM dbo.pharma_staging
WHERE Quantity < 0 AND Order_status = 'Completed' AND Revenue > 0

SELECT * FROM dbo.Pharma_staging

SELECT
DISTINCT Payment_method FROM dbo.pharma_staging

SELECT 
COUNT(*) Cnt
FROM dbo.Pharma_staging 
WHERE Salesperson_name IS NULL OR TRIM(Salesperson_name) = ' '

SELECT 
COUNT(*) Cnt
FROM dbo.pharma_staging 
WHERE Salesperson_name <> TRIM(Salesperson_name);

SELECT 
Salesperson_id,
Salesperson_name,
COUNT(DISTINCT Salesperson_name) AS Cnt
FROM dbo.Pharma_staging 
GROUP BY
Salesperson_id,
Salesperson_name

SELECT 
Salesperson_id,
COUNT(DISTINCT UPPER(Salesperson_name)) Cnt
FROM dbo.Pharma_staging 
GROUP BY Salesperson_id
HAVING COUNT(DISTINCT UPPER(Salesperson_name)) > 1;

SELECT 
Customer_id,
COUNT(DISTINCT UPPER(Customer_name)) Cnt
FROM dbo.pharma_staging 
GROUP BY Customer_id
HAVING COUNT(DISTINCT UPPER(Customer_name)) > 1;

SELECT COUNT(*) AS Cnt
FROM dbo.Pharma_staging 
WHERE Product_name IS NULL OR TRIM(Product_name) = '';

SELECT 
Product_id,
COUNT(DISTINCT UPPER(Product_name)) Cnt
FROM dbo.Pharma_staging 
GROUP BY Product_id
HAVING COUNT(DISTINCT UPPER(Product_name)) > 1

SELECT 
Category 
FROM dbo.pharma_staging 
WHERE Category IS NULL OR TRIM(Category) = '';

SELECT DISTINCT Category FROM dbo.Pharma_staging

SELECT DISTINCT Store_name FROM dbo.pharma_staging

SELECT 
Store_name 
FROM dbo.pharma_staging 
WHERE Store_name IS NULL OR TRIM(Store_name) = '';

SELECT 
Store_id,
COUNT(DISTINCT UPPER(Store_name)) cnt
FROM dbo.Pharma_staging 
GROUP BY Store_id
HAVING COUNT(DISTINCT UPPER(Store_name)) > 1

SELECT DISTINCT Region FROM dbo.Pharma_staging

SELECT DISTINCT City FROM dbo.Pharma_staging

SELECT 
Order_date,
COUNT(*) AS Cnt
FROM dbo.Pharma_staging 
WHERE TRY_CONVERT(Date, Order_date) IS NULL
GROUP BY Order_date

UPDATE A
SET A.Customer_Name = B.Customer_Name
FROM dbo.Pharma_staging AS A
JOIN dbo.Pharma_staging AS B
    ON A.Customer_ID = B.Customer_ID
WHERE A.Customer_Name IS NULL
  AND B.Customer_Name IS NOT NULL;

  ALTER TABLE dbo.Pharma_staging
ALTER COLUMN Order_Date DATE;

ALTER TABLE dbo.Pharma_staging
ALTER COLUMN Discount DECIMAL(10,2);

SELECT * FROM dbo.Pharma_staging

SELECT 
Order_id,
COUNT(Order_id) Cnt
FROM dbo.Pharma_staging
GROUP BY Order_id
HAVING COUNT(Order_id) > 1

SELECT 
Order_id,
Product_id,
COUNT(*) Cnt
FROM dbo.Pharma_staging
GROUP BY Order_id, Product_id
HAVING COUNT(*) > 1

SELECT Order_id FROM dbo.pharma_staging WHERE order_id IS NULL

SELECT 
*
FROM dbo.Pharma_raw
WHERE Order_date IS NOT NULL
AND TRY_CONVERT(Date, Order_date) IS NULL

SELECT * FROM dbo.Pharma_raw WHERE Order_id = 504170

SELECT Customer_id FROM dbo.Pharma_raw WHERE Customer_id IS NULL

SELECT Customer_id,
COUNT( DISTINCT Customer_id) Cnt
FROM dbo.Pharma_raw
GROUP BY Customer_id
HAVING Count(DISTINCT customer_id) > 1;

SELECT 
Customer_id,
COUNT(DISTINCT Customer_name) Cnt
FROM dbo.Pharma_staging
GROUP BY Customer_id 
HAVING COUNT(Distinct Customer_name) > 1

SELECT * FROM dbo.Pharma_staging WHERE Customer_id = 999999

SELECT customer_name FROM dbo.Pharma_staging

UPDATE dbo.pharma_staging 
SET Customer_name = 'Customer_x' WHERE Customer_name LIKE 'CUSTOMER_X';

SELECT 
Product_id 
FROM dbo.pharma_raw
WHERE Product_id IS NULL

SELECT 
Product_id,
COUNT(DISTINCT Product_name) cnt
FROM dbo.Pharma_staging
GROUP BY Product_id
HAVING COUNT(DISTINCT Product_name) > 1

SELECT * FROM pharma_staging
SELECT DISTINCT Category FROM dbo.Pharma_staging

SELECT 
Product_name,
COUNT(DISTINCT UPPER(Category)) Up,
COUNT(DISTINCT Category) 
FROM dbo.Pharma_staging
GROUP BY Product_name, Category;

SELECT 
UPPER(Category) AS Cat,
COUNT(DISTINCT Category) AS Cat_var
FROM dbo.Pharma_staging 
GROUP BY UPPER(Category)
HAVING COUNT(DISTINCT Category) > 1;

SELECT 
*
FROM dbo.Pharma_staging 
WHERE Quantity <= 0

SELECT * FROM dbo.Pharma_raw WHERE List_price IS NULL

SELECT list_price FROM dbo.Pharma_raw WHERE list_price <= 0

SELECT MAX(List_price) FROM dbo.Pharma_raw

SELECT 
*
FROM dbo.pharma_raw 
WHERE Product_id = 1014

SELECT 
COLUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Pharma_staging'

SELECT DISCOUNT FROM dbo.Pharma_staging WHERE Discount IS NULL

SELECT * FROM dbo.Pharma_staging WHERE Discount = 0 

SELECT MAX(Discount) FROM dbo.Pharma_staging

SELECT * FROM dbo.Pharma_staging

SELECT Revenue FROM dbo.Pharma_raw WHERE Revenue IS NULL

SELECT 
Product_id,
Product_name,
Quantity,
Revenue
FROM dbo.Pharma_staging 
WHERE Quantity < 0

SELECT 
Revenue,
(Quantity * list_Price) * (1 - Discount) AS Calculated_Revenue
FROM dbo.Pharma_staging

SELECT Profit FROM dbo.Pharma_raw WHERE Profit IS NULL

SELECT
*
FROM dbo.Pharma_raw
WHERE Profit <=0

SELECT
Profit,
Revenue - (Quantity * Cost_price) Calculated_profit
FROM dbo.Pharma_raw
WHERE Profit <= 0

SELECT 
Store_id,
COUNT(DISTINCT Store_name) Cnt
FROM dbo.Pharma_raw
GROUP BY Store_id 
HAVING COUNT(DISTINCT Store_name) > 1;

SELECT 
DISTINCT Store_id 
FROM dbo.pharma_raw
ORDER BY Store_id

SELECT 
COUNT(*) 
FROM dbo.Pharma_raw
WHERE Store_id IS NULL

SELECT 
Store_name,
COUNT(DISTINCT Store_id) Cnt
FROM dbo.Pharma_raw
GROUP BY Store_name

SELECT DISTINCT 
A.Store_id,
A.Store_name,
B.Store_id
FROM dbo.Pharma_raw AS A
JOIN dbo.Pharma_raw AS B
ON A.Store_name = B.Store_name
WHERE A.Store_id IS NULL AND B.Store_id IS NOT NULL

SELECT * FROM dbo.Pharma_raw

SELECT Salesperson_id FROM dbo.Pharma_raw WHERE Salesperson_id IS NULL

SELECT 
Salesperson_id,
COUNT(DISTINCT Salesperson_name) Cnt
FROM dbo.Pharma_raw 
GROUP BY Salesperson_id
HAVING COUNT(DISTINCT Salesperson_name) > 1

SELECT 
* 
FROM dbo.Pharma_raw
WHERE 
Salesperson_name <> TRIM(Salesperson_name)

SELECT DISTINCT City FROM dbo.Pharma_raw

SELECT * FROM dbo.pharma_raw WHERE City <> TRIM(City)

SELECT DISTINCT State FROM dbo.Pharma_raw

SELECT DISTINCT Region FROM dbo.Pharma_raw

SELECT DISTINCT Payment_method FROM dbo.Pharma_raw

SELECT DISTINCT Order_status FROM dbo.Pharma_raw

SELECT COUNT(*) FROM dbo.Pharma_raw
SELECT COUNT(*) FROM dbo.Pharma_staging
