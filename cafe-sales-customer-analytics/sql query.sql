CREATE DATABASE brewbridge;
USE brewbridge;

CREATE TABLE menu_information (
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    selling_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    calories INT,
    availability_status VARCHAR(20)
);

CREATE TABLE loyalty_campaign_information (
    customer_id VARCHAR(20),
    reward_offer_type VARCHAR(100),
    communication_channel VARCHAR(50),
    campaign_date DATE,
    expiry_date DATE
);

CREATE TABLE order_information (
    order_id VARCHAR(20),
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    discount_applied DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    order_type VARCHAR(50),
    reward_redeemed VARCHAR(10),
    customer_rating DECIMAL(3,1)
);

SELECT * FROM menu_information LIMIT 5;
SELECT * FROM order_information LIMIT 5;
SELECT * FROM loyalty_campaign_information LIMIT 5;

-- Check Null Values
SELECT *
FROM order_information
WHERE Total_Amount_INR = ''
   OR Total_Amount_INR = ' ';

SELECT *	
FROM order_information
WhERE Order_ID = ''
   OR Order_ID = ' ' 
AND Customer_ID = ''
   OR Customer_ID = ' ';

DELETE FROM order_information
WHERE Total_Amount_INR = '' 
    OR Total_Amount_INR = ' ';

-- Delete dupliate rows
SELECT order_id, COUNT(*)
FROM order_information
GROUP BY order_id
HAVING COUNT(*) > 1;
DELETE o1
FROM order_information o1
JOIN order_information o2
ON o1.order_id = o2.order_id
AND o1.order_id > o2.order_id;

-- Delete negative values
DELETE FROM order_information
WHERE quantity < 0
   OR Total_Amount_INR < 0;
   
SELECT *
FROM order_information
WHERE customer_rating < 1;

-- Customer Analysis SQL
-- Unique Customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM order_information;

-- Customers by Region
SELECT region,
       COUNT(*) AS total_customers
FROM customer_information
GROUP BY region
ORDER BY total_customers DESC;

-- Customers by Membership Tier
SELECT membership_tier,
       COUNT(*) AS total_customers
FROM customer_information
GROUP BY membership_tier;

-- Average Spend Per Customer
SELECT customer_id,
       ROUND(AVG(Total_Amount_INR),2) AS avg_spend
FROM order_information
GROUP BY customer_id
ORDER BY avg_spend DESC;

-- Sales & Menu Analysis

-- Total Revenue
SELECT ROUND(SUM(Total_Amount_INR),2) AS total_revenue
FROM order_information;

-- Best Selling Products
SELECT 
    m.product_name,
    SUM(o.quantity) AS total_quantity
FROM order_information o
JOIN menu_information m
ON o.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_quantity DESC;

-- Revenue by Category
SELECT 
    m.category,
    ROUND(SUM(o.Total_Amount_INR),2) AS revenue
FROM order_information o
JOIN menu_information m
ON o.product_id = m.product_id
GROUP BY m.category
ORDER BY revenue DESC;

-- Revenue by Order Type
SELECT order_type,
       ROUND(SUM(Total_Amount_INR),2) AS revenue
FROM order_information
GROUP BY order_type;

-- Payment Method Analysis
SELECT payment_method,
       COUNT(*) AS total_orders,
       ROUND(SUM(Total_Amount_INR),2) AS revenue
FROM order_information
GROUP BY payment_method;

-- Loyalty Campaign Analysis

-- Customers Who Received Campaign & Ordered
SELECT COUNT(DISTINCT l.customer_id) AS campaign_customers
FROM loyalty_campaign_information l
JOIN order_information o
ON l.customer_id = o.customer_id;

-- Campaign vs Non-Campaign Spend 
SELECT 
CASE
    WHEN l.customer_id IS NOT NULL THEN 'Campaign Recipient'
    ELSE 'Non Recipient'
END AS customer_type,

ROUND(AVG(o.Total_Amount_INR),2) AS avg_spend

FROM order_information o

LEFT JOIN loyalty_campaign_information l
ON o.customer_id = l.customer_id

GROUP BY customer_type;

-- Most Effective Reward Type
SELECT 
    Reward_Offer,
    ROUND(AVG(o.Total_Amount_INR),2) AS avg_spend
FROM loyalty_campaign_information l
JOIN order_information o
ON l.customer_id = o.customer_id
GROUP BY Reward_Offer
ORDER BY avg_spend DESC;

-- Redemption Analysis
SELECT Reward_Applied,
       COUNT(*) AS total_orders
FROM order_information
GROUP BY Reward_Applied;

-- Profitability Analysis

-- Profit Per Product
SELECT 
    m.product_name,
    ROUND(SUM(
        (o.Unit_Price_INR - m.Cost_Price_INR) * o.quantity
    ),2) AS Total_Profit
FROM order_information o
JOIN menu_information m
ON o.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_profit DESC;