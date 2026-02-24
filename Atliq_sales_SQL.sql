-- We'll be using "sales" database for analysis.
use sales;

-- listing all the tables in "sales' DB.
show tables;

-- Describe each column in "customers" table.
DESCRIBE customers;

-- fixing typo from "custmer_name" to "customer_name". 
ALTER TABLE customers
CHANGE custmer_name customer_name VARCHAR(45);

-- Looking at customers table records.
SELECT * FROM customers;

-- Seeing all retailer stores i.e. our unique customers
SELECT DISTINCT customer_name FROM customers;

-- Types of major customers.
SELECT DISTINCT customer_type FROM customers;

-- Distribution of customer_type in overall transactions.
SELECT c.customer_type, COUNT(*) AS type_count
FROM transactions t
JOIN customers c
ON t.customer_code = c.customer_code
GROUP BY c.customer_type
ORDER BY type_count DESC;

-- Customer type distribution amongst all stores.
SELECT customer_type, COUNT(*) AS customer_count
FROM customers
GROUP BY customer_type;

--------------------------------
SELECT * FROM date;

-- Data from June, 2017 to February, 2020 (4 years).
SELECT DISTINCT year FROM date;

---------------------------------
SELECT * FROM markets;

-- Since we're focusing on India 
DELETE FROM markets
WHERE markets_name In ("New york", "Paris");

-- Zonewise city distribution in India.
SELECT zone, COUNT(markets_name) AS cities
FROM markets
GROUP BY zone;

SELECT zone, markets_name
FROM markets
GROUP BY zone, markets_name
ORDER BY zone ASC;
---------------------------------------
SELECT * FROM products;

SELECT DISTINCT product_type
FROM products;

SELECT product_type, COUNT(product_code) AS product_count
FROM products
GROUP BY product_type;

SELECT p.product_type, COUNT(*) AS type_count
FROM transactions t
JOIN products p
ON t.product_code = p.product_code
GROUP BY p.product_type
ORDER BY type_count DESC;

SELECT p.product_type, SUM(t.sales_amount) AS total_sales
FROM transactions t
JOIN products p
ON p.product_code = t.product_code
GROUP BY p.product_type
ORDER BY total_sales DESC;

-------------------------------------------------
SELECT *
FROM transactions;

SELECT COUNT(*) FROM transactions;

-- Replacing negative value sales_amount with average.  
UPDATE transactions
SET sales_amount = (
    SELECT ROUND(AVG(sales_amount))
    FROM (
        SELECT sales_amount
        FROM transactions
        WHERE sales_amount != -1
    ) AS avg_sales
)
WHERE sales_amount = -1;

SET SQL_SAFE_UPDATES = 0;

-- converting USD currency amount to INR
UPDATE transactions
SET sales_amount = sales_amount * 70.51,
	currency = "INR"
WHERE currency = "USD";

-- top 5 products that generated the highest total sales.
SELECT product_code, SUM(sales_amount) AS Total_sale
FROM transactions
GROUP BY product_code
ORDER BY Total_sale  DESC
LIMIT 5;

-- 2018 had the highest total sales followed by 2019 and 2020 with 2017 having the lowest sales.
SELECT YEAR(order_date) AS Year, ROUND(SUM(sales_amount)) AS Total_sale
FROM transactions
GROUP BY Year
ORDER BY Total_sale DESC;

-- going deeper into monthly total sales in 2018.
SELECT MONTH(order_date) AS Month, ROUND(SUM(sales_amount)) AS Total_sale
FROM transactions
WHERE YEAR(order_date) = 2018
GROUP BY Month
ORDER BY Total_sale DESC;

-- checking which product was sold the most in each month of the year 2018.
SELECT 
    month,
    product_code,
    total_sale
FROM (
    SELECT 
        MONTH(order_date) AS month,
        product_code,
        SUM(sales_amount) AS total_sale,
        RANK() OVER (
            PARTITION BY MONTH(order_date)
            ORDER BY SUM(sales_amount) DESC
        ) AS rnk
    FROM transactions
    WHERE YEAR(order_date) = 2018
    GROUP BY MONTH(order_date), product_code
) ranked
WHERE rnk = 1
ORDER BY month;

-- seeing how much exact sales did Prod040 generate.
SELECT SUM(sales_amount) AS Prod040_total_sale
FROM
(
SELECT *
FROM transactions
WHERE YEAR(order_date) = 2018 AND MONTH(order_date) = 1 AND product_code = "Prod040"
) AS prod040;

-- Top 10 most purchased products.
SELECT product_code, SUM(sales_qty) AS Total_qty
FROM transactions
GROUP BY product_code
ORDER BY Total_qty DESC
LIMIT 10;

-- The cities Delhi NCR, Mumbai, Ahmedabad have consistently been the top 3 in terms of total sales. Meanwhile Bhubaneshwar and Surat were amongst the lowest sales recorders.
SELECT m.markets_name AS City, ROUND(SUM(t.sales_amount)) AS Total_sales
FROM transactions t
JOIN markets m
ON t.market_code = m.markets_code
WHERE YEAR(order_date) = 2020
GROUP BY City
ORDER BY Total_sales DESC;

-- finding which store purchased the most goods in 'Delhi NCR' market.
SELECT c.customer_name, COUNT(c.customer_name) AS store_count
FROM transactions t
JOIN customers c
ON t.customer_code = c.customer_code
JOIN markets m
ON t.market_code = m.markets_code
WHERE m.markets_name = 'Delhi NCR'
GROUP BY c.customer_name
ORDER BY store_count DESC;

-- Top 5 products sold to 'Premium Stores' in 'Delhi NCR'. 
SELECT p.product_code, p.product_type, COUNT(p.product_code) AS product_count
FROM transactions t
JOIN customers c
ON t.customer_code = c.customer_code
JOIN markets m
ON t.market_code = m.markets_code
JOIN products p
ON t.product_code = p.product_code
WHERE m.markets_name = 'Delhi NCR' AND c.customer_name = 'Premium Stores'
GROUP BY p.product_code
ORDER BY product_count DESC
LIMIT 5;