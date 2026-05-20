with users as (
    select * from {{ ref('int_users') }}
),

users_final as (
select *,
-- revenue per session (safe division)
{{ safe_divide('total_revenue', 'total_sessions') }} as avg_revenue_per_session,
-- revenue tier
case
    when total_revenue = 0 then '0. No purchase'
    when total_revenue < 50 then '1. Low (< $50)'
    when total_revenue < 200 then '2. Mid ($50-200)'
    when total_revenue >= 200 then '3. High (> $200)'
end as revenue_tier,

-- engagement tier
case
    when total_sessions = 1 then '1. Single visit'
    when total_sessions <= 5 then '2. Occasional (2-5)'
    when total_sessions <= 20 then '3. Regular (6-20)'
    when total_sessions > 20 then '4. Power user (20+)'
end as engagement_tier,

-- conversion speed
case
    when days_to_first_purchase is null  then 'Never converted'
    when days_to_first_purchase = 0 then 'Same day'
    when days_to_first_purchase <= 7 then 'Within a week'
    when days_to_first_purchase <= 30 then 'Within a month'
    else 'Over a month'
end as conversion_speed

from users
)

select *
from users_final