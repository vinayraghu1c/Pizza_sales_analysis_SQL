# Pizza Sales Analysis — SQL Project

Welcome to the **Pizza Sales Analysis** project! This project showcases how SQL can be used to extract meaningful business insights from a normalized pizza sales dataset. The dataset has been imported from Kaggle and structured into multiple relational tables for optimal querying.

---

## Project Structure

This project includes:

- **Database Schema Creation**
- **13 Business Questions**
- - **Data Import**
- **SQL Queries and Insights**

---

## Objective

To analyze a pizza sales dataset using SQL and answer key business questions related to sales performance, customer ordering behavior, and revenue trends.

---

## Tech Stack

- **SQL** MySQL
- **Database Tool**: MySQL Workbench 
- **Dataset Source**: [Kaggle - Pizza Sales] [([https://www.kaggle.com/code/mdismielhossenabir/pizza-sales-dataset]) - manually normalized into relational format

---

## Business Questions Answered (Using SQL)

### 🔹 Beginner-Level Analysis:
1. Total number of orders
2. Total revenue generated
3. Highest priced pizza
4. Most common quantity ordered
5. Most common pizza size
6. Top 5 most ordered pizza types (by quantity)

### 🔹 Intermediate-Level Analysis:
7. Total quantity ordered by each pizza category
8. Order distribution by hour of the day
9. Category-wise pizza distribution (by count and variety)
10. Average number of pizzas ordered per day
11. Top 3 most ordered pizzas based on revenue
12. Percentage contribution of each category to total revenue
13. Top 3 best-selling pizzas (by revenue) within each category

---

## Key Insights

- The **total revenue** was calculated using `quantity * unit_price`.
- The **most popular pizza size** and **most frequently ordered pizza** were determined via `GROUP BY` and `ORDER BY`.
- **Window functions (`RANK() OVER`)** were used to rank top pizzas within each category.
- Data was grouped by **hour**, **date**, and **category** to understand trends and optimize business strategy.

---

## Data Cleaning & Transformation

- The original dataset was a **single CSV file**.
- It was cleaned using **Excel** and separated into **4 normalized tables** for efficient relational analysis.
- Temporary tables were used for joining and updating missing fields using SQL joins.

---

## Database Schema

The database consists of 4 tables:

1. ** orders**  
   - `order_id` (PK)  
   - `order_date`  
   - `order_time`

2. **order_details**  
   - `order_details_id` (PK)  
   - `order_id` (FK)  
   - `pizza_id` (FK)  
   - `quantity`

3. **pizzas**  
   - `pizza_id` (PK)  
   - `pizza_type_id` (FK)  
   - `pizza_size`  
   - `unit_price`

4. **pizza_types**  
   - `pizza_type_id` (PK)  
   - `pizza_category`  
   - `pizza_name`  
   - `pizza_ingredients`

---

## Table Creation
```sql
CREATE DATABASE pizza_sales;
USE pizza_sales;
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    order_time TIME,
    PRIMARY KEY (order_id)
);
CREATE TABLE order_details (
    order_id INT,
    quantity INT,
    pizza_id INT
);

-- Add pizza_type_id column separately
ALTER TABLE order_details ADD COLUMN pizza_type_id TEXT;

-- Add index for faster join
ALTER TABLE order_details ADD INDEX idx_order_id (order_id);
CREATE TABLE temp_od (
    order_id INT,
    quantity INT,
    pizza_id INT,
    pizza_type_id TEXT
);

-- Add index for faster join
ALTER TABLE temp_od ADD INDEX idx_order_id (order_id);

CREATE TABLE pizzas (
    pizza_id INT,
    pizza_type_id TEXT,
    pizza_size TEXT,
    unit_price DOUBLE
);
CREATE TABLE pizza_types (
    pizza_type_id TEXT,
    pizza_name TEXT,
    pizza_category TEXT,
    pizza_ingredients TEXT
);
```
---

## Data Insertion
```sql
LOAD DATA LOCAL INFILE 'D:\\Projects\\Pizza_sale_SQL\\pizza_sale_Multi\\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'D:\\Projects\\Pizza_sale_SQL\\pizza_sale_Multi\\order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'D:\\Projects\\Pizza_sale_SQL\\pizza_sale_Multi\\order_details.csv'
INTO TABLE temp_od
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
UPDATE order_details
JOIN temp_od USING (order_id)
SET order_details.pizza_type_id = temp_od.pizza_type_id;
LOAD DATA LOCAL INFILE 'D:\\Projects\\Pizza_sale_SQL\\pizza_sale_Multi\\pizzas.csv'
INTO TABLE pizzas
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'D:\\Projects\\Pizza_sale_SQL\\pizza_sale_Multi\\pizza_types.csv'
INTO TABLE pizza_types
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
```
---

## Business Questions & SQL Queries

### 1. Total number of orders
```sql
SELECT COUNT(*) AS total_orders FROM orders;
```

### 2.  What is the total revenue generated?
```sql
SELECT ROUND(SUM(od.quantity * p.unit_price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;
```

### 3. Which is the highest priced pizza?
```sql
SELECT * FROM pizzas
ORDER BY unit_price DESC
LIMIT 1;
```

### 4. What is the most common quantity ordered?
```sql
SELECT quantity, COUNT(*) AS frequency
FROM order_details
GROUP BY quantity
ORDER BY frequency DESC
LIMIT 1;
```


### 5. What is the most commonly ordered pizza size?
```sql
SELECT pizza_size, COUNT(*) AS count
FROM pizzas
GROUP BY pizza_size
ORDER BY count DESC
LIMIT 1;
```

### 6. What are the top 5 most ordered pizza types (by quantity)?
```sql
SELECT pt.pizza_name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_name
ORDER BY total_quantity DESC
LIMIT 5;
```

### 7. What is the total quantity ordered for each pizza category?
```sql
SELECT pt.pizza_category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_category;
```

### 8. Order distribution by hour of the day
```sql
SELECT HOUR(order_time) AS order_hour, COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;
```

### 9. Category-wise pizza distribution (by count and va
```sql
SELECT pizza_category, COUNT(DISTINCT pizza_name) AS variety_count
FROM pizza_types
GROUP BY pizza_category;
```

### 10. Average number of pizzas ordered per day
```sql
SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT o.order_date), 2) AS avg_pizzas_per_day
FROM order_details od
JOIN orders o ON od.order_id = o.order_id;
```

### 11. Top 3 most ordered pizzas based on revenue
```sql
SELECT pt.pizza_name, SUM(od.quantity * p.unit_price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_name
ORDER BY revenue DESC
LIMIT 3;
```


### 12. Percentage contribution of each category to total revenue
```sql
SELECT pt.pizza_category,
       ROUND(SUM(od.quantity * p.unit_price) * 100.0 /
       (SELECT SUM(od2.quantity * p2.unit_price)
        FROM order_details od2
        JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS revenue_percentage
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_category;
```

### 13. Top 3 best-selling pizzas (by revenue) within each category
```sql
SELECT pizza_category, pizza_name, revenue FROM (
    SELECT pt.pizza_category,
           pt.pizza_name,
           SUM(od.quantity * p.unit_price) AS revenue,
           RANK() OVER(PARTITION BY pt.pizza_category ORDER BY SUM(od.quantity * p.unit_price) DESC) AS rank
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.pizza_category, pt.pizza_name
) ranked
WHERE rank <= 3;
```
---

## Final Thoughts

This project gave me hands-on experience with:
- Writing efficient **SQL queries**.
- Performing **data analysis** using only SQL (no additional libraries/tools).
- Structuring unnormalized data into a **relational schema**.
- Solving real-world business questions using SQL logic.

---

## About Me

I'm Vinay Raghuwanshi, currently pursuing BCA and specializing in Data Analytics and Business Intelligence.  
📧 [vinayraghuwanshi206@gmail.com](mailto:vinayraghuwanshi206@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/vinay-raghuwanshi)

---
