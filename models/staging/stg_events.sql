with unioned as (

     {{ union_sources_auto('RAW', 'RAW_EVENTS_') }}

),

cleaned as (

    select
        user_id,
        user_session,
        lower(event_type) as event_type,
        product_id,
        category_code,
        brand,
        try_cast(price as float) as price,
        cast(
            convert_timezone(
            'UTC',
            try_to_timestamp(event_time, 'YYYY-MM-DD HH24:MI:SS UTC')
            ) as timestamp_ntz
            ) as event_time

    from unioned
    where user_id is not null and user_session is not null

)

select * from cleaned