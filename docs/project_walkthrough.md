```markdown
# Data Engineering Master Documentation: Azure ➔ Snowflake ➔ dbt
**Developer:** Jonatan A. Rivera  
**GitHub:** [jaxrivera](https://github.com/jaxrivera)  
**Stack:** Azure Blob Storage, Snowflake, dbt Core, WSL2/Ubuntu, Git

---

## 1. Project Overview
This project demonstrates a production-grade **Modern Data Stack (MDS)** pipeline using a **Medallion Architecture**. It automates the extraction of raw e-commerce data from Azure, transforms it within Snowflake using dbt, and calculates key business metrics like Net Revenue while enforcing strict security protocols (RBAC).

---

## 2. Infrastructure Setup (Snowflake SQL)
Execute these commands as `ACCOUNTADMIN` to initialize the warehouse, databases, and security roles.

### 2.1 Database & Warehouse Initialization
```sql
-- Create Databases
CREATE OR REPLACE DATABASE PROJ_RAW;
CREATE OR REPLACE DATABASE PROJ_ANALYTICS;

-- Create Compute Warehouse
CREATE OR REPLACE WAREHOUSE PROJ_WH 
    WITH WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60 
    AUTO_RESUME = TRUE;
```

### 2.2 Role-Based Access Control (RBAC)
```sql
-- Create dedicated Data Engineering Role
CREATE ROLE IF NOT EXISTS PROJ_DE_ROLE;

-- Grant permissions to the role
GRANT USAGE ON WAREHOUSE PROJ_WH TO ROLE PROJ_DE_ROLE;
GRANT USAGE ON DATABASE PROJ_RAW TO ROLE PROJ_DE_ROLE;
GRANT USAGE ON DATABASE PROJ_ANALYTICS TO ROLE PROJ_DE_ROLE;

-- Setup the Analytics Schema
CREATE SCHEMA IF NOT EXISTS PROJ_ANALYTICS.MARKETING_TRANSFORMED;
GRANT ALL PRIVILEGES ON SCHEMA PROJ_ANALYTICS.MARKETING_TRANSFORMED TO ROLE PROJ_DE_ROLE;

-- Assign role to user
GRANT ROLE PROJ_DE_ROLE TO USER <YOUR_USERNAME>;
```

---

## 3. Transformation Models (dbt SQL)

### 3.1 Staging Layer (Silver)
**File:** `models/stg_orders.sql`  
*Logic: Data cleaning, type casting, and filtering for 'COMPLETED' status.*

```sql
{{ config(materialized='view') }}

WITH raw_data AS (
    SELECT 
        order_id,
        customer_id,
        CAST(order_date AS DATE) as order_date,
        CAST(amount AS FLOAT) as gross_amount,
        status
    FROM {{ source('raw_source', 'orders') }}
)

SELECT * FROM raw_data
WHERE status = 'COMPLETED'
```

### 3.2 Marts Layer (Gold)
**File:** `models/fct_revenue.sql`  
*Logic: Business metric calculation (Net Revenue = Gross - 10% Marketing Fee).*

```sql
{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

final_calc AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        gross_amount,
        -- Applying 10% marketing fee logic
        (gross_amount * 0.9) AS net_revenue
    FROM orders
)

SELECT * FROM final_calc
```

---

## 4. Local Development & Git Bash Workflow

### 4.1 Environment & dbt Execution
Run these in your WSL2/Ubuntu terminal:
```bash
# Activate Virtual Environment
source dbt_env/bin/activate

# Execute dbt Pipeline
dbt debug    # Verify Snowflake Handshake
dbt run      # Build all models
dbt test     # Run data quality tests
dbt docs generate && dbt docs serve # View Lineage Graph
```

### 4.2 Git Version Control
```bash
# Initialize and Commit
git init
git add .
git commit -m "Pipeline Success: Medallion Architecture with Staging and Revenue Marts"

# Configure Remote and Push
git branch -M main
git remote add origin [https://github.com/jaxrivera/snowflake-dbt-ecommerce.git](https://github.com/jaxrivera/snowflake-dbt-ecommerce.git)
git push -u origin main
```

---

## 5. Troubleshooting Log

| Error Context | Root Cause | Resolution |
| :--- | :--- | :--- |
| **Authentication** | `250001: Incorrect username/password` | Verified Account Locator format in `profiles.yml` (e.g., `thfprst-yyb61847`). |
| **Permissions** | `Insufficient privileges on Schema` | Granted `USAGE` on both Database and Schema to `PROJ_DE_ROLE`. |
| **Git Push** | `Rejected (fetch first)` | Ran `git pull origin main --rebase` to sync remote README changes. |
| **Git Remote** | `fatal: repository not found` | Corrected username typo in URL from `JONATANAX` to `jaxrivera`. |

---

## 6. Technical SOP (Reproduction Guide)
1. **Azure:** Upload raw data to Container `ecommerce-raw`.
2. **Snowflake:** Run the SQL Setup Script (Section 2) to prepare the environment.
3. **dbt:** Update `~/.dbt/profiles.yml` with Snowflake credentials.
4. **Deploy:** Run `dbt run` to materialize the cleaned views and fact tables.
5. **Analyze:** Verify data in the `PROJ_ANALYTICS.MARKETING_TRANSFORMED.FCT_REVENUE` table.

---

## 7. Interview Discussion Points
- **Medallion Architecture:** Explicitly chose to use Bronze/Silver/Gold layers to ensure data modularity and a clear audit trail.
- **Security:** Implemented RBAC to follow the Principle of Least Privilege, avoiding the use of `ACCOUNTADMIN` for routine transformations.
- **Materialization Strategy:** Used **Views** for staging (Silver) to save storage costs and **Tables** for final marts (Gold) to optimize query speed for BI tools.
- **Data Integrity:** Leveraged dbt's `ref()` function to build a Directed Acyclic Graph (DAG), ensuring dependencies are managed automatically.
```
