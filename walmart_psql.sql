SELECT * FROM walmart
--
DROP TABLE walmart
SELECT COUNT (*) FROM walmart;

SELECT payment_method,
COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MIN (quantity)
FROM walmart

--Business Problems
--1 for each payment method find different payment method and number of transactions , number of quantity sold
SELECT payment_method,
COUNT(*) as no_payments, 
SUM(quantity) as qty_sold
FROM walmart
GROUP BY payment_method;

--2 identify highest rated category in each branch, displaying the branch, category and avg rating
SELECT *
FROM(
SELECT branch , category, avg(rating) as avg_rating,
RANK()OVER(PARTITION BY branch ORDER BY AVG(rating)DESC) as rank
FROM walmart
GROUP BY branch, category
)
WHERE rank=1

--3 idientify the busiest day for each branch based on their number of transactions
SELECT *
FROM
(
SELECT branch, 
to_char(TO_DATE(date, 'DD/MM/YY'),'Day') as day_name,
COUNT(*) as no_transactions,
RANK()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank=1

--4 calculae the total quantity of items sold per payment method. list payment method and total quantity.
select * from walmart

SELECT payment_method,
SUM(quantity) as qty_sold
FROM walmart
GROUP BY payment_method;

--5 determine the avg, minimum, and max rating of category for each city. 
--list the city, avg rating, min rating, max rating.
SELECT city, category,
MIN(rating) as min_rating,
MAX(rating) as max_rating,
AVG(rating) as avg_rating
FROM walmart
GROUP BY city, category

-- 6 calculate the total profit for each category by considering total profit as (unit_price * quantity
-- * profit_margin). list category and total_profit, ordered from highest to lowest profit.
select * from walmart

SELECT category, 
SUM(total* profit_margin) as total_profit,
SUM(total) as total_revenue
FROM walmart
GROUP BY category

--7 determine the most common method for each branch. display branch and the payment method.
WITH cte
AS
(
SELECT branch, payment_method, COUNT (*) as total_transactions,
RANK()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY branch,payment_method
)
SELECT *
FROM cte
WHERE RANK =1

--8 categories sales into 3 group Morning, afternoon, evening. find out each shift and number of invoices.
SELECT branch,
	CASE 
		WHEN EXTRACT (HOUR FROM (time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as day_time	, COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC

--9 identify 5 branch with highest decrease ratio in revenue compare to last year. 
--(current year 2023 and last year 2022)
--revenue_decre_ratio= last_rev - curr_rev/last_rev 100

--revenue 2022
WITH revenue_2022
as
(
SELECT branch, 
SUM(total) as revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY'))=2022
GROUP BY 1
),
revenue_2023
AS
(
SELECT branch, 
SUM(total) as revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY'))=2023
GROUP BY 1
)

SELECT ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
ROUND( 
		(ls.revenue-cs.revenue)::numeric/ls.revenue:: numeric*100,
		2 )as decr_rev_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs
ON ls.branch= cs.branch
WHERE ls.revenue>cs.revenue
ORDER BY 4 DESC
LIMIT 5
