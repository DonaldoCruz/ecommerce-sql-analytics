-- Retrieving the top 3 best sellers per region (Brazilian state)

WITH seller_total_by_region AS (
	-- Getting total sold by each seller per region
	SELECT 
		oi.seller_id,
		s.seller_state,
		SUM(oi.price) AS total_sold
	FROM iceberg.bronze.order_items oi
	LEFT JOIN iceberg.bronze.sellers s ON s.seller_id = oi.seller_id
	GROUP BY
		oi.seller_id,
		s.seller_state
),
-- Ranking sellers by total sold, per region
ranked_sellers AS (
	SELECT
		seller_id,
		seller_state,
		total_sold,
		ROW_NUMBER() OVER (PARTITION BY seller_state ORDER BY total_sold DESC) AS ranked
	FROM seller_total_by_region
)

-- Getting top 3 sellers per region
SELECT * 
FROM ranked_sellers
WHERE ranked <= 3
ORDER BY seller_state;
