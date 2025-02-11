-- Question 01: Question 01: Using the customer table, please write an SQL query that shows Title, First Name, Last Name, and Date of Birth for each of the customers.
SELECT 
    title, 
    first_name, 
    last_name, 
    date_of_birth
FROM 
    customer;

-- Question 02: Using the customer table, please write an SQL query that shows the number of customers in each customer group (Bronze, Silver & Gold).
SELECT 
    customer_group, 
    COUNT(*) AS customer_count
FROM 
    customer
GROUP BY 
    customer_group;

-- Question 03: The CRM manager has asked me to provide a complete list of all data for those customers in the customer table, but I need to add the currency code of each player so she will be able to send the right offer in the right currency. Note that the currency code does not exist in the customer table but in the account table. Please write the SQL that would facilitate this.
SELECT 
    c.*, 
    a.currencycode
FROM 
    customer c
JOIN 
    account a ON c.customer_id = a.customer_id;

-- Question 04: Now I need to provide a product manager with a summary report that shows, by product and by day, how much money has been bet on a particular product. Please note that the transactions are stored in the betting table and there is a product code in that table that is required to be looked up (classid & categoryid) to determine which product family this belongs to. Please write the SQL that would provide the report.
SELECT 
    p.product_name,
    b.bet_date,
    SUM(b.bet_amount) AS total_bet_amount
FROM 
    betting b
JOIN 
    product p ON b.product_code = p.product_code
GROUP BY 
    p.product_name, b.bet_date
ORDER BY 
    b.bet_date;

-- Question 05: You’ve just provided the report from question 4 to the product manager, now he has emailed me and wants it changed. Can you please amend the summary report so that it only summarizes transactions that occurred on or after 1st November, and he only wants to see Sportsbook transactions. Again, please write the SQL below that will do this.
SELECT 
    p.product_name,
    b.bet_date,
    SUM(b.bet_amount) AS total_bet_amount
FROM 
    betting b
JOIN 
    product p ON b.product_code = p.product_code
WHERE 
    b.bet_date >= '2021-11-01' 
    AND p.product_category = 'Sportsbook'
GROUP BY 
    p.product_name, b.bet_date
ORDER BY 
    b.bet_date;

-- Question 06: As often happens, the product manager has shown his new report to his director and now he also wants a different version of this report. This time, he wants all of the products but split by the currency code and customer group of the customer, rather than by day and product. He would also only like transactions that occurred after 1st December. Please write the SQL code that will do this.
SELECT 
    p.product_name,
    a.currencycode,
    c.customer_group,
    SUM(b.bet_amount) AS total_bet_amount
FROM 
    betting b
JOIN 
    product p ON b.product_code = p.product_code
JOIN 
    account a ON b.customer_id = a.customer_id
JOIN 
    customer c ON b.customer_id = c.customer_id
WHERE 
    b.bet_date >= '2021-12-01'
GROUP BY 
    p.product_name, a.currencycode, c.customer_group
ORDER BY 
    p.product_name, a.currencycode, c.customer_group;

-- Question 07: Our VIP team have asked to see a report of all players regardless of whether they have done anything in the complete timeframe or not. In our example, it is possible that not all of the players have been active. Please write an SQL query that shows all players' Title, First Name, and Last Name and a summary of their bet amount for the complete period of November.
SELECT 
    c.title,
    c.first_name,
    c.last_name,
    SUM(b.bet_amount) AS total_bet_amount
FROM 
    customer c
LEFT JOIN 
    betting b ON c.customer_id = b.customer_id 
            AND b.bet_date >= '2021-11-01' AND b.bet_date < '2021-12-01'
GROUP BY 
    c.customer_id
ORDER BY 
    c.first_name, c.last_name;

-- Question 08: Our marketing and CRM teams want to measure the number of players who play more than one product. Can you please write 2 queries, one that shows the number of products per player and another that shows players who play both Sportsbook and Vegas.
SELECT 
    b.customer_id,
    COUNT(DISTINCT b.product_code) AS num_of_products
FROM 
    betting b
GROUP BY 
    b.customer_id;

SELECT 
    b.customer_id
FROM 
    betting b
JOIN 
    product p ON b.product_code = p.product_code
WHERE 
    p.product_category IN ('Sportsbook', 'Vegas')
GROUP BY 
    b.customer_id
HAVING 
    COUNT(DISTINCT p.product_category) = 2;

-- Question 09: Now our CRM team wants to look at players who only play one product. Please write SQL code that shows the players who only play at Sportsbook, use the bet_amt > 0 as the key. Show each player and the sum of their bets for both products.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CASE WHEN p.product_category = 'Sportsbook' THEN b.bet_amount ELSE 0 END) AS sportsbook_bet_amount,
    SUM(CASE WHEN p.product_category = 'Vegas' THEN b.bet_amount ELSE 0 END) AS vegas_bet_amount
FROM 
    customer c
JOIN 
    betting b ON c.customer_id = b.customer_id
JOIN 
    product p ON b.product_code = p.product_code
WHERE 
    b.bet_amount > 0
GROUP BY 
    c.customer_id
HAVING 
    SUM(CASE WHEN p.product_category = 'Sportsbook' THEN b.bet_amount ELSE 0 END) > 0
    AND SUM(CASE WHEN p.product_category = 'Vegas' THEN b.bet_amount ELSE 0 END) = 0;

-- Question 10: The last question requires us to calculate and determine a player’s favorite product. This can be determined by the most money staked. Please write a query that will show each player's favorite product.
SELECT 
    b.customer_id,
    p.product_name,
    SUM(b.bet_amount) AS total_bet_amount
FROM 
    betting b
JOIN 
    product p ON b.product_code = p.product_code
GROUP BY 
    b.customer_id, p.product_name
ORDER BY 
    b.customer_id, total_bet_amount DESC;

-- Question 11: Write a query that returns the top 5 students based on GPA.
SELECT 
    student_name, 
    gpa
FROM 
    student_school
ORDER BY 
    gpa DESC
LIMIT 5;

-- Question 12: Write a query that returns the number of students in each school. (A school should be in the output even if it has no students!).
SELECT 
    s.school_name, 
    COUNT(st.student_id) AS number_of_students
FROM 
    school s
LEFT JOIN 
    student_school st ON s.school_id = st.school_id
GROUP BY 
    s.school_name;

-- Question 13: Write a query that returns the top 3 GPA students' names from each university.
WITH RankedStudents AS (
    SELECT 
        ss.student_name,
        ss.gpa,
        ss.university_id,
        ROW_NUMBER() OVER (PARTITION BY ss.university_id ORDER BY ss.gpa DESC) AS rank
    FROM 
        student_school ss
)
SELECT 
    student_name, 
    gpa, 
    university_id
FROM 
    RankedStudents
WHERE 
    rank <= 3
ORDER BY 
    university_id, gpa DESC;
