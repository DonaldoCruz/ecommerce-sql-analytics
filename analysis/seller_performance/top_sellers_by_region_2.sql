-- Slightly compated version of first query top seller by region query. Would be good to compare performance.
with ranked_sellers as (
    select
        oi.seller_id,
        s.seller_state,
        SUM(oi.price) as total_sold,
        ROW_NUMBER() over ( -- This works because window functions are evaluated after the select statement,
            partition by s.seller_state
            -- Aggregations in ORDER BY work because they are 
			-- evaluated after the GROUP BY phase makes them available,
			-- whether or not they appear in the SELECT.
            order by SUM(oi.price) desc
        ) as ranked
    from iceberg.bronze.order_items oi
    left join iceberg.bronze.sellers s on s.seller_id = oi.seller_id
    group by oi.seller_id, s.seller_state
)
select * from ranked_sellers
where ranked <= 3
order by seller_state asc, ranked asc;