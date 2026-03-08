-- Question: For each seller, 
-- calculate their monthly revenue and the month-over-month percentage change. 
-- Flag any month where revenue dropped more than 50% compared to the previous month.

-- Step 1: Calculate monthly revenue per seller
WITH monthly_seller_revenue AS (
	SELECT 
		oi.seller_id,
		DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
		SUM(oi.price) + SUM(oi.freight_value)  AS total_revenue
	FROM iceberg.bronze.order_items oi
	LEFT JOIN iceberg.bronze.orders o on o.order_id = oi.order_id 
	GROUP BY oi.seller_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),
-- Now add last months revenue to table.
month_over_month  AS (
	SELECT 
		seller_id,
		month,
		total_revenue,
		LAG(total_revenue) over (
			partition by seller_id 
			ORDER BY month asc
		) AS last_month_revenue
	FROM monthly_seller_revenue
)
-- Now calculating percentage change and flaging when revenue drops more than 50%
SELECT 
	seller_id,
	month,
	total_revenue,
	last_month_revenue,
	ROUND((total_revenue - last_month_revenue) / NULLIF(last_month_revenue, 0) * 100, 2) AS percent_change,
	ROUND((total_revenue - last_month_revenue) / NULLIF(last_month_revenue, 0) * 100, 2) < -50 AS drop_flag
FROM month_over_month
ORDER BY seller_id, month ASC;
