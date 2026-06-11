SELECT COUNT(*)
FROM ecommerce_cleaned;

SELECT *
FROM ecommerce_cleaned;

SELECT @@local_infile;
SET GLOBAL local_infile = 1;

SELECT 
    event_type,
    COUNT(*) AS total_events
FROM ecommerce_cleaned
GROUP BY event_type
ORDER BY total_events DESC;

SELECT
    ROUND((SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END)/SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END)) * 100,2
    ) AS view_to_cart_rate,
    ROUND((SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END)/SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END)) * 100,2
    ) AS cart_to_purchase_rate
FROM ecommerce_cleaned;

SELECT 
    DATE_FORMAT(event_time, '%Y-%m') AS month,
    ROUND(SUM(price), 2) AS revenue
FROM ecommerce_cleaned
WHERE event_type = 'purchase'
GROUP BY DATE_FORMAT(event_time, '%Y-%m')
ORDER BY month;

SELECT category_code, ROUND(SUM(price), 2) AS total_revenue
FROM ecommerce_cleaned
WHERE event_type = 'purchase'
AND category_code <> 'Unknown'
GROUP BY category_code
ORDER BY total_revenue DESC
LIMIT 10;

SELECT brand, ROUND(SUM(price), 2) AS total_revenue
FROM ecommerce_cleaned
WHERE event_type = 'purchase'
AND brand <> 'Unknown'
GROUP BY brand
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        user_id,
        COUNT(*) AS purchases
    FROM ecommerce_cleaned
    WHERE event_type = 'purchase'
    GROUP BY user_id
    HAVING COUNT(*) > 1
) AS repeat_buyers;

SELECT
    user_id,
    ROUND(
        SUM(price),
        2
    ) AS total_spent,
    RANK() OVER (
        ORDER BY SUM(price) DESC
    ) AS customer_rank
FROM ecommerce_cleaned
WHERE event_type = 'purchase'
GROUP BY user_id
LIMIT 10;

SELECT category_code, ROUND(SUM(price), 2) AS revenue,
    ROUND((SUM(price)/(SELECT SUM(price)
                FROM ecommerce_cleaned
                WHERE event_type='purchase')) * 100, 2) AS contribution_percent
FROM ecommerce_cleaned
WHERE event_type='purchase'
AND category_code <> 'Unknown'
GROUP BY category_code
ORDER BY revenue DESC
LIMIT 10;