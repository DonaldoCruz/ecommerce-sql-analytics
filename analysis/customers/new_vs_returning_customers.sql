-- Question: Find customers who made a purchase in Q1 2018 but did NOT make any purchase in Q4 2017. 
-- These are "new" or "reactivated" customers.

-- Used ANTI JOIN pattern, using CTEs can make much cleaner.
SELECT DISTINCT  customers_q1.customer_unique_id
FROM iceberg.bronze.orders as orders_q1
INNER JOIN iceberg.bronze.customers as customers_q1 on orders_q1.customer_id = customers_q1.customer_id 
WHERE 
	EXTRACT(YEAR FROM orders_q1.order_purchase_timestamp) = 2018 
	AND EXTRACT(QUARTER FROM orders_q1.order_purchase_timestamp) = 1
	AND NOT EXISTS (
		SELECT 
			1
		FROM iceberg.bronze.orders AS orders_q4
		INNER JOIN iceberg.bronze.customers AS customers_q4 ON orders_q4.customer_id = customers_q4.customer_id 
		WHERE 
			EXTRACT(YEAR FROM orders_q4.order_purchase_timestamp) = 2017
			AND EXTRACT(QUARTER FROM orders_q4.order_purchase_timestamp) = 4
 			AND customers_q1.customer_unique_id = customers_q4.customer_unique_id 
);

