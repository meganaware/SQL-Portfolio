/*Break Into Tech Data Analytics Certificate Program by Charlotte Chaze
SQL: Querying a database with multiple tables in it to quantify statistics about customer and order data*/ 

/*Select all the columns and ~20 rows from the customers table to see what it looks like.*/
SELECT * FROM BIT_DB.customers LIMIT 20;

/*How to fix this messy/incorrect data
To make sure your query results are correct when you query this data, you need to make note of the incorrect data and plan around it.*/
SELECT * FROM BIT_DB.customers
WHERE length(order_id) = 6
AND order_id <> 'Order ID';
/*Another common way that data shows up incorrectly is that cells are blank, or "null". There aren't any cells in this dataset that are blank or null, but if there were, you'd filter them out like this:*/
SELECT * FROM BIT_DB.customers
WHERE order_id IS NOT NULL
AND order_id <> '';

/*#1. How many orders were placed in January?*/
SELECT COUNT(orderid)
FROM BIT_DB.JanSales
WHERE length(orderid) = 6 
AND orderid <> 'Order ID';

/*#2. How many of those orders were for an iPhone?*/
SELECT COUNT(orderid)
FROM BIT_DB.JanSales
WHERE Product='iPhone'
AND length(orderid) = 6 
AND orderid <> 'Order ID';

/*#3. Select the customer account numbers for all the orders that were placed in February.*/
SELECT distinct acctnum
FROM BIT_DB.customers cust
INNER JOIN BIT_DB.FebSales Feb
ON cust.order_id=FEB.orderid
WHERE length(orderid) = 6 
AND orderid <> 'Order ID';

/*#4. Which product was the cheapest one sold in January, and what was the price?
# THERE ARE MULTIPLE CORRECT ANSWERS LISTED BELOW */
/*###### QUESTION 4 ANSWER #1 ######*/
SELECT distinct Product, price
FROM BIT_DB.JanSales
WHERE  price in (SELECT min(price) FROM BIT_DB.JanSales);
/*####### QUESTION 4 ANSWER #2 ######*/
SELECT distinct product, price 
FROM BIT_DB.JanSales 
ORDER BY price ASC LIMIT 1;
/*####### QUESTION 4 ANSWER #3 ######*/
SELECT distinct product, MIN(price) 
FROM BIT_DB.JanSales Jan 
GROUP BY product, price 
ORDER BY price ASC LIMIT 1;
/*#PLEASE NOTE: Did do use Option 3, but forgot the GROUP BY?
#If so, please see the Question 4 notes below the Answers section for an explanation.*/
/*#######  QUESTION 4 ANSWER #4 ######*/
SELECT product, min(price) 
FROM BIT_DB.JanSales Jan 
GROUP BY product, price 
ORDER BY price ASC
LIMIT 1;

/*#5. What is the total revenue for each product sold in January?*/
SELECT sum(quantity)*price as revenue
,product
FROM BIT_DB.JanSales
GROUP BY product;
/*#PLEASE NOTE: Are you unsure why we use sum(quantity)*price here? See Question 5 notes below the answer section for an explanation.*/

/*#6. Which products were sold in February at 548 Lincoln St, Seattle, WA 98101, how many of each were sold, and what was the total revenue?*/
select 
sum(Quantity), 
product, 
sum(quantity)*price as revenue
FROM BIT_DB.FebSales 
WHERE location = '548 Lincoln St, Seattle, WA 98101'
GROUP BY product;

/*#7. How many customers ordered more than 2 products at a time, and what was the average amount spent for those customers?*/
select 
count(distinct cust.acctnum), 
avg(quantity)*price
FROM BIT_DB.FebSales Feb
LEFT JOIN BIT_DB.customers cust
ON FEB.orderid=cust.order_id
WHERE Feb.Quantity>2
AND length(orderid) = 6 
AND orderid <> 'Order ID';


/*Advanced Data Filtering Techniques in SQL
  'like' searches the column you give it for the values you type in after like.
  '%' tells the SQL code that you are searching for a value that can match anything.*/

/*Filter data by date
##1. */
SELECT orderdate
FROM BIT_DB.FebSales
WHERE orderdate between '02/13/19 00:00' AND '02/18/19 00:00';
/*##2. */
SELECT location
FROM BIT_DB.FebSales 
WHERE orderdate = '02/18/19 01:35';
/*##3. */
SELECT sum(quantity)
FROM BIT_DB.FebSales 
WHERE orderdate like '02/18/19%';

/*You can use LIKE for any kind of data, not just dates. And you can add the % to the front, end, or both sides of the value you're searching for.
##1.*/
SELECT distinct Product
FROM BIT_DB.FebSales
WHERE Product like '%Batteries%';
/*##2.*/ 
SELECT distinct Product, Price
FROM BIT_DB.FebSales 
WHERE Price like '%.99';

/*List all the products sold in Los Angeles in February, and include how many of each were sold.*/
SELECT Product, SUM(quantity)
FROM BIT_DB.FebSales 
WHERE location like '%Los Angeles%'
GROUP BY Product;


/*Advanced Customer & Order Analytics*/

/*#1. Which locations in New York received at least 3 orders in January, and how many orders did they each receive?*/
SELECT distinct location, count(orderID)
FROM BIT_DB.JanSales
WHERE location LIKE '%NY%'
AND length(orderid) = 6 
AND orderid <> 'Order ID'
GROUP BY location
HAVING count(orderID)>2;
/*# Did you forget to filter for the right Order IDs? In this case, you get the same answer either way. 
# But you won't always! */

/*#2. How many of each type of headphone was sold in February?*/
SELECT sum(Quantity) as quantity,
Product
FROM BIT_DB.FebSales 
WHERE Product like '%Headphones%'
GROUP BY Product;

/*#3. What was the average amount spent per account in February?*/
SELECT sum(quantity*price)/count(cust.acctnum)
FROM BIT_DB.FebSales Feb
LEFT JOIN BIT_DB.customers cust
ON FEB.orderid=cust.order_id
WHERE length(orderid) = 6 
AND orderid <> 'Order ID'
/*# OR # */
SELECT avg(quantity*price)
FROM BIT_DB.FebSales Feb
LEFT JOIN BIT_DB.customers cust
ON FEB.orderid=cust.order_id
WHERE length(orderid) = 6 
AND orderid <> 'Order ID';

/*#4. What was the average quantity of products purchased per account in February? */
select sum(quantity)/count(cust.acctnum)
FROM BIT_DB.FebSales Feb
LEFT JOIN BIT_DB.customers cust
ON FEB.orderid=cust.order_id
WHERE length(orderid) = 6 
AND orderid <> 'Order ID';

/*#5. Which product brought in the most revenue in January and how much revenue did it bring in total? */
SELECT product, 
sum(quantity*price)
FROM BIT_DB.JanSales 
GROUP BY product
ORDER BY sum(quantity*price) desc 
LIMIT 1;
/*# EXPLANATION #1 
# "Why do we use SUM(quantity*price) instead of SUM(quantity)*price?"
# In this question, we are using GROUP BY product. 
# The price of each individual product doesn't change. 
# That's why SUM(quantity*price) and SUM(quantity)*price, in this specific question, both give the same results. 
# To visualize this, run the following SQL and look at the results:*/
select sum(quantity),
price,
sum(quantity)*price as revenue,
sum(quantity*price) as revenue2,
product 
FROM BIT_DB.JanSales
group by product;
/*# EXPLANATION #2
# "Why can't I just use sum(price) instead of sum(quantity*price)?"
# In this case, there's no difference between sum(price) and sum(quantity*price).
# However, the correct answer is sum(quantity*price), because revenue is calculated by multiplying the price of the product by the number sold. 
# In this data, each product is sold for only one price, so you can get the same answer with sum(price). 
# But not every dataset will be that simple, and it's best not to assume that's the case.
# If the product was sold for different prices on different days, sum(price) wouldn't give the correct answer. */
