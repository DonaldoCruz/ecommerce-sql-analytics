
-- Sellers scorecard
select 
	date_format(o.order_purchase_timestamp, '%Y-%m') as purchase_month,
	SUM(oi.price) as monthly_total,
	-- Inner sum is the aggregation of the group by, second sum is to calculate running total
	SUM(SUM(oi.price)) over (order by date_format(o.order_purchase_timestamp, '%Y-%m')) as cummulative_sum
from iceberg.bronze.order_items oi
left join iceberg.bronze.orders o on o.order_id = oi.order_id 
where
	o.order_status = LOWER('delivered')
	and DATE(o.order_purchase_timestamp) between DATE('2017-01-01') and DATE('2017-12-31')
group by date_format(o.order_purchase_timestamp, '%Y-%m')
order by purchase_month;
