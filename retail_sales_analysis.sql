-- =====================================================
-- Retail Sales Analysis | MySQL
-- Tables: customers, products, orders, order_items
-- =====================================================

CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- ---------- 1. SCHEMA ----------
DROP TABLE IF EXISTS order_items, orders, products, customers;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(50),
  segment VARCHAR(20),
  city VARCHAR(30),
  region VARCHAR(20),
  signup_date DATE
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(50),
  category VARCHAR(30),
  cost_price DECIMAL(10,2),
  unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  order_status VARCHAR(20),
  payment_mode VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  discount_pct INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------- 2. LOAD DATA ----------
-- Workbench: Table Data Import Wizard use kar le (right click table > Table Data Import Wizard)
-- Ya LOAD DATA (path apna daal, local_infile enable hona chahiye):
-- LOAD DATA LOCAL INFILE 'C:/path/customers.csv' INTO TABLE customers
--   FIELDS TERMINATED BY ',' IGNORE 1 LINES;
-- Order: customers -> products -> orders -> order_items

-- ---------- 3. DATA QUALITY CHECKS ----------
SELECT 'customers' t, COUNT(*) n FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- Orphan check (0 aana chahiye)
SELECT COUNT(*) AS orphan_items
FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Duplicate check
SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

-- ---------- 4. MASTER VIEW (Power BI isi ko use karega) ----------
CREATE OR REPLACE VIEW vw_sales AS
SELECT
  oi.item_id, o.order_id, o.order_date, o.order_status, o.payment_mode,
  c.customer_id, c.customer_name, c.segment, c.city, c.region,
  p.product_id, p.product_name, p.category,
  oi.quantity, oi.discount_pct,
  p.unit_price,
  ROUND(oi.quantity * p.unit_price * (1 - oi.discount_pct/100), 2) AS revenue,
  ROUND(oi.quantity * p.cost_price, 2) AS cost,
  ROUND(oi.quantity * p.unit_price * (1 - oi.discount_pct/100)
        - oi.quantity * p.cost_price, 2) AS profit
FROM order_items oi
JOIN orders o    ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p  ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered';

-- ---------- 5. ANALYSIS QUERIES ----------

-- Q1. Overall KPIs
SELECT COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(revenue),0) AS revenue,
       ROUND(SUM(profit),0) AS profit,
       ROUND(SUM(profit)/SUM(revenue)*100,2) AS profit_margin_pct,
       ROUND(SUM(revenue)/COUNT(DISTINCT order_id),0) AS avg_order_value
FROM vw_sales;

-- Q2. Year-wise revenue + YoY growth (window function)
WITH yearly AS (
  SELECT YEAR(order_date) yr, SUM(revenue) rev FROM vw_sales GROUP BY YEAR(order_date)
)
SELECT yr, ROUND(rev,0) revenue,
       ROUND((rev - LAG(rev) OVER (ORDER BY yr)) / LAG(rev) OVER (ORDER BY yr) * 100, 2) AS yoy_growth_pct
FROM yearly;

-- Q3. Monthly trend with running total
SELECT DATE_FORMAT(order_date,'%Y-%m') ym,
       ROUND(SUM(revenue),0) revenue,
       ROUND(SUM(SUM(revenue)) OVER (ORDER BY DATE_FORMAT(order_date,'%Y-%m')),0) AS running_total
FROM vw_sales GROUP BY ym ORDER BY ym;

-- Q4. Category-wise revenue, profit, margin
SELECT category, ROUND(SUM(revenue),0) revenue, ROUND(SUM(profit),0) profit,
       ROUND(SUM(profit)/SUM(revenue)*100,2) margin_pct
FROM vw_sales GROUP BY category ORDER BY revenue DESC;

-- Q5. Top 5 products in every category (RANK)
SELECT * FROM (
  SELECT category, product_name, ROUND(SUM(revenue),0) revenue,
         RANK() OVER (PARTITION BY category ORDER BY SUM(revenue) DESC) rnk
  FROM vw_sales GROUP BY category, product_name
) t WHERE rnk <= 5;

-- Q6. Region + city performance
SELECT region, city, COUNT(DISTINCT order_id) orders, ROUND(SUM(revenue),0) revenue
FROM vw_sales GROUP BY region, city ORDER BY revenue DESC;

-- Q7. Customer segment analysis
SELECT segment, COUNT(DISTINCT customer_id) customers,
       ROUND(SUM(revenue),0) revenue,
       ROUND(SUM(revenue)/COUNT(DISTINCT customer_id),0) revenue_per_customer
FROM vw_sales GROUP BY segment;

-- Q8. Top 10 customers by revenue
SELECT customer_name, city, ROUND(SUM(revenue),0) revenue,
       COUNT(DISTINCT order_id) orders
FROM vw_sales GROUP BY customer_id, customer_name, city
ORDER BY revenue DESC LIMIT 10;

-- Q9. Return + cancellation rate by category
SELECT p.category,
       ROUND(SUM(o.order_status='Returned')/COUNT(*)*100,2) AS return_rate_pct,
       ROUND(SUM(o.order_status='Cancelled')/COUNT(*)*100,2) AS cancel_rate_pct
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category;

-- Q10. Discount impact on profit
SELECT discount_pct, COUNT(*) items, ROUND(SUM(revenue),0) revenue,
       ROUND(SUM(profit)/SUM(revenue)*100,2) margin_pct
FROM vw_sales GROUP BY discount_pct ORDER BY discount_pct;

-- Q11. Payment mode share
SELECT payment_mode, COUNT(DISTINCT order_id) orders,
       ROUND(COUNT(DISTINCT order_id)*100.0/SUM(COUNT(DISTINCT order_id)) OVER (),2) share_pct
FROM vw_sales GROUP BY payment_mode ORDER BY orders DESC;

-- Q12. Repeat vs one-time customers
WITH cust AS (
  SELECT customer_id, COUNT(DISTINCT order_id) n FROM vw_sales GROUP BY customer_id
)
SELECT CASE WHEN n = 1 THEN 'One-time' ELSE 'Repeat' END AS type,
       COUNT(*) customers FROM cust GROUP BY type;

-- Q13. RFM-style customer segmentation
WITH rfm AS (
  SELECT customer_id,
         DATEDIFF((SELECT MAX(order_date) FROM vw_sales), MAX(order_date)) recency,
         COUNT(DISTINCT order_id) frequency,
         SUM(revenue) monetary
  FROM vw_sales GROUP BY customer_id
),
scored AS (
  SELECT *, NTILE(4) OVER (ORDER BY recency DESC) r,
            NTILE(4) OVER (ORDER BY frequency)   f,
            NTILE(4) OVER (ORDER BY monetary)    m
  FROM rfm
)
SELECT customer_id, recency, frequency, ROUND(monetary,0) monetary,
       CASE WHEN r+f+m >= 10 THEN 'Champion'
            WHEN r+f+m >= 7  THEN 'Loyal'
            WHEN r >= 3      THEN 'Promising'
            ELSE 'At Risk' END AS segment
FROM scored;
