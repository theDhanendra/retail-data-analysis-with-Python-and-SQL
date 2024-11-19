CREATE DATABASE Retail_Orders;
use Retail_Orders;

-- create table retail_orders(
-- 	order_id int primary key,
--     order_date date,
--     ship_mode varchar (20),
--     segment varchar (20),
--     country varchar (20),
--     city varchar (20),
--     state varchar (20),
--     postal_code varchar (20),
-- 	region varchar (20),
-- 	category varchar (20),
--     sub_category varchar (20),
--     product_id varchar (50),
--     quantity int, 
--     discount decimal (7, 2),
--     sale_price decimal (7, 2),
--     profit decimal (7, 2)
--     );

SELECT * FROM Retail_Orders;

# Task:
-- 1. Identify the top 10 products that generate the highest revenue.
SELECT  product_id, sum(sale_price) as revenue from retail_orders
group by product_id
order by revenue desc limit 10;

-- 2. Determine the top 5 best-selling products in each region.
SELECT region, product_id, SUM(sale_price) as revenue from retail_orders
group by region, product_id
order by region,revenue desc;

with cte as (
SELECT region, product_id, SUM(sale_price) as revenue from retail_orders
group by region, product_id)
select * from (
select *, ROW_NUMBER() over(partition by region order by revenue desc) as rank_ 
from cte ) A
where rank_ <=5;

-- 3. Compare the month-over-month sales growth for 2022 and 2023.
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales from retail_orders
group by year(order_date), month(order_date)
order by order_year, order_month;

-- VS
with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales from retail_orders
group by year(order_date), month(order_date)
-- order by order_year, order_month
)
select order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- 4. For each category, find out which month had the highest sales.
with cte as (
select category, format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales
from retail_orders
group by category, format(order_date, 'yyyyMM')
-- order by category, format(order_date, 'yyyyMM')
)
select * from (
select  *, row_number() over(partition by category order by sales desc) as rank_
from cte
) a where rank_ = 1;

-- 5. Discover which sub-category experienced the highest profit growth in 2023 compared to 2022
with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales from retail_orders
group by sub_category, year(order_date)
-- order by order_year, order_month
)
, cte2 as(
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
SELECT *, (sales_2023 - sales_2022)* 100 / sales_2022 as highest_growth_sub_Category from cte2
order by highest_growth_sub_Category desc;

-- 6. Discount Effectiveness: Analyze the impact of discounts on sales and profit:
SELECT discount, SUM(sale_price) as total_sales, SUM(profit) as total_profit
from retail_orders
Group by discount
order by discount;
# This query shows the relationship between discount levels and their effect on sales and profits, helping optimize pricing strategies.

-- 7. Category-Wise Performance
-- This query compares sales and profit across different product categories.
SELECT category,                    
    SUM(sale_price) AS total_sales, 
    SUM(profit) AS total_profit  
FROM retail_orders                
GROUP BY category                     
ORDER BY total_sales DESC;

-- 8. Profitability of each region.
SELECT region, SUM(profit) AS total_profit  
FROM retail_orders                
GROUP BY region                       
ORDER BY total_profit DESC;
#This query helps assess which regions are most profitable and where resources should be focused.

-- 9. Top Selling Cities:
SELECT city, SUM(sale_price) AS total_sales 
FROM retail_orders
GROUP BY city                         
ORDER BY total_sales DESC             
LIMIT 10;
# This helps identify cities with the highest demand, enabling targeted marketing and resource allocation.

-- 10. Yearly Revenue Growth by Region.
SELECT region,                      
    YEAR(order_date) AS year,  
    SUM(sale_price) AS total_sales 
FROM retail_orders                
GROUP BY region, YEAR(order_date)     
ORDER BY region, year;

-- 11. Shipping Mode Analysis:
SELECT ship_mode, 
    COUNT(order_id) AS total_orders, 
    SUM(profit) AS total_profit
FROM retail_orders
GROUP BY ship_mode
ORDER BY total_profit DESC;
