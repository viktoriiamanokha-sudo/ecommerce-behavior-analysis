-- marts/fct_category_summary.sql
select
    split_part(category_code, '.', 1) as top_category,
    user_type,
    basket_size,
    count(*) as purchases,
    sum(price) as revenue
from fct_purchases p
left join dim_users u using (user_id)
group by 1, 2, 3