-- Might be more readable WITH CTEs.
WITH monthly_total AS (
	SELECT 
		date_trunc('month', o.order_purchase_timestamp) AS purchase_month,
		SUM(oi.price) AS monthly_total
	FROM iceberg.bronze.order_items oi
	LEFT JOIN iceberg.bronze.orders o on o.order_id = oi.order_id 
	WHERE
		o.order_status = LOWER('delivered')
		AND DATE(o.order_purchase_timestamp) between DATE('2017-01-01') 
        AND DATE('2017-12-31')
	GROUP BY date_trunc('month', o.order_purchase_timestamp)
	ORDER BY purchase_month
)
SELECT 
	purchase_month,
	monthly_total,
	SUM(monthly_total) OVER (ORDER BY purchase_month) AS running_total
FROM monthly_total;

