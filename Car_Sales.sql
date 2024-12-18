
SELECT *
FROM car_sales;

-- Q1 = What are the sales or cars in each state?

SELECT
state,
COUNT(*)
FROM car_sales
GROUP BY state; # the answer gives out some errors in the data.

#query for data cleaning, firstly identifying the data input error.
SELECT *
FROM car_sales
WHERE state = '3vwd17aj4fm201708';

#furthermore checking how many affected rows are due to the input or database error.
SELECT *
FROM car_sales
WHERE LENGTH(state) > 2;

#narrowing the data with one common error among all the affected rows.
SELECT *
FROM  car_sales
WHERE body ='Navitgation';

#creating temporary table for analysis
CREATE TEMPORARY TABLE car_sales_valid AS
SELECT *
FROM car_sales
WHERE body != 'Navitgation'; # data had spelling mistake of navigation.

#final query for answer of question 1
SELECT
state,
COUNT(*)
FROM car_sales_valid
GROUP BY state;

-- Q2= Which kind of car are most popular? How many sales are made for each make and model?

SELECT 
make,
model,
COUNT(*)
FROM car_sales_valid
GROUP BY make,model
ORDER BY COUNT(*) DESC;

SELECT *
FROM car_sales_valid
WHERE make = '';

DROP table car_sales_valid;

CREATE TEMPORARY TABLE car_sales_valid AS
SELECT *
FROM car_sales
WHERE body != 'Navitgation'
AND make !='';

SELECT 
make,
model,
COUNT(*)
FROM car_sales_valid
GROUP BY make,model
ORDER BY COUNT(*) DESC;

-- Q3 Are there any differences in sales prices in different states? What's the average sales price in each state?

SELECT 
state,
AVG(sellingprice) AS avg_selling_price
from car_sales_valid
GROUP BY state 
ORDER BY avg_selling_price ASC;

-- Q4 What's the average sales price for car sold in each month?

SELECT *
FROM car_sales_valid;

SELECT saledate
FROM car_sales_valid
LIMIT 1000;

#String manipulation

SELECT saledate,
SUBSTR(saledate, 12,4) AS sale_year,
SUBSTR(saledate, 5,3) AS sale_month,
SUBSTR(saledate, 9,3) AS sale_day,
CASE SUBSTR(saledate,5,3)
	WHEN 'Jan' THEN 1
	WHEN 'Feb' THEN 2
	WHEN 'Mar' THEN 3
	WHEN 'Apr' THEN 4
	WHEN 'May' THEN 5
	WHEN 'Jun' THEN 6
	WHEN 'Jul' THEN 7
	WHEN 'Aug' THEN 8
	WHEN 'Sep' THEN 9
	WHEN 'Oct' THEN 10
	WHEN 'Nov' THEN 11
	WHEN 'Dec' THEN 12
	ELSE 'None'
END AS sale_month
FROM car_sales_valid
LIMIT 1000;

DROP table car_sales_valid; # dropping the table to create again with the new case substr

CREATE TEMPORARY TABLE car_sales_valid AS
SELECT
'year' AS manufactured_year,
make,
model,
trim,
body,
transmission,
vin,
state,
'condition' AS car_condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate,
SUBSTR(saledate, 12,4) AS sale_year,
SUBSTR(saledate, 5,3) AS sale_month,
SUBSTR(saledate, 9,3) AS sale_day,
CAST(CASE SUBSTR(saledate,5,3)
	WHEN 'Jan' THEN 1
	WHEN 'Feb' THEN 2
	WHEN 'Mar' THEN 3
	WHEN 'Apr' THEN 4
	WHEN 'May' THEN 5
	WHEN 'Jun' THEN 6
	WHEN 'Jul' THEN 7
	WHEN 'Aug' THEN 8
	WHEN 'Sep' THEN 9
	WHEN 'Oct' THEN 10
	WHEN 'Nov' THEN 11
	WHEN 'Dec' THEN 12
	ELSE NULL
END AS UNSIGNED) AS sale_month
FROM car_sales
WHERE body != 'Navitgation'
AND make !='';


SELECT *
FROM car_sales_valid;

SELECT 
sale_year,
sale_month,
AVG(sellingprice) AS avg_selling_price
FROM car_sales_valid
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;


-- Q5 Which month of the year has the most sales?

SELECT 
sale_month,
COUNT(*)
FROM car_sales_valid
GROUP BY sale_month
ORDER BY sale_month ASC;

SELECT sale_month,
COUNT(*)
FROM car_sales_valid
GROUP BY sale_month;

SELECT *
FROM car_sales_valid
WHERE sale_month='';

DROP table car_sales_valid;

CREATE TEMPORARY TABLE car_sales_valid AS
SELECT
'year' AS manufactured_year,
make,
model,
trim,
body,
transmission,
vin,
state,
condition AS car_condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate,
SUBSTR(saledate, 12,4) AS sale_year,
SUBSTR(saledate, 5,3) AS sale_month,
SUBSTR(saledate, 9,3) AS sale_day,
CAST(CASE SUBSTR(saledate,5,3)
	WHEN 'Jan' THEN 1
	WHEN 'Feb' THEN 2
	WHEN 'Mar' THEN 3
	WHEN 'Apr' THEN 4
	WHEN 'May' THEN 5
	WHEN 'Jun' THEN 6
	WHEN 'Jul' THEN 7
	WHEN 'Aug' THEN 8
	WHEN 'Sep' THEN 9
	WHEN 'Oct' THEN 10
	WHEN 'Nov' THEN 11
	WHEN 'Dec' THEN 12
	ELSE NULL
END AS UNSIGNED) AS sale_month
FROM car_sales
WHERE body != 'Navitgation'
AND make !=''
AND saledate !='';

SELECT sale_month,
COUNT(*)
FROM car_sales_valid
GROUP BY sale_month;


--6 What are the top 5 selling vehicles for each body type?

SELECT *
FROM car_sales_valid;

#nested queries for the ranking of the top selling vehicles.
SELECT 
make,
model,
body,
num_sales,
body_rank
FROM(
	SELECT 
	make,
	model,
	body,
	COUNT(*) AS num_sales,
	RANK()OVER(PARTITION BY body ORDER BY COUNT(*)DESC) AS body_rank
	FROM car_sales_valid
	GROUP BY make, model, body
	) s
WHERE body_rank <=5
ORDER BY body ASC,num_sales DESC;


-- Q7 Which sales are higher than the average for that car's model,and how much higher are they?


SELECT
make,
model,
vin,
sale_year,
sale_month,
sale_day,
sellingprice
FROM car_sales_valid;

SELECT
make,
model,
vin,
sale_year,
sale_month,
sale_day,
sellingprice,
avg_model,
sellingprice/avg_model AS price_ratio
FROM(
	SELECT
	make,
	model,
	vin,
	sale_year,
	sale_month,
	sale_day,
	sellingprice,
	AVG(sellingprice) OVER(PARTITION BY make,model) AS avg_model 
	FROM car_sales_valid
	)s
WHERE sellingprice > avg_model
ORDER BY price_ratio DESC;

-- Q8 What is the impact of car condition on the sale price?

SELECT 
car_condition
FROM 
car_sales_valid;

SELECT 
CASE 
	WHEN car_condition BETWEEN 0 AND 9 THEN '0 to 9'
	WHEN car_condition BETWEEN 10 AND 19 THEN '10 to 19'
	WHEN car_condition BETWEEN 20 AND 29 THEN '20 to 29'
	WHEN car_condition BETWEEN 30 AND 39 THEN '30 to 39'
	WHEN car_condition BETWEEN 40 AND 49 THEN '40 to 49'
END AS car_condition_bucket,
COUNT(*) AS num_sales,
AVG(sellingprice) AS avg_selling_price
FROM car_sales_valid
GROUP BY car_condition_bucket
ORDER BY car_condition_bucket;

-- Q9 How does the odometer value impact the sale price?

SELECT odometer,
COUNT(*) AS num_sales,
AVG(sellingprice) AS avg_selling_price
FROM car_sales_valid
GROUP BY odometer
ORDER BY odometer ASC;

SELECT Odometer 
FROM
car_sales_valid;

SELECT
CASE
	WHEN odometer < 100000 THEN '0- 99999'
	WHEN odometer < 200000 THEN '100000- 199999'
	WHEN odometer < 300000 THEN '200000- 299999'
	WHEN odometer < 400000 THEN '300000- 399999'
	WHEN odometer < 500000 THEN '400000- 499999'
	WHEN odometer < 600000 THEN '500000- 599999'
	WHEN odometer < 700000 THEN '600000- 699999'
	WHEN odometer < 800000 THEN '700000- 799999'
	WHEN odometer < 900000 THEN '800000- 899999'
	WHEN odometer < 1000000 THEN '900000- 999999'
END AS odometer_bucket,
COUNT(*) AS num_sales,
AVG(sellingprice) AS avg_sale_price
FROM car_sales_valid
GROUP BY odometer_bucket
ORDER BY odometer_bucket ASC;

-- Q10 What is the highest,lowest,and average sellingprice for each brand,and how many different models are sold?
	
SELECT 
make,
COUNT(DISTINCT model) AS num_models,
COUNT(*) AS num_sales,
MIN(sellingprice) AS min_price,
MAX(sellingprice) AS max_price,
AVG(sellingprice) AS avg_price
FROM car_sales_valid
GROUP BY make;





