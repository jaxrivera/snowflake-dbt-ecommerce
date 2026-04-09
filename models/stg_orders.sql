with raw_data as (
    -- Reference the table we loaded from Azure
    select * from PROJ_RAW.ECOMMERCE.ORDERS
)
select
    order_id,
    customer_id,
    cast(order_date as date) as order_date,
    revenue_amount as gross_revenue,
    upper(product_category) as category
from raw_data
where order_id is not null
