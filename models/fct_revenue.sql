{{ config(materialized='table') }}

with clean_orders as (
    -- This 'ref' function creates the dependency between models
    select * from {{ ref('stg_orders') }}
)
select
    *,
    (gross_revenue * 0.90) as net_revenue,
    current_timestamp() as processed_at
from clean_orders
