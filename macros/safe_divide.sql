{% macro safe_divide(numerator, denominator) %}
    {#
        Safely divides two values, returning null instead of
        crashing when denominator is zero or null.

        Args:
            numerator: the top value
            denominator: the bottom value

        Usage:
            {{ safe_divide('revenue', 'sessions') }}
            {{ safe_divide('purchased * 100.0', 'viewed') }}
    #}

    case
        when {{ denominator }} = 0
          or {{ denominator }} is null
        then null
        else {{ numerator }} / {{ denominator }}
    end

{% endmacro %}