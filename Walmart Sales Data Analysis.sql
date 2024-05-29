
-- Modify data type from date strings to the data formate matching MySQL
ALTER TABLE sales ADD COLUMN record_date DATE;
SET @@session.sql_mode = 'ALLOW_INVALID_DATES';
UPDATE sales
SET record_date = STR_TO_DATE(Date, '%m/%d/%y');
ALTER TABLE sales DROP COLUMN date;
ALTER TABLE sales MODIFY record_date DATE AFTER total;

ALTER TABLE sales ADD COLUMN record_time TIME;
SET @@session.sql_mode = 'ALLOW_INVALID_DATES';
UPDATE sales
SET record_time = STR_TO_DATE(Time, '%H:%i:%s');
ALTER TABLE sales DROP COLUMN time;
ALTER TABLE sales MODIFY record_time TIME AFTER record_date;

ALTER TABLE sales ADD ProductLine TEXT AFTER product_line;

-- Feature Engineering
#time_of_day

ALTER TABLE sales ADD COLUMN time_of_date VARCHAR(20);
ALTER TABLE sales DROP COLUMN time_of_date;
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = (CASE WHEN CAST(record_time AS TIME) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		  WHEN CAST(record_time AS TIME) BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
          ELSE 'Evening'
	 END
     );

#day_name

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = DAYNAME(record_date);

#month_name

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(record_date);

-- Exploratory Data Analysis 
#Generic

##How many unique cities does the data include?
SELECT 
	DISTINCT city
FROM sales;

##In Which city is each branch?
SELECT 
	DISTINCT city, branch
FROM sales;

#Product

##What is the most common payment method?
SELECT 
	payment, COUNT(payment) AS payment_method_count
FROM sales
GROUP BY payment
ORDER BY payment_method_count DESC;

##What is the total revenue by month?
SELECT
	month_name AS month, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

##What month had the largest COGS?
SELECT
	month_name AS month, MAX(cogs) AS highest_cogs
FROM sales
GROUP BY month
ORDER BY highest_cogs;

##What is the city with the largest revenue?
SELECT
	branch, city, SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue;

##Which branch sold more products than average product sold?
SELECT 
	branch, SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

#Customers
##What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

##What is the gender distribution per branch?
SELECT
	branch, gender,
	COUNT(*) as gender_count
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_count DESC;

##Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

#Sales
##Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
