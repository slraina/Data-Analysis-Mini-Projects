use DannyCaseStudy1

-- Having a look on the data using STORED PROCEDURE
DROP PROC spGETDATA
CREATE PROC spGETDATA
AS
	BEGIN
	SELECT * from dannys_diner.members
	SELECT * from dannys_diner.menu
	SELECT * from dannys_diner.sale
	END

EXECUTE spGETDATA;


-- 1. Total Amount Spent by each Customer at the restraunt?

SELECT s.customer_id, '$ '+ CAST(SUM(m.price) as nvarchar) as [Total Spent]
FROM dannys_diner.sale s
JOIN dannys_diner.menu m
ON m.product_id = s.product_id 
GROUP BY s.customer_id

--	2. How many days has each customer visited the restaurant?

-- Since we don't have time-stamp so we'll count each order as made on a NEW VISIT

SELECT customer_id, COUNT(order_date) as [Days_Visited]
FROM dannys_diner.sale
GROUP BY customer_id

-- 3.What was the first item from the menu purchased by each customer?
WITH FO as(
SELECT customer_id, MIN(order_date) as [First Order Date]
FROM dannys_diner.sale
GROUP BY customer_id
)SELECT FO.*,m.product_name
FROM dannys_diner.sale s
RIGHT JOIN FO
On FO.[First Order Date] = s.order_date
AND FO.customer_id = s.customer_id
JOIN [dannys_diner].[menu] m
ON s.product_id = m.product_id

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 product_name, Count(s.product_id) as [Times Purchased]
FROM [dannys_diner].[sale] s
JOIN [dannys_diner].[menu] m
ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY Count(s.product_id) DESC

-- 5.Which item was the most popular for each customer?
WITH MP as(
SELECT customer_id, product_id, Count(product_id) as [Products Purchased], 
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY Count(product_id) DESC) as RANKS
FROM [dannys_diner].[sale] 
GROUP BY customer_id, product_id
-- ORDER BY customer_id, product_id
)SELECT customer_id, product_id
FROM MP
WHERE RANKS = 1
Order by customer_id

-- 6.Which item was purchased first by the customer after they became a member?

WITH FPOAM as (
SELECT m.customer_id, s.product_id, DATEDIFF(Day, m.join_date, s.order_date) as DIFF,
RANK() OVER(PARTITION BY m.customer_id ORDER BY DATEDIFF(Day, m.join_date, s.order_date)) as [rank_of_orders]
FROM [dannys_diner].[members] m
JOIN [dannys_diner].[sale] s 
ON s.customer_id = m.customer_id
AND s.order_date >= m.join_date
)SELECT customer_id, product_name
FROM FPOAM
JOIN [dannys_diner].[menu] m
ON m.product_id = FPOAM.[product_id]
WHERE [rank_of_orders]= 1

-- 7.Which item was purchased just before the customer became a member?
WITH BSP as(
SELECT m.customer_id, s.product_id,DATEDIFF(Day, m.join_date, s.order_date) as DIFF,
RANK() OVER(PARTITION BY m.customer_id ORDER BY DATEDIFF(Day, m.join_date, s.order_date)DESC ) as [rank_of_orders] 
FROM [dannys_diner].[members] m
JOIN [dannys_diner].[sale] s 
ON s.customer_id = m.customer_id
AND s.order_date < m.join_date
) SELECT customer_id, product_name
FROM BSP
JOIN [dannys_diner].[menu] m
ON m.product_id = BSP.[product_id]
WHERE [rank_of_orders]= 1

--8.What are the total items and amount spent for each member before they became a member?

WITH PBS as(
SELECT m.customer_id, s.product_id,m.join_date, s.order_date,
DATEDIFF(Day, m.join_date, s.order_date) as DIFF,
RANK() OVER(PARTITION BY m.customer_id ORDER BY DATEDIFF(Day, m.join_date, s.order_date)DESC ) as [rank_of_orders] 
FROM [dannys_diner].[members] m
JOIN [dannys_diner].[sale] s 
ON s.customer_id = m.customer_id
AND s.order_date < m.join_date
)Select customer_id, SUM(price) as [Purchase Before Membership]
FROM PBS 
JOIN [dannys_diner].[menu] m 
ON m.product_id = PBS.product_id
GROUP BY customer_id

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
-- how many points would each customer have?

SELECT s.customer_id,
SUM(CASE WHEN m.product_name = 'sushi' THEN 2*10*m.price
	 ELSE 10*m.price
END) AS Points
FROM [dannys_diner].[menu] m
JOIN [dannys_diner].[sale] s
ON m.product_id = s.product_id
GROUP BY s.customer_id

-- 10.In the first week after a customer joins the program (including their join date) they earn
-- 2x points on all items, not just sushi - how many points do customer A and B have at the
-- end of January?

SELECT s.customer_id, 
-- s.order_date, m.product_name, m.price, mm.join_date, DATEDIFF(Day,mm.join_date,s.order_date) AS DAYS_AFTER_JOINING,
SUM(CASE WHEN DATEDIFF(Day,mm.join_date,s.order_date) <=6 
	 AND DATEDIFF(Day,mm.join_date,s.order_date) >= 0 
	 THEN 2*10*m.price
	 WHEN m.product_id = 1 THEN 2*10*m.price 
	 ELSE 10*m.price
END) AS Points
FROM [dannys_diner].[menu] m
JOIN [dannys_diner].[sale] s
ON m.product_id = s.product_id
JOIN [dannys_diner].[members] mm
ON mm.customer_id = s.customer_id
WHERE s.order_date <= '2021-01-30'
GROUP BY s.customer_id

-- Joining all tables together so that Danny team can derive quick insights
-- > See if the Order Placed my the Person has taken the MemberShip or Not

SELECT s.customer_id,s.order_date,
-- mb.join_date, 
m.product_name, m.price, 
CASE 
	WHEN s.order_date >= mb.join_date THEN 'Y'
	ELSE 'N'
	END AS members
FROM [dannys_diner].[sale] s
JOIN [dannys_diner].[menu] m 
ON m.product_id = s.product_id
LEFT JOIN [dannys_diner].[members] mb
ON mb.customer_id = s.customer_id

--Rank all things in Table

WITH rkg as (
SELECT s.customer_id,s.order_date,m.product_name, m.price, 
CASE 
	WHEN s.order_date >= mb.join_date THEN 'Y'
	ELSE 'N'
END AS members
FROM [dannys_diner].[sale] s
JOIN [dannys_diner].[menu] m 
	ON m.product_id = s.product_id
LEFT JOIN [dannys_diner].[members] mb
	ON mb.customer_id = s.customer_id
)SELECT rkg.*, 
CASE WHEN members = 'N' THEN NULL
	 ELSE DENSE_RANK() OVER (PARTITION BY customer_id,members ORDER BY order_date )
	 END AS Ranking
FROM RKG

-- GET ALL THE DATA USING STORED PROCEDURE

EXEC spGETDATA 
