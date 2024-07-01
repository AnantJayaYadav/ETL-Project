select * from df_orders

--finding top 10 highest revenue ganerating products
select product_id, sum(sale_price) as sales
from df_orders 
group by product_id
order by sales desc
limit 10

--finding top 5 highest selling products in each region
with cte as(
	select region,product_id, sum(sale_price) as sales
from df_orders 
group by region,product_id)
select * from(
	select * 
	, row_number() over (partition by region order by sales desc) as rn
	from cte)A
	where rn<=5

--month over month growth comparison for 2022 and 2023 sales(jan 2022 vs jan 2023)
--SELECT DISTINCT EXTRACT(YEAR FROM order_date) AS year FROM df_orders;
with cte as (
	select EXTRACT(YEAR FROM order_date) as order_year,EXTRACT(Month FROM order_date) as order_month,
	sum(sale_price) as sales
	from df_orders
	group by order_year,order_month
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month


--for each category, the month with highest sales
with cte as(
	SELECT TO_CHAR(order_date, 'YYYYMM') AS order_year_month, category, sum(sale_price) as sales
FROM df_orders
	group by category, order_year_month)
select * from(
	select *, 
	row_number() over(partition by category order by sales desc)as rn
	from cte)a
	where rn=1


--the subcategory with the highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        sub_category,
        EXTRACT(YEAR FROM order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, order_year
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT 
    sub_category,
    (sales_2023 - sales_2022) AS sales_difference,
    CASE 
        WHEN sales_2022 = 0 THEN NULL  -- Avoid division by zero
        ELSE (sales_2023 - sales_2022) * 100.0 / sales_2022
    END AS percentage_growth
FROM cte2
ORDER BY percentage_growth DESC NULLS LAST  -- Handle NULLs properly
LIMIT 1;




