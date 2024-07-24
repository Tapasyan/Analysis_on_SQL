select * from market_fact_full;

select  avg(Sales) from market_fact_full;
# Sub-Query

select Ord_id , Sales from market_fact_full where Sales > (select  avg(Sales) from market_fact_full);

-- Find Prod_id who's Sales is greater than avg(Sales) across all Prod_id?

select Prod_id,sum(Sales) as total_sales from market_fact_full group by Prod_id;

-- use first query

select avg(total_sales) as avg_sales from (select Prod_id,sum(Sales) as total_sales from market_fact_full group by Prod_id)x;

-- Now find those stores Who's total sales is grater than avg-sales?

select * from (select Prod_id,sum(Sales) as total_sales from market_fact_full group by Prod_id) total_sale
join  (select avg(total_sales) as avg_sales from (select Prod_id,sum(Sales) as 
total_sales from market_fact_full group by Prod_id)x) avg_Sales
on total_sale.total_sales > avg_Sales.avg_sales;

with total_sales as (
    select Prod_id, sum(Sales) as total_sales 
    from market_fact_full 
    group by Prod_id
), 
avg_sales as (
    select avg(total_sales) as avg_sales 
    from total_sales
)
select * from total_sales as ts 
join avg_sales av on ts.total_sales > av.avg_sales ;


-- Window Function or Analytic Function

select * , max(Sales) over(partition by Prod_id) as max_sales from market_fact_full;
select * from prod_dimen;
select * , row_number() over(partition by Product_Category) as rn from prod_dimen;


-- find first 2 Prod_id from market_fact_full
select * from(select * , row_number() over(partition by Product_Category order by Prod_id) as rn from prod_dimen) x where x.rn <3;

-- Find the top 3 Prod_id  in market_fact_full having the highest sales

select * from(select *,rank() over(partition by Prod_id order by Sales desc) as rk from market_fact_full) x where x.rk <3;

select * from Prod_dimen;

select * from orders_dimen;

select *,dense_rank() over(partition by Prod_id order by Sales desc) as rk from market_fact_full;


-- Write Query to display the most recently_placed order in each order_priority

-- FIRST_VALUE [FUNCTION]

select *, first_value(Order_Number) over(partition by Order_Priority order by Order_Date desc)as 
most_recent_placed_orders from orders_dimen limit 1500;

-- LAST_VALUE [VALUE]

-- Write Query to display the most Least_placed order in each order_priority
select *, last_value(Order_Number) over(partition by Order_Priority order by Order_Date asc)as 
most_least_placed_orders from orders_dimen limit 1500;

-- NTH value

-- write a query to display the second recently places order under each product_category


select * , first_value(Order_Number) over w as most_recently_placed_order,nth_value(Order_Priority,2)
over w as second_recently_placed_oredr from orders_dimen window w as (partition by Order_Priority order by Order_Date desc
range between  unbounded preceding and unbounded following);

-- UNBOUNDED PRECEDING
-- This specifies the starting point of the window frame as the first row of the partition.
-- It means that the window frame includes all rows from the partition's first row up to the current row being processed by the window function.
-- Essentially, it includes all rows from the beginning of the partition up to the current row.
-- 2. UNBOUNDED FOLLOWING
-- This specifies the ending point of the window frame as the last row of the partition.
-- It means that the window frame includes all rows from the current row being processed by the window function up to the last row of the partition.
-- In other words, it includes all rows from the current row to the end of the partition.

-- NTILE
-- find all Product category which are most recentile placed , and late placed order.

select Order_Priority,
case when x.buckets = 1 then "Most_recently_placed"
     when x.buckets = 2 then "second_recently_placed" 
     when x.buckets = 3 then "third_recently_placed" END Order_category
from (select * , ntile(3) over (order by Order_Date desc) as buckets from orders_dimen where Order_Priority = "HIGH") x ;


-- CUME_DIST [FUNCTION]  VALUE >> 1 <=CUME_DIST> 0
-- FORMULA = CURRENT  ROW NO (ROW NO WITH VALUES SAME AS CURRENT ROW) / TOTAL NO OF ROWS

-- FIND THE ord_category whic are consist the first 30 % of the data.

select * from cust_dimen;
select * from prod_dimen;
select * from orders_dimen;
select * from shipping_dimen;
select * from market_fact_full;

select Product_Category ,sum(Sales) as total_sales_in_each_segment from market_fact_full m join Prod_dimen p on m.Prod_id = p.Prod_id
group by Product_Category order by total_sales_in_each_segment desc;

-- find the two highest shipping cost in each Order_priority.

SELECT Order_priority, sum(Shipping_cost) AS total_shipping_cost
FROM market_fact_full m
JOIN orders_dimen o ON m.Ord_id = o.ord_id
GROUP BY Order_priority order by total_shipping_cost desc limit 2;

-- Fetch the data which have higher shipping cost then avg shipping cost;

CREATE VIEW SHIPPING_SUMMARY
AS

SELECT o.Order_priority, SUM(m.Shipping_cost) AS total_shipping_cost
FROM market_fact_full m
JOIN orders_dimen o ON o.Ord_id = m.ord_id
GROUP BY o.Order_priority
HAVING SUM(m.Shipping_cost) > (
    SELECT AVG(Shipping_cost)
    FROM market_fact_full
)
ORDER BY total_shipping_cost DESC;

-- WE ARE USING VIEW HERE FOR SEE PRIVATE DATA THAT NO_ONE CAN SEE OUR REAL DATA.

SELECT * FROM SHIPPING_SUMMARY;

-- RECURSIVE SQL QUERY


WITH RECURSIVE numbers_cte(n) AS (
    -- Anchor member
    SELECT 1 AS n
    UNION ALL
    -- Recursive member
    SELECT n + 1
    FROM numbers_cte
    WHERE n < 10  -- Define your upper limit here
)
SELECT n
FROM numbers_cte;



