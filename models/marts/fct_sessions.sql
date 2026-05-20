with sessions as (
    select * from {{ ref('int_sessions') }}

),

users as (
    select * from {{ ref('dim_users') }}
),

final as (
select s.*,
case
    when s.session_duration_minutes is null then '0. Instant'
    when s.session_duration_minutes < 10 then '1. Short'
    when s.session_duration_minutes < 30 then '2. Mid'
    when s.session_duration_minutes >= 30 then '3. Long'
end as session_duration_category,
u.cohort_month, 
u.user_type, 
u.revenue_tier, 
u.engagement_tier, 
u.conversion_speed

from sessions s
left join users u
on s.user_id = u.user_id
)

select *
from final