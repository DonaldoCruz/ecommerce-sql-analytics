-- Aggregation with Conditions (Easy)
-- Question: Find all sellers who have an average delivery time of more than 20 days (from purchase to delivery). 
-- Show seller_id, order_count, and avg_delivery_days.

SELECT 
	sellers.seller_id,
	COUNT(DISTINCT orders.order_id) AS order_count,
	AVG( DATE_DIFF( 'day', orders.order_purchase_timestamp, orders.order_delivered_customer_date) ) AS average_delivery_days
FROM iceberg.bronze.sellers
INNER JOIN iceberg.bronze.order_items ON sellers.seller_id = order_items.seller_id
INNER JOIN iceberg.bronze.orders ON order_items.order_id = orders.order_id and orders.order_status = 'delivered'
GROUP BY sellers.seller_id
HAVING AVG( DATE_DIFF( 'day', orders.order_purchase_timestamp, orders.order_delivered_customer_date) ) > 20;
