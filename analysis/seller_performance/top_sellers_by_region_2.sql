-- Slightly compated version of first query top seller by region query. Would be good to compare performance.
WITH ranked_sellers AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        SUM(oi.price) AS total_sold,
        ROW_NUMBER() OVER ( -- This works because window functions are evaluated after the select statement,
            PARTITION BY s.seller_state
            -- Aggregations in ORDER BY work because they are 
			-- evaluated after the GROUP BY phase makes them available,
			-- whether or not they appear in the SELECT.
            ORDER BY SUM(oi.price) DESC
        ) AS ranked
    FROM iceberg.bronze.order_items oi
    LEFT JOIN iceberg.bronze.sellers s ON s.seller_id = oi.seller_id
    GROUP BY oi.seller_id, s.seller_state -- Could this cause inconsitencies since we are getting seller data from two different tables?
)
SELECT * FROM ranked_sellers
WHERE ranked <= 3
ORDER BY seller_state, ranked;