/*
-- ===========================================================================
-- PROJECT: EXPLORATORY DATA ANALYSIS (EDA)
-- ===========================================================================
-- DESCRIPTION:
-- EDA is the process of "interviewing" the data to understand its structure,
-- quality, and scope before performing advanced analytics.
-- It acts as a final validation step to ensure the Gold Layer adheres to
-- established business rules and relational integrity.
-- PURPOSE OF THESE QUERIES:
-- 1. DATABASE STRUCTURE: Confirming physical tables, schemas, and columns.
-- 2. DIMENSIONS: Identifying unique categories for future segmentation.
-- 3. DATE SCOPE: Establishing the historical boundaries of the dataset.
-- 4. MEASURES: Calculating high-level "Big Numbers" like total sales and counts.
-- 5. MAGNITUDE: Comparing performance across different dimensions (Gender, Country).
-- 6. RANKING: Identifying top and bottom performers to support decision-making.
-- ===========================================================================
*/

-- STEP 1: EXPLORE DATABASE STRUCTURE - First step when doing EDA is to explore the database (views ,columns, etc).

-- Explore All Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

--STEP 2 EXPLORE DIMENSIONS EXPLORATION: Identifying the unique values (or categories) in each dimension. Recognizing how data might be grouped or segmented,which si useful for later analysis. (DISTINCT FUNCTION)

-- Exploring the distinct countries in the gold.dim_customers view
SELECT DISTINCT country FROM gold.dim_customers

-- Explore All Product Categories "The Major Division"
SELECT DISTINCT category, sub_category,product_name FROM gold.dim_products
ORDER BY 1,2,3


-- STEP 3 DATE EXPLORATION: Identify the earliest and latest dates (boundaries). Understand the scope of data aand the timespan. (MIN/MAX (Date Dimension))

-- Find the date of the first and last order
-- How many years of sales are available

SELECT 
	MIN(order_date) first_order_date,
	MAX(order_date) last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) order_range_months
FROM gold.fact_sales

-- Find the oldest and youngest customer
-- Find the age range between the youngest and oldest customer
SELECT
	MIN(birth_date) youngest_birthdate,
	MAX(birth_date) oldest_birthdate,
	DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_age,
	DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_age,
	DATEDIFF(YEAR, MIN(birth_date), MAX(birth_date)) AS age_range
FROM gold.dim_customers


-- STEP 4 MEASURES EXPLORATION: Calculate the key metric of the business. Highest level of aggregation | Lowest level of details. (Aggregate Functions...SUM, AVG,COUNT, etc)

SELECT * FROM gold.fact_sales
SELECT * FROM gold.dim_customers

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS items_sold FROM gold.fact_sales 

-- Find the average selling price
SELECT AVG(price) AS average_price FROM gold.fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales

-- Find the Total number of Products
SELECT COUNT(product_key) AS total_products FROM gold.fact_sales
SELECT COUNT(product_name) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products

-- Find the Total number of Customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Find the Total number of Customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales
 
 -- Generate a Report that shows all key metrics of the business
 
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders' AS measure_name, COUNT(order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Product' AS measure_name, COUNT(product_key) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers


-- STEP 5 MAGNITUDE: comparing the measure values by categories. (Aggregate a measure, group by dimension)

-- Find the total customers by countries

SELECT 
	country,
	COUNT(customer_key) AS total_customers -- aggregate measure
FROM gold.dim_customers
GROUP BY country -- group measure by dimension
ORDER BY total_customers DESC

-- Find the total customers by gender

SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find the total products by category
SELECT
	category,
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average cost in each category?
SELECT
	category,
	AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

-- What is the total revenue generated for each category?
SELECT
	p.category,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Find total revenue is generated by each customer
SELECT * FROM gold.fact_sales
SELECT * FROM gold.dim_customers

SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.customer_key, 
	c.first_name, 
	c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold items across countries?

SELECT 
	c.country,
	SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC

-- How many male customers have order products from the bike category
-- What was the total sum of sales based on the number of male customers

SELECT 
	c.gender,
	p.category,
	SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.category = 'Bikes' AND c.gender = 'Male'
GROUP BY c.gender, p.category
ORDER BY total_sales DESC

-- STEP 6 RANKING ANALYSIS: Order the values of dimensions by measures. Top N performers | Bottom N Performers (Ranks(Dimension) By Aggregated(Measure))

-- Which 5 products generate the highest revenue?

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT * FROM(
	SELECT 
	p.product_name,
	SUM(f.sales_amount) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products 
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name)t
WHERE rank_products <= 5

-- What are the 5 worst_performing products in terms of sales?

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 

-- Find the top 10 customer who have generated the highes revenue

SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.customer_key, 
	c.first_name, 
	c.last_name
ORDER BY total_revenue DESC

-- The 3 customers with the fewest orders placed

SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
	c.customer_key, 
	c.first_name, 
	c.last_name
ORDER BY total_revenue