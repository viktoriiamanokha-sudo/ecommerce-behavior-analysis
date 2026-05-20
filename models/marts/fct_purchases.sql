{{
    config(
        materialized='incremental',
        unique_key=['user_session', 'product_id', 'event_time'],
        on_schema_change='sync_all_columns'
    )
}}

with purchases as (
    select * from {{ ref('int_purchases') }}

        -- only new rows on incremental runs
    {% if is_incremental() %}
        where event_time > (
            select max(event_time) from {{ this }}
        )
    {% endif %}
    
),

users as (
    select * from {{ ref('dim_users') }}
),

joined as (
    select p.*,
        avg(p.session_revenue) over (partition by p.user_id) as user_avg_session_spend,
        u.cohort_month,
        u.user_type,
        u.revenue_tier,
        u.engagement_tier,
        u.conversion_speed
    from purchases p
    left join users u on p.user_id = u.user_id
),

final as (
    select *,
        -- spend comparison
        case
            when session_revenue > user_avg_session_spend then 'Above average'
            when session_revenue = user_avg_session_spend then 'Average'
            else 'Below average'
        end as spend_vs_user_avg,

        -- time of day
        case
            when hour_of_day between 6  and 11 then '1. Morning'
            when hour_of_day between 12 and 17 then '2. Afternoon'
            when hour_of_day between 18 and 22 then '3. Evening'
            else '4. Night'
        end as time_of_day,

        -- day of week (Snowflake dayofweek: 0=Sun, 6=Sat)
        case day_of_week
            when 0 then '1. Sunday'
            when 1 then '2. Monday'
            when 2 then '3. Tuesday'
            when 3 then '4. Wednesday'
            when 4 then '5. Thursday'
            when 5 then '6. Friday'
            when 6 then '7. Saturday'
        end as day_name,

        -- price bucket
        case
            when price < 20  then '1. Low (< $20)'
            when price < 100 then '2. Mid ($20-100)'
            when price < 500 then '3. High ($100-500)'
            else '4. Premium (> $500)'
        end as price_tier,

        -- basket size
        case
            when items_number = 1 then '1. Single item'
            when items_number <= 3 then '2. Small (2-3)'
            when items_number <= 10 then '3. Medium (4-10)'
            else '4. Large (10+)'
        end as basket_size

        from joined
)

select * from final