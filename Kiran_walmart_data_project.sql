create database walmartsalesdata;
show databases;
use walmartsalesdata;
create table emp(invoice_id varchar(30),
branch varchar(5),
city varchar(30),
customer_type varchar(30),
gender varchar(10),
product_line varchar (100),
unit_price double,
quantity int,
VAT double,
total double,
date_of_joining DATE,
time_of_joining TIME,
payment_method varchar(30),
cogs double,
gross_margin_percentage double,
gross_income double,
rating double);

SHOW TABLES;

-- TO check is their any null values are present in the table
SELECT invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, VAT, total, date_of_joining, time_of_joining, payment_method, cogs, gross_margin_percentage, gross_income, rating
FROM emp
WHERE invoice_id IS NULL 
   OR branch IS NULL 
   OR city IS NULL 
   OR customer_type IS NULL 
   OR gender IS NULL 
   OR product_line IS NULL 
   OR unit_price IS NULL 
   OR quantity IS NULL 
   OR VAT IS NULL 
   OR total IS NULL 
   OR date_of_joining IS NULL 
   OR time_of_joining IS NULL 
   OR payment_method IS NULL 
   OR cogs IS NULL 
   OR gross_margin_percentage IS NULL 
   OR gross_income IS NULL 
   OR rating IS NULL;
-- Adding a new column into the table Named time_of_day

ALTER TABLE emp
ADD time_of_day VARCHAR(100); 

/* Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and
Evening. This will help answer the question on which part of the day most sales are made.*/

SET SQL_SAFE_UPDATES=0;
Update emp
SET time_of_day = CASE
	WHEN time(time_of_joining) BETWEEN '00:00:00' AND '11:59:00' THEN "Morning"
    WHEN time(time_of_joining) BETWEEN '12:00:00' AND '17:59:00' THEN "Afternoon"
    ELSE "Evening"
    END; 
/* Add a new column named day_name that contains the extracted days of the week on which the
given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which
walmartsalesdataweek of the day each branch is busiest. */

ALTER TABLE emp
ADD COLUMN day_name VARCHAR(30);
Update emp
SET day_name=date_format(date_of_joining,'%a');
/* %a	Abbreviated weekday name (Sun to Sat)*/

/* Add a new column named month_name that contains the extracted months of the year on which the
given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most
sales and profit.
 */ 
 
ALTER TABLE emp
ADD COLUMN month_name VARCHAR(30);
SET SQL_SAFE_UPDATES=0;
UPDATE emp
SET month_name=DATE_FORMAT(date_of_joining,'%b');
/* %b	Abbreviated month name (Jan to Dec) */

-- Generic Questions
-- How many unique cities does the data have?

SELECT DISTINCT city FROM emp;

-- In which city is each branch?

SELECT city,branch
FROM emp
GROUP BY city,branch;

/* Product 
How many unique product lines does the data have?. */

SELECT product_line,COUNT(distinct product_line)
from emp
group by product_line;

-- What is most common payment method?.

SELECT payment_method,count(payment_method)
FROM emp
GROUP BY payment_method LIMIT 1;

-- What is the most selling product line?

select product_line, sum(quantity) as quantity_sold
from emp
group by product_line
order by quantity_sold desc limit 1;

-- What is the total revenue by month?

SELECT month_name, sum(total) as revenue
from emp
group by month_name
order by  revenue desc;
-- or 
select month_name AS Month,
sum(Unit_price * Quantity) AS Revenue
from emp
group by Month
order by Revenue desc;

-- What month had the largest COGS?
-- formula >>> COGS = unitsPrice * quantity
select product_line,sum(unit_price * quantity) as largest_cogs 
from emp
group by product_line 
order by largest_cogs desc limit 1;

-- or 
select product_line,SUM(cogs) as largest_cogs
from emp
group by product_line
order by largest_cogs DESC limit 1;

-- What product line had the largest revenue?

select product_line,SUM(unit_price * quantity) as Revenue
from emp
group by Product_line
order by Revenue DESC limit 1;

-- What is the city with the largest revenue?

select city,sum(unit_price*quantity) as revenue
from emp
group by city
order by revenue desc limit 1;
-- or 
select city, max(total) as revenue
from emp
group by city
order by revenue desc limit 1;

-- What product line had the largest VAT?

select product_line,max('tax5%' * cogs)
from emp
group by product_line
order by max('tax5'* cogs) desc limit 1;
-- or
select product_line, sum('tax 5%' * cogs) as total_vat
from emp 
group by product_line
order by total_vat desc limit 1;

-- Fetch each product line and add a column to those product line showing "Good","Bad".Good if its greaterthan average sales

select product_line,
       avg(total) av,
	if(
       avg(total)>(select avg(total)from emp),
       "Good",
       "Bad"
       ) as cat
from emp 
group by product_line;

-- or 
select product_line,avg(total) total_avg,
if(avg(total)>(select avg(total) from emp),"Good","Bad") as product_charactor
from emp
group by product_line
order by total_avg desc;

-- or

SELECT 
    product_line,
    AVG(unit_price * quantity) AS Average_sales,
    CASE 
        WHEN AVG(unit_price * quantity) > (SELECT AVG(unit_price * quantity) FROM emp) THEN 'Good'
        ELSE 'Bad'
    END AS Category
FROM emp
GROUP BY 
    product_line;
	-- AVERAGE
SELECT AVG(unit_price * quantity) AS SALES_AVG
from  emp;

-- Which branch sold more products than average product sold?

select branch,avg(quantity)
from emp
group by branch
having avg(quantity)>(select avg(quantity) from emp);

/* The HAVING clause enables users to filter the results based on the groups specified. */

-- What is the most common product line by gender?

select product_line,gender, count(*)  as comman
from emp
group by product_line,gender
order by comman desc limit 1;

-- What is the average rating of each product line?

select product_line,avg(rating) as total_rating
from emp
group by product_line
order by total_rating;

-- Sales

-- Number of sales made in each time of the day per weekday

select sum(quantity),time_of_day
from emp
group by time_of_day;

-- Which of the customer types brings the most revenue?

select customer_type,sum(total) as most_revenue
from emp
group by customer_type
order by most_revenue desc limit 1;

-- Which city has the largest tax percent/VAT (Value added tax)?

select city,max(VAT) as tax 
from emp
group by city
order by tax desc limit 1;

-- Which customer type pays the most in VAT?
select customer_type,max(VAT) as pays
from emp
group by customer_type
order by pays desc limit 1;

-- Customer 

-- How many unique customer type does the data have ?

select distinct(customer_type) from emp;
-- or 
select distinct(customer_type) 
from emp
group by customer_type ;

-- How many unique payment methods does the data have?

select distinct(payment_method) from emp;
-- or
select distinct(payment_method)
from emp
group by payment_method;

-- What is the most common customer type ?

select count(customer_type) as common
from emp
group by customer_type
order by common desc limit 1;

-- Which customer type buys the most?

select count(customer_type) as most_buys
from emp 
group by customer_type
order by most_buys desc limit 1;
-- or 
select customer_type,max(quantity) as buys
from emp 
group by customer_type
order by buys desc limit 1;

-- What is the gender of most of the customers?

select gender,max(gender) as most_gender
from emp
group by gender 
order by most_gender desc limit 1;
-- or 
select count(gender) as comman
from emp
group by gender
order by comman desc limit 1;

-- What is the gender distribution per branch?

select branch,count(gender) as distribution 
from emp
group by branch
order by distribution desc limit 1;

-- Which time of the day do customers give most ratings?

select max(time_of_day) as days
from emp
group by time_of_day
order by days desc limit 1;

-- Which time of the day do customers give most ratings per branch?

select time_of_day,count(rating) as ratings
from emp
group by time_of_day
order by ratings desc limit 1;

-- Which day of the week has the best avg ratings?

select day_name,avg(rating) as avg_ratings
from emp
group by day_name
order by avg_ratings desc limit 1;
 -- or 
 select day_name,round(avg(rating),2) avg_ratings
 from emp
 group by day_name
 order by avg_ratings desc limit 1;
 -- Round a numeric field to the nearest value with a specified number of decimal places

-- Which day of the week has the best average ratings per branch?
select * from emp;
select branch,day_name,avg(rating)as  avg_ratings
from emp
group by branch,day_name
order by avg_ratings desc limit 1;
-- or 
select branch,day_name,round(avg(rating),2)avg_rating
from emp
group by branch,day_name
order by avg_rating desc limit 1;
 
 --  conclusions

-- Sales Trends by Product Line
-- Revenue and Profit Insights
-- Customer Segmentation and Preferences
-- Branch Performance
-- Time-Based Sales Patterns