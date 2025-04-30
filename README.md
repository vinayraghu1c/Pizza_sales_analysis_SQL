# Pizza Sales Analysis — SQL Project

Welcome to the **Pizza Sales Analysis** project! This project showcases how SQL is used to extract meaningful business insights from a normalized pizza sales dataset. The dataset has been imported from Kaggle and structured into multiple relational tables for optimal querying.

---

## Project Structure

This project includes:

- **Database Schema Creation**
- **13 Business Questions**
- **Data Import**
- **SQL Queries and Insights**

---

## Objective

To analyze a pizza sales dataset using SQL and answer key business questions related to sales performance, customer ordering behavior, and revenue trends.

---

## Tech Stack

- **Database Tool**: MySQL Workbench 
- **Dataset Source**: [Kaggle - Pizza Sales](https://www.kaggle.com/code/mdismielhossenabir/pizza-sales-dataset) - manually normalized into a relational format

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
9. Category-wise pizza distribution 
10. Average number of pizzas ordered per day


 ### 🔹 Advanced-Level Analysis:
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
- It was split into **four normalized tables** using Excel for efficient relational analysis.
- Temporary tables were used for joining and updating missing fields using SQL joins.

---

## Database Schema

The database consists of 4 tables:

1. ** orders **
   - `order_id` (PK)  
   - `order_date`  
   - `order_time`

2. **order_details**  
   -  
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
        JOIN
    temp_od USING (order_id) 
SET 
    order_details.pizza_type_id = temp_od.pizza_type_id;
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
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders;
```

### 2.  What is the total revenue generated?
```sql
SELECT 
    ROUND(SUM(od.quantity * p.unit_price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
```

### 3. Which is the highest priced pizza?
```sql
SELECT 
    p.unit_price, pt.pizza_name
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY unit_price DESC
LIMIT 1;
```

### 4. What is the most common quantity ordered?
```sql
SELECT 
    quantity, COUNT(order_id)
FROM
    pizza_sales
GROUP BY quantity;
```


### 5. What is the most commonly ordered pizza size?
```sql
SELECT 
    pizzas.pizza_size, COUNT(od.order_id)
FROM
    pizzas
        JOIN
    order_details od ON pizzas.pizza_id = od.pizza_id
GROUP BY pizza_size
LIMIT 1;
```

### 6. What are the top 5 most ordered pizza types (by quantity)?
```sql
SELECT 
    pt.pizza_name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas ON pt.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details od ON pizzas.pizza_id = od.pizza_id
GROUP BY pizza_name
ORDER BY quantity DESC
LIMIT 5;
```

### 7. What is the total quantity ordered for each pizza category?
```sql
SELECT 
    pt.pizza_category, SUM(od.quantity) AS order_quantity
FROM
    order_details od
        JOIN
    pizzas ON od.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_category
ORDER BY order_quantity DESC;
```

### 8. Order distribution by hour of the day
```sql
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours
ORDER BY order_count DESC;
```

### 9. Category-wise pizza distribution 
```sql
SELECT 
    pizza_category,
    SUM(quantity),
    COUNT(DISTINCT pizza_name) AS no_of_pizzas
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_category
ORDER BY no_of_pizzas DESC;```

### 10. Average number of pizzas ordered per day
```sql
SELECT 
    ROUND(AVG(Quantity), 0) AS avg_order_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY order_date) AS order_quantity;
```

### 11. Top 3 most ordered pizzas based on revenue
```sql
SELECT 
    SUM(pizzas.unit_price * order_details.quantity) AS revenue,
    pizza_name
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_name
ORDER BY revenue DESC
LIMIT 3;

```


### 12. Percentage contribution of each category to total revenue
```sql
SELECT 
    pizza_types.pizza_category,
    (SUM(order_details.quantity * pizzas.unit_price) / (SELECT 
            SUM(order_details.quantity * pizzas.unit_price) AS revenue
        FROM
            pizza_types
                JOIN
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                JOIN
            order_details ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_category
ORDER BY revenue DESC;


```

### 13. Top 3 best-selling pizzas (by revenue) within each category
```sql
SELECT 
    pizza_types.pizza_category,
    (SUM(order_details.quantity * pizzas.unit_price) / (SELECT 
            SUM(order_details.quantity * pizzas.unit_price) AS revenue
        FROM
            pizza_types
                JOIN
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                JOIN
            order_details ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_category
ORDER BY revenue DESC;

```
---

## Final Thoughts

This project gave me hands-on experience with:
- Writing efficient **SQL queries**.
- Performing **data analysis** using only SQL (no additional libraries/tools).
- Structuring unnormalized data into a **relational schema**.
- Solving real-world business problems using SQL logic.

---

## About Me

I'm Vinay Raghuwanshi, currently pursuing BCA and specializing in Data Analytics and Business Intelligence.  

📧 [vinayraghuwanshi206@gmail.com](mailto:vinayraghuwanshi206@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/vinay-raghuwanshi)

---
