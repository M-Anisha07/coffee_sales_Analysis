create database coffee_shop_db;
use coffee_shop_db;
select * from coffee_shop_sales;


UPDATE coffee_shop_sales
SET transaction_date = CONVERT(date, transaction_date, 105);

--DATA TYPES OF DIFFERENT COLUMNS

EXEC sp_help coffee_shop_sales;

--TOTAL SALES

select sum(unit_price*transaction_qty) as total_sales 
from coffee_shop_sales;

select sum(unit_price*transaction_qty) as total_sales 
from coffee_shop_sales
where
month(transaction_date)=5;   --may month

select concat(round(sum(unit_price*transaction_qty)/1000,0),'K') as total_sales 
from coffee_shop_sales
where
month(transaction_date)=3; --march month

--TOTAL SALES KPI - MOM DIFFERENCE AND MOM 
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty),0) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

--TOTAL QUANTITY SOLD
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5; -- for month of (CM-May)

--TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty),0) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


--CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS

SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023

--SALES TREND OVER PERIOD

    SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;


--DAILY SALES FOR MONTH SELECTED

SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

--COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;

--SALES BY WEEKDAY / WEEKEND:

SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) 
         THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
       WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) 
        THEN 'Weekends'
        ELSE 'Weekdays'
    END;

--SALES BY STORE LOCATION
SELECT 
store_location,
SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC


--SALES BY PRODUCT CATEGORY

SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC


--SALES BY PRODUCTS (TOP 10)
SELECT TOP 10
    product_type,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC;


--SALES BY DAY | HOUR

    SELECT 
        ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales,
        SUM(transaction_qty) AS Total_Quantity,
        COUNT(*) AS Total_Orders
    FROM coffee_shop_sales
    WHERE 
        DATENAME(WEEKDAY, transaction_date) = 'Tuesday'
        AND DATEPART(HOUR, transaction_time) = 8
        AND MONTH(transaction_date) = 5;

--SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

SELECT 
    DATENAME(WEEKDAY, transaction_date) AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DATENAME(WEEKDAY, transaction_date),
         DATEPART(WEEKDAY, transaction_date)
ORDER BY DATEPART(WEEKDAY, transaction_date);
       

--GET SALES FOR ALL HOURS FOR MONTH OF MAY

SELECT 
    DATEPART(HOUR, transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY DATEPART(HOUR, transaction_time);