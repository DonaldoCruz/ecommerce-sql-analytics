
-- Sellers scorecard
SELECT 
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
	SUM(oi.price) AS monthly_total,
	-- Inner sum is the aggregation of the group by, second sum is to calculate running total
	SUM(SUM(oi.price)) OVER (ORDER BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS cummulative_sum
from iceberg.bronze.order_items oi
LEFT JOIN iceberg.bronze.orders o on o.order_id = oi.order_id 
WHERE
	o.order_status = LOWER('delivered')
	AND DATE(o.order_purchase_timestamp) between DATE('2017-01-01') AND DATE('2017-12-31')
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY purchase_month;
