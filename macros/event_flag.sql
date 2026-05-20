{% macro event_flag(event_type, agg='max') %}
    {#
        Generates a boolean flag or count for a specific event type.

        Args:
            event_type: the event to check ('view', 'cart', 'purchase')
            agg: aggregation function — 'max' for flag (0/1), 'sum' for count

        Usage:
            {{ event_flag('view') }}           -- has_view flag
            {{ event_flag('view', 'sum') }}    -- views_count
    #}

    {{ agg }}(case when event_type = '{{ event_type }}' then 1 else 0 end)

{% endmacro %}