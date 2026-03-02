-- Retrieving the top 3 best sellers per region (Brazilian state)

with seller_total_by_region as (
	-- Getting total sold by each seller per region
	select 
		oi.seller_id,
		s.seller_state,
		SUM(oi.price) as total_sold
	from iceberg.bronze.order_items oi
	left join iceberg.bronze.sellers s on s.seller_id = oi.seller_id
	group by 
		oi.seller_id,
		s.seller_state
),
-- Ranking sellers by total sold, per region
ranked_sellers as (
	select
		seller_id,
		seller_state,
		total_sold,
		ROW_NUMBER() over (partition by seller_state order by total_sold desc) as ranked
	from seller_total_by_region
)

-- Getting top 3 sellers per region
select * 
from ranked_sellers
where ranked <= 3
order by seller_state;
