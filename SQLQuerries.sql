USE walmart_db;
SHOW TABLES; 
DESCRIBE walmart; 

SELECT 
    payment_method, 
    COUNT(*) AS total_transactions 
FROM walmart 
GROUP BY payment_method;

SELECT COUNT(DISTINCT Branch)
FROM walmart;

-- Question One: Find the different payment methods and the number of transcation, number of qty sold 
SELECT 
    payment_method, 
    COUNT(*) AS total_transactions,
    SUM(quantity) AS number_of_quantity_sold
FROM walmart 
GROUP BY payment_method;

-- Question Two: Identify the highest-rated category in each branch, displaying the branch, category 

WITH category_ranking AS (
    SELECT 
        branch, 
        category, 
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS category_rank
    FROM walmart 
    GROUP BY branch, category
)
SELECT *
FROM category_ranking
WHERE category_rank = 1;

-- Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM (
    SELECT 
        Branch, 
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS day_name, 
        COUNT(*) AS no_transactions, 
        RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM walmart
    GROUP BY Branch, day_name
) ranked_data
WHERE `rank` = 1;

-- Calculate the total quantinty of items sold per payment method. List the payment_method and total_quantity 

SELECT payment_method, 
COUNT(*) AS no_payments,
SUM(quantity) AS no_quantity_sold
FROM walmart
GROUP BY payment_method;

-- Determine the average, minimum, and maximum rating of category for each city. List the city, average_rating, min_rating, and max_rating
SELECT city, category,
MIN(rating) AS min_rating, 
MAX(rating) AS max_rating, 
AVG(rating) AS avg_rating 
FROM walmart 
GROUP BY city, category;

-- Calculate the total profit for each category by considering total_profit as (unit_price*quantity*profit_margin). List category and total_profit, ordered from highest to lowest profit. 

SELECT category, 
SUM(total) AS total_revenue,
SUM(total * profit_margin) AS profit
FROM walmart 
GROUP BY category;

-- Determine the most common payment method for each Branch. Display the Branch and the preferred_payment method. 
WITH cte 
AS
(SELECT Branch, payment_method, 
COUNT(*) AS Total_trans,
RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS Rrank
FROM walmart
GROUP BY Branch, payment_method)
SELECT  * FROM cte WHERE Rrank = 1;

-- Categorize sales into three groups MORNING, AFTERNOON, AND EVENING. Find out which of the shift and number of invoices 

SELECT Branch, 
    CASE 
        WHEN HOUR(STR_TO_DATE(date, '%d/%m/%Y %H:%i:%s')) BETWEEN 0 AND 11 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(date, '%d/%m/%Y %H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY Branch, time_of_day
ORDER BY Branch, time_of_day DESC;

-- Identify 5 branch with the highest ratio in revenue compare to last year (current year 2023 and last year 2022)
WITH revenue_by_branch AS (
    SELECT 
        Branch,
        YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS year,
        SUM(Total) AS total_revenue
    FROM walmart
    GROUP BY Branch, year
),
revenue_comparison AS (
    SELECT 
        r1.Branch,
        r1.total_revenue AS revenue_2023,
        r2.total_revenue AS revenue_2022,
        (r1.total_revenue / NULLIF(r2.total_revenue, 0)) AS revenue_growth_ratio
    FROM revenue_by_branch r1
    LEFT JOIN revenue_by_branch r2 
        ON r1.Branch = r2.Branch AND r1.year = 2023 AND r2.year = 2022
)
SELECT Branch, revenue_2023, revenue_2022, revenue_growth_ratio
FROM revenue_comparison
ORDER BY revenue_growth_ratio DESC
LIMIT 5;

