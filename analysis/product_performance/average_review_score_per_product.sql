-- Question: Find the average review score for each product category (in English). 
-- Only include categories with at least 50 reviews. Order by average score descending.

-- reviews, order items, products
SELECT 
	category_translation.product_category_name_english AS category,
	COUNT(reviews.review_id) as number_of_reviews,
	AVG(reviews.review_score) AS average_review_score
FROM iceberg.bronze.order_items AS items
INNER JOIN iceberg.bronze.reviews ON items.order_id = reviews.order_id
INNER JOIN iceberg.bronze.products on items.product_id = products.product_id
INNER JOIN iceberg.bronze.category_translation on products.product_category_name = category_translation.product_category_name
GROUP BY category_translation.product_category_name_english
HAVING COUNT(reviews.review_score) >= 50 
ORDER BY average_review_score DESC;
