-- SECTION 1: CREATE TABLES

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    order_date DATE,
    order_status VARCHAR(20)
);


-- SECTION 2: INSERT SAMPLE DATA

INSERT INTO products (product_id, product_name, category, price)
VALUES
(101, 'Kurta', 'Clothing', 800),
(102, 'Shoes', 'Footwear', 1500),
(103, 'Bag', 'Accessories', 600),
(104, 'Jeans', 'Clothing', 1200),
(105, 'Watch', 'Accessories', 2000);

INSERT INTO orders (
    order_id, customer_name, product_id,
    quantity, order_date, order_status
)
VALUES
(201, 'Ananya', 101, 2, '2026-10-01', 'Delivered'),
(202, 'Rahul', 102, 1, '2026-10-01', 'Delivered'),
(203, 'Priya', 103, 3, '2026-10-02', 'Delivered'),
(204, 'Arjun', 104, 2, '2026-10-03', 'Cancelled'),
(205, 'Sneha', 105, 1, '2026-10-03', 'Delivered'),
(206, 'Ananya', 102, 2, '2026-10-04', 'Delivered'),
(207, 'Rahul', 101, 1, '2026-10-05', 'Delivered'),
(208, 'Priya', 104, 1, '2026-10-05', 'Delivered');


-- SECTION 3: VIEW PRODUCTS

SELECT *
FROM products;


-- SECTION 4: VIEW ORDERS

SELECT *
FROM orders;


-- SECTION 5: JOIN ORDERS WITH PRODUCTS

SELECT
    o.order_id,
    o.customer_name,
    p.product_name,
    p.category,
    o.quantity,
    p.price,
    o.order_status
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
ORDER BY o.order_id;


-- SECTION 6: CALCULATE AMOUNT PER ORDER

SELECT
    o.order_id,
    o.customer_name,
    p.product_name,
    o.quantity,
    p.price,
    o.quantity * p.price AS order_amount,
    o.order_status
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
ORDER BY order_amount DESC;


-- SECTION 7: TOTAL DELIVERED REVENUE

SELECT
    SUM(o.quantity * p.price) AS total_delivered_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered';


-- SECTION 8: PRODUCT-WISE REVENUE AND UNITS SOLD

SELECT
    p.product_name,
    SUM(o.quantity) AS total_units_sold,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- SECTION 9: CATEGORY-WISE REVENUE

SELECT
    p.category,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;


-- SECTION 10: CANCELLATION RATE

SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate_percentage
FROM orders;


-- SECTION 11: CUSTOMER-WISE TOTAL SPENDING

SELECT
    o.customer_name,
    COUNT(*) AS total_orders,
    SUM(o.quantity * p.price) AS total_spending
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY o.customer_name
ORDER BY total_spending DESC;


-- SECTION 12: DAILY DELIVERED REVENUE

SELECT
    o.order_date,
    COUNT(*) AS delivered_orders,
    SUM(o.quantity * p.price) AS daily_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_date
ORDER BY o.order_date;


-- SECTION 13: BEST-SELLING PRODUCTS BY QUANTITY

SELECT
    p.product_name,
    SUM(o.quantity) AS units_sold
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_name
ORDER BY units_sold DESC, p.product_name;


-- SECTION 14: ORDER STATUS SUMMARY

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- SECTION 15: CUSTOMER REVENUE RANKING

SELECT
    o.customer_name,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY o.customer_name
ORDER BY total_revenue DESC;


-- SECTION 16: AVERAGE DELIVERED ORDER VALUE

SELECT
    ROUND(
        AVG(o.quantity * p.price),
        2
    ) AS average_order_value
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered';


-- SECTION 17: PRODUCTS NEVER ORDERED

SELECT
    p.product_id,
    p.product_name,
    p.category
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
WHERE o.order_id IS NULL;


-- SECTION 18: CATEGORY REVENUE CONTRIBUTION

SELECT
    p.category,
    SUM(o.quantity * p.price) AS total_revenue,
    ROUND(
        100.0 * SUM(o.quantity * p.price) /
        SUM(SUM(o.quantity * p.price)) OVER (),
        2
    ) AS revenue_percentage
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;


-- SECTION 19: DAILY REVENUE WITH RUNNING TOTAL

SELECT
    daily_sales.order_date,
    daily_sales.daily_revenue,
    SUM(daily_sales.daily_revenue) OVER (
        ORDER BY daily_sales.order_date
    ) AS running_revenue
FROM (
    SELECT
        o.order_date,
        SUM(o.quantity * p.price) AS daily_revenue
    FROM orders AS o
    JOIN products AS p
        ON o.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.order_date
) AS daily_sales
ORDER BY daily_sales.order_date;


-- SECTION 20: HIGHEST-REVENUE PRODUCT

SELECT
    p.product_name,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders AS o
JOIN products AS p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 1;


-- SECTION 21: OVERALL BUSINESS KPIs

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'Delivered'
    ) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        ) / COUNT(*),
        2
    ) AS cancellation_rate_percentage
FROM orders;
