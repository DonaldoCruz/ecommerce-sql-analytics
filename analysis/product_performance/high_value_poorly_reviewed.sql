-- Question: Find product categories where the average order value is above $100, 
-- the average review score is below 3.5, 
-- AND there are at least 30 orders. 
-- These are "high-value but poorly reviewed" categories — potential quality issues.

SELECT
	category_translation.product_category_name_english,
	AVG( order_items.price + order_items.freight_value)	AS average_order_value,
	AVG(reviews.review_score) AS average_review_score,
	COUNT(distinct orders.order_id) AS total_orders
from iceberg.bronze.order_items
INNER JOIN iceberg.bronze.orders ON order_items.order_id = orders.order_id
INNER JOIN iceberg.bronze.reviews ON orders.order_id= reviews.order_id
INNER JOIN iceberg.bronze.products ON order_items.product_id = products.product_id
INNER JOIN iceberg.bronze.category_translation ON products.product_category_name = category_translation.product_category_name 
GROUP BY category_translation.product_category_name_english
HAVING 
	AVG( order_items.price + order_items.freight_value) >= 100.0
	AND AVG(reviews.review_score) < 3.5
	AND COUNT(distinct orders.order_id) >= 30;