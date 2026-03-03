-- Might be more readable with CTEs.
with monthly_total as (
	select 
		date_trunc('month', o.order_purchase_timestamp) as purchase_month,
		SUM(oi.price) as monthly_total
	from iceberg.bronze.order_items oi
	left join iceberg.bronze.orders o on o.order_id = oi.order_id 
	where
		o.order_status = LOWER('delivered')
		and DATE(o.order_purchase_timestamp) between DATE('2017-01-01') and DATE('2017-12-31')
	group by date_trunc('month', o.order_purchase_timestamp)
	order by purchase_month
)
select 
	purchase_month,
	monthly_total,
	SUM(monthly_total) over (order by purchase_month) as running_total
from monthly_total;

