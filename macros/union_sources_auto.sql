{% macro union_sources_auto(schema, prefix) %}

    {% set query %}
        select table_name
        from information_schema.tables
        where table_schema  = upper('{{ schema }}')
        and   table_name    ilike '{{ prefix }}%'
        and   table_type    = 'BASE TABLE'
        order by table_name
    {% endset %}

    {% if execute %}

        {% set results     = run_query(query) %}
        {% set table_names = results.columns[0].values() %}

        {% if table_names | length == 0 %}
            {{ exceptions.raise_compiler_error(
                "No tables found with prefix '" ~ prefix ~ "' in schema '" ~ schema ~ "'"
            ) }}
        {% endif %}

        {% for table_name in table_names %}
            select * from {{ target.database }}.{{ schema }}.{{ table_name }}
            {% if not loop.last %}union all{% endif %}
        {% endfor %}

    {% else %}
        select null as placeholder where false
    {% endif %}

{% endmacro %}