with events as (

    select * from {{ ref('stg_events') }}


),

session_agg as (

    select
        user_id,
        user_session,

        min(event_time) as session_start,
        max(event_time) as session_end,

        -- duration in minutes
        datediff(
            'minute',
            min(event_time),
            max(event_time)
        ) as session_duration_minutes,

        count(*) as events_count,

        -- behavioral flags
        {{ event_flag('view') }} as has_view,
        {{ event_flag('cart') }} as has_cart,
        {{ event_flag('purchase') }} as has_purchase,

        -- counts per event type
        {{ event_flag('view', 'sum') }} as views_count,
        {{ event_flag('cart', 'sum') }} as carts_count,
        {{ event_flag('purchase', 'sum') }} as purchases_count,

        -- revenue (coalesce guards against NULL price rows)
        sum(
            case when event_type = 'purchase'
            then coalesce(price, 0) else 0 end
        ) as session_revenue,

        -- product diversity in session
        count(distinct product_id) as unique_products_viewed,
        count(distinct category_code) as unique_categories,
        count(distinct brand) as unique_brands

    from events
    group by 1, 2

),

session_with_stage as (

    select
        *,

        -- deepest funnel stage reached in this session
        case
            when has_purchase = 1 then 'purchased'
            when has_cart     = 1 then 'carted'
            when has_view     = 1 then 'viewed'
            else 'unknown'
        end as session_stage

    from session_agg

)

select * from session_with_stage