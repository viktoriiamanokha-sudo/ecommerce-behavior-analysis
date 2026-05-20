with users as (
        select * from {{ ref('stg_events') }}
),

users_agg as (

        select user_id,

        -- timing
        min(event_time) as first_event_time,
        date_trunc('month', min(event_time)) as cohort_month,
        max(event_time) as last_event_time,
        min(case when event_type = 'purchase' then event_time end) as first_purchase_time,

        -- time to convert
        datediff('day', min(event_time), min(case when event_type = 'purchase' then event_time end)) as days_to_first_purchase,

        -- engagement
        count(distinct user_session) as total_sessions,

        -- revenue
        sum(case when event_type = 'purchase' then coalesce(price, 0) else 0 end) as total_revenue,
        sum(case when event_type = 'purchase' then 1 else 0 end) as total_purchases,

        -- churn flag
        case
        when datediff('day', max(event_time), current_date) > 30
        then true else false
        end as is_churned,

        -- user segment
        case
        when sum(case when event_type = 'purchase' then 1 else 0 end) = 0 then 'browser'
        when sum(case when event_type = 'purchase' then 1 else 0 end) = 1 then 'one-time buyer'
        when sum(case when event_type = 'purchase' then 1 else 0 end) > 1 then 'repeat buyer'
        end as user_type

        from users
        group by 1

)

select *
from users_agg