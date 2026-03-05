-- Question: For each seller, 
-- calculate their monthly revenue and the month-over-month percentage change. 
-- Flag any month where revenue dropped more than 50% compared to the previous month.

-- Step 1: Calculate monthly revenue per seller
with monthly_seller_revenue as (
	select 
		oi.seller_id,
		date_format(o.order_purchase_timestamp, '%Y-%m') month,
		SUM(oi.price) + SUM(oi.freight_value)  as total_revenue
	from iceberg.bronze.order_items oi
	left join iceberg.bronze.orders o on o.order_id = oi.order_id 
	group by oi.seller_id, date_format(o.order_purchase_timestamp, '%Y-%m')
),
-- Now add last months revenue to table.
month_over_month  as (
	select 
		seller_id,
		month,
		total_revenue,
		lag(total_revenue) over (
			partition by seller_id 
			order by month asc
		) as last_month_revenue
	from monthly_seller_revenue
)
-- Now calculating percentage change and flaging when revenue drops more than 50%
select 
	seller_id,
	month,
	total_revenue,
	last_month_revenue,
	round((total_revenue - last_month_revenue) / last_month_revenue * 100, 2) as percent_change,
	round((total_revenue - last_month_revenue) / last_month_revenue * 100, 2) < -50 as drop_flag
from month_over_month
order by seller_id, month asc;
