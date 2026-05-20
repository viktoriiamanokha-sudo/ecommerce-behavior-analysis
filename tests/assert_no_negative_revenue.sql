-- this test PASSES if it returns zero rows
-- it FAILS if any rows have negative revenue

select *
from {{ ref('fct_purchases') }}
where session_revenue < 0