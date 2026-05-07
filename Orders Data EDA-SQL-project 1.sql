SELECT * FROM orders.orders_data;

-- Exploratory Data Analysis

-- Find the distinct cities

select distinct City
from orders_data;

select *
from orders_data;

-- calculate the total Selling price and profit for all orders

select order_id,
round(sum(price_perunit* Quantity),1) as sales,
round(sum(profit_per_unit * Quantity),1) as profit
from orders_data
group by order_id
order by 3 desc;

-- Find all the orders from technology category that were shipped using second class ship mode ordered by order date

select * from orders_data
where Category = 'Technology' and
ship_mode = 'Second Class'
order by order_date;

-- Find the Avg order value

select round(avg(sales),1) as Avg_order_value 
from orders_data;


-- Find the city with the highest total quantity of products ordered

select City, sum(Quantity)
from orders_data
group by City
order by 2 desc limit 1;

select * from orders_data;

-- Use window function to rank orders in each region by quantity in descending order

select order_id, order_date, Region, Quantity, 
dense_rank() over(partition by Region order by Quantity desc) rnk
from orders_data;

-- List all orders placed in a first quarter of any year(January to March) including the total cost for these orders

select order_id, sales,
quarter(order_date) as quatr
from orders_data
where quarter(order_date) = 1
order by sales desc;

-- Top 10 highest profit Generating products

select product_id, round(sum(profit),1) Profit
from orders_data
group by product_id
order by 2 desc
limit 10;

-- Alternte way to find Top 10 highest profit generating products using CTE's.

with top10_products as
(select product_id, round(sum(profit),1) profit,
row_number() over(order by sum(profit) desc) as rnk
from orders_data
group by product_id)
select * from top10_products
where rnk <= 10;

-- Find the top 3 Highest Selling Products in each region acc to Quantity



with cte as
(select Region, product_id, sum(Quantity) Quantity,
row_number() over(partition by Region order by sum(Quantity) desc) rnk
from orders_data
group by Region, product_id 
order by 1,3 desc)
select * from cte
where rnk <= 3;


-- Find Month over Month Growth Comparison for 2022 and 2023 sales.(e.g jan2022 vs jan 2023)

select * from orders_data;

select month(order_date) order_month
from orders_data;

alter table orders_data
add column order_month int;

update orders_data
set order_month = month(order_date);

ALTER TABLE orders_data
add column order_year int;

update orders_data
set order_year = year(order_date);

with cte2 as
(with cte as
(select order_year,order_month, round(sum(sales),1) as sales
from orders_data
group by order_month, order_year
order by 2)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month)
select *,
round(sales_2022 - sales_2023,1) growth
from cte2;

-- For each category which Month had Highest sales

with cte_category as 
(select Category, order_month, round(sum(sales),1) sales,
row_number() over(partition by Category order by round(sum(sales),1) desc) as rnk
from orders_data
group by Category, order_month)
select * from cte_category
where rnk = 1;

-- which sub-category had highest growth by profit in 2023 compare to 2022
with final_cte as
(with cte_subCategory as
(select sub_category, order_year, round(sum(profit),1) profit
from orders_data
group by sub_category, order_year
order by 1)
select sub_category,
sum(case when order_year = 2022 then profit else 0 end) profit_2022,
sum(case when order_year = 2023 then profit else 0 end) as profit_2023
from cte_subCategory
group by sub_category)
select *,
round(profit_2022 - profit_2023) as profit_growth
from final_cte
order by 4 desc
limit 1;








