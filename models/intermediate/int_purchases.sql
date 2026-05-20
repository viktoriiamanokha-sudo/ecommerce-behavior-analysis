with purchases as (
    select * from {{ ref('stg_events') }}
),

purchases_agg as (
    select user_id,
    user_session,
    event_time,
    extract(hour from event_time) as hour_of_day,
    dayofweek(event_time) as day_of_week, -- returns 0=Sunday, 6=Saturday
    date_trunc('month', event_time) as purchase_month,
    product_id,
    brand,
    category_code,
    split_part(category_code, '.', 1) as top_category,
    price,
    (case when brand is null then true else false end) as is_unbranded,
    count(*) over (partition by user_session) as items_number,
    sum(price) over (partition by user_session) as session_revenue

    from purchases
    where event_type = 'purchase'

)

select * 
from purchases_agg