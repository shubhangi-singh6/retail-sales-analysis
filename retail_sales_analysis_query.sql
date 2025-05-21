-- [I] TABLE CREATION

CREATE TABLE sales_store
(
	transaction_id VARCHAR(15),
	customer_id VARCHAR(15),
	customer_name VARCHAR(30),
	customer_age INT,
	gender VARCHAR(15),
	product_id VARCHAR(15),
	product_name VARCHAR(15),
	product_category VARCHAR(15),
	quantiy INT,
	prce FLOAT,
	payment_mode VARCHAR(15),
	purchase_date DATE,
	time_of_purchase TIME,
	status VARCHAR(15)
);


-- [II] DATA POPULATION

SELECT *
FROM sales_store
SET DATEFORMAT dmy
BULK INSERT sales_store
FROM 'C:\Users\garvg\Downloads\sales.csv'  --Replace this path with your original csv path
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n'
		);

-- [III] DATA CLEANING

--To avoid any tampering with the original data, Copy of the table is being used 

 SELECT * FROM sales_store

 SELECT * INTO sales FROM sales_store

 SELECT * FROM sales

 -- Data Cleaning Part
 -- Step 1: To check for any duplicates

 SELECT transaction_id, COUNT(*)
 FROM sales
 GROUP BY transaction_id
 HAVING COUNT(transaction_id) > 1

  /* Duplicate transaction IDs -
		TXN240646
		TXN342128
		TXN626832
		TXN745076
		TXN832908
		TXN855235
		TXN981773 */


 WITH CTE AS (
  SELECT *,
	 ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
  FROM sales
  )
Select * 
 FROM CTE
 WHERE transaction_id IN ('TXN240646', 'TXN342128', 'TXN626832', 'TXN745076','TXN832908', 'TXN855235', 'TXN981773' )
 

 --Step 2 : Correction of Headers

 SELECT * FROM sales

 EXEC sp_rename'sales.quantiy','quantity','COLUMN'

 EXEC sp_rename'sales.prce','price','COLUMN'


 --Step 3 : To check Datatype

 SELECT COLUMN_NAME, DATA_TYPE
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = 'sales'


 --Step 4 : To Check Null Values
   --To check null count

	   DECLARE @SQL NVARCHAR(MAX) = '';

	   SELECT @SQL = STRING_AGG
	   (
			'SELECT''' + COLUMN_NAME + ''' AS ColumnName,
			COUNT(*) AS NullCount
			FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales
			WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
			' UNION ALL '
		)
		WITHIN GROUP (ORDER BY COLUMN_NAME)
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'sales';

	--Execute the dynamic SQL
		EXEC sp_executesql @SQL;

	-- Null Value Treatment

		SELECT * FROM sales
		WHERE 
			transaction_id IS NULL
			OR
			customer_id	IS NULL
			OR
			customer_name IS NULL 
			OR
			customer_age IS NULL 
			OR
			gender IS NULL 
			OR
			product_id IS NULL 
			OR
			product_name IS NULL 
			OR
			product_category IS NULL 
			OR
			quantity IS NULL 
			OR
			price IS NULL 
			OR
			payment_mode IS NULL 
			OR
			purchase_date IS NULL
			OR
			time_of_purchase IS NULL 
			OR
			status IS NULL
			
		DELETE FROM sales
		WHERE transaction_id IS NULL
		
		SELECT * FROM sales
		WHERE customer_name = 'Ehsaan Ram'

		UPDATE sales
		SET customer_id = 'CUST9494'
		WHERE transaction_id = 'TXN977900'


		SELECT * FROM sales
		WHERE customer_name = 'Damini Raju'

		UPDATE sales
		SET customer_id = 'CUST1401'
		WHERE transaction_id = 'TXN985663'


		SELECT * FROM sales
		WHERE customer_id = 'CUST1003'

		UPDATE sales
		SET customer_name = 'Mahika Saini',
			customer_age = '35',
			gender = 'Male'
		WHERE transaction_id = 'TXN432798'


	SELECT * FROM sales

-- Step 5 : Data Cleaning
	
	SELECT DISTINCT gender -- To get different genders originally mentioned
	FROM sales

	UPDATE sales
	SET gender = 'Male'
	WHERE gender = 'M'

	UPDATE sales
	SET gender = 'Female'
	WHERE gender = 'F'

	SELECT DISTINCT payment_mode -- To get different payment modes mentioned originally  
	FROM sales

	UPDATE sales
	SET payment_mode = 'Credit Card'
	WHERE payment_mode = 'CC'


-- [IV] DATA ANALYSIS

-- 1. What are the top 5 most selling products by quantity

	SELECT * FROM sales

		--Business Problem : The products most in demand are not known
		--Business Impact : Helps prioritize stock and boost sales through targeted promotions

	SELECT DISTINCT status
	FROM sales

	SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
	FROM sales
	WHERE status = 'delivered'
	GROUP BY product_name
	ORDER BY total_quantity_sold DESC

		

-- 2. Which top 5 products are most frequently cancelled

	SELECT * FROM sales
		
		--Business Problem : Frequent cancellations affecyt revenue and customer trust
		--Business Impact : Identify poor-performing products to improve quality or remove from catalog
	
	SELECT TOP 5 product_name, SUM(quantity) AS total_products_cancelled
	FROM sales
	WHERE status = 'cancelled'
	GROUP BY product_name
	ORDER BY total_products_cancelled DESC


-- 3. What time of the day has the highest number of purchase

	SELECT * FROM sales

		--Business Problem : Find peak sales time
		--Business Impact : Optimize staffing, promotions and server loads

		SELECT
			CASE
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 5 AND 12 THEN 'MORNING'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 18 THEN 'AFTERNOON'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 0 THEN 'EVENING'
			END AS time_of_day,
			COUNT(*) AS total_orders
		FROM sales
		GROUP BY 
			CASE
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 5 AND 12 THEN 'MORNING'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 18 THEN 'AFTERNOON'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 0 THEN 'EVENING'
			END
		ORDER BY total_orders DESC



-- 4. Who are the top 5 highest spending customers
	
	SELECT * FROM sales

		--Business Problem : Identify VIP customers
		--Business Impact : Personalised offers, loyalty rewards and retetntion

	SELECT TOP 5 customer_id, 
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_amount_spent
	FROM sales
	GROUP BY customer_id
	ORDER BY total_amount_spent DESC



-- 5. Which product categories generate the 5 highest revenue

	SELECT * FROM sales

		--Business Problem : Identify top-performing product categories
		--Business Impact : Refine product strategy, supply chain and promotions allowing the business to invest more in high-margin or high-demand categories

	SELECT product_category, 
				FORMAT(SUM(price*quantity),'C0','en-IN') AS total_revenue
	FROM sales
	GROUP BY product_category
	ORDER BY SUM(price*quantity) DESC

		

-- 6. What is the return/cancellation rate per product category

	SELECT * FROM sales

		--Business Problem : Monitor dissatisfaction trends per category 
		--Business Impact : Reduce returns , Improve product descriptions/expections; Helps identify and fix product or logistics issues

	--Cancellation
	SELECT product_category, 
		FORMAT(COUNT(CASE WHEN status = 'cancelled' THEN 1 END)*100.0/COUNT(*),'N3') + ' %' AS cancelled_percent
	FROM sales
	GROUP BY product_category
	ORDER BY cancelled_percent DESC

	--Return
	
	SELECT product_category, 
		FORMAT(COUNT(CASE WHEN status = 'returned' THEN 1 END)*100.0/COUNT(*),'N3') + ' %' AS returned_percent
	FROM sales
	GROUP BY product_category
	ORDER BY returned_percent DESC

		


-- 7. What is the most preferred payment mode
 
	SELECT * FROM sales

		--Business Problem : Know which payment option customers prefer the most
		--Business Impact : Streamline payment processing and prioritize popular modes

	SELECT TOP 1 payment_mode, COUNT(*) AS preferred_payment
	FROM sales
	GROUP BY payment_mode
	ORDER BY preferred_payment DESC

		


-- 8. How does age group affect the purchasing behaviour

	SELECT * FROM sales

		--Business Problem : Understanding customer demographics
		--Business Impact : Targeted marketing and product recommendations by age group

	--Finding the total customer range
	SELECT MIN(customer_age), MAX(customer_age)
	FROM sales

	SELECT 
		CASE
			WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
			WHEN customer_age BETWEEN 25 AND 35 THEN '25-35'
			WHEN customer_age BETWEEN 35 AND 50 THEN '35-50'
			ELSE '50+'
		END AS customer_age,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
	FROM sales
	GROUP BY CASE
			WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
			WHEN customer_age BETWEEN 25 AND 35 THEN '25-35'
			WHEN customer_age BETWEEN 35 AND 50 THEN '35-50'
			ELSE '50+'
		END
	ORDER BY SUM(price*quantity) DESC

		

-- 9. What is the monthly sales trend

	SELECT * FROM sales

		--Business Problem : Sales fluctuations go unnoticed
		--Business Impact : Plan inventory and marketing according to seasonal trends

	--Method 1

	SELECT 
		FORMAT(purchase_date,'yyyy-MM') AS Month_Year,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
		SUM(quantity) AS total_quantity
	FROM sales
	GROUP BY FORMAT(purchase_date,'yyyy-MM')

	--Method 2

	SELECT
		YEAR(purchase_date) AS Years,
		MONTH(purchase_date) AS Months,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
		SUM(quantity) AS total_quantity
	FROM sales
	GROUP BY YEAR(purchase_date),
		    MONTH(purchase_date) 
	ORDER BY Years DESC, Months DESC

		

-- 10. Are certain genders buying products more from specific product categories

	SELECT * FROM sales

		--Business Problem : Gender-based product preferences
		--Business Impact : Personalised ads, gender-focused campaigns
	
	--Method 1

	SELECT gender, product_category, COUNT(product_category) AS total_purchase
	FROM sales
	GROUP BY gender, product_category
	ORDER BY gender

	--Method 2

	SELECT *
	FROM (
		SELECT gender, product_category
		FROM sales
		) AS source_table
	PIVOT (
		COUNT(gender)
		FOR gender IN ([Male],[Female])
		) AS pivot_table
	ORDER BY product_category

		




