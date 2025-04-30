
-- 1. Total number of orders
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders;

-- 2. Total Revenue Generated
SELECT 
    ROUND(SUM(od.quantity * p.unit_price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
    
-- 3. highest priced Pizza
SELECT 
    p.unit_price, pt.pizza_name
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY unit_price DESC
LIMIT 1;
    
-- 4. most common quantity ordered
SELECT 
    quantity, COUNT(order_id)
FROM
    pizza_sales
GROUP BY quantity;

-- 5. most common pizza size ordered
SELECT 
    pizzas.pizza_size, COUNT(od.order_id)
FROM
    pizzas
        JOIN
    order_details od ON pizzas.pizza_id = od.pizza_id
GROUP BY pizza_size
LIMIT 1;
 
-- 6. top 5 pizzas types types along with quantity
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


-- Itermidiate Level Questions 
-- 7 Total Quantity of each pizza category 
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

-- 8. Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours
ORDER BY order_count DESC;

-- 9. Category wise distribution of pizzas
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
ORDER BY no_of_pizzas DESC;

-- 10. Calculate the average number of pizzas ordered per day  

SELECT 
    ROUND(AVG(Quantity), 0) AS avg_order_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY order_date) AS order_quantity;

-- 11.Top 3 most ordered pizzas based on revenue
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

-- 12. Percentage contribution of each category to total revenue
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


-- 13. Top 3 best-selling pizzas (by revenue) within each category

select pizza_name, revenue,rn from (select pizza_category,pizza_name,revenue, rank() over (partition by pizza_category order by revenue desc) as rn from 
(SELECT 
    pizza_types.pizza_category,
    pizza_types.pizza_name,
    SUM(pizzas.unit_price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.pizza_category,pizza_types.pizza_name) as a) as b where rn <=3;