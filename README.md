# Cloud-Native Ecommerce ELT Pipeline
### Snowflake | dbt Core | Azure Blob Storage | WSL2

## 🚀 Project Overview
This project demonstrates a production-grade Modern Data Stack (MDS) pipeline. It automates the journey of ecommerce data from raw cloud storage to a refined "Gold" analytics layer, enabling business stakeholders to track Net Revenue after marketing overhead.

## 🏗 Architecture (Medallion)
- **Bronze (Raw):** Ingested raw JSON/CSV data from Azure Blob Storage into Snowflake `PROJ_RAW`.
- **Silver (Staging):** dbt views (`stg_orders`) used for data cleaning, type casting, and filtering.
- **Gold (Marts):** Materialized tables (`fct_revenue`) applying business logic and KPI calculations.

## 🛠 Key Features
- **Security First:** Implemented Snowflake RBAC (Role-Based Access Control) using a dedicated `PROJ_DE_ROLE`.
- **Modularity:** Utilized dbt `ref()` functions to build a DAG (Directed Acyclic Graph), ensuring data integrity.
- **Scalability:** Integrated Azure Storage via Snowflake Storage Integrations for high-throughput data loading.

## 📈 Data Lineage
(Run `dbt docs generate` to view the full graph)
[Raw Azure Data] -> [stg_orders (View)] -> [fct_revenue (Table)]


## 📖 Project Documentation
For detailed guides on this project, please see the following:
- [Implementation Notes](./docs/IMPLEMENTATION_NOTES.md) - *Interview Prep & Architecture Logic*
- [Reproduction Guide](./docs/REPRODUCE.md) - *Setup & Execution Instructions*
- [Troubleshooting Log](./docs/TROUBLESHOOTING.md) - *Resolved Errors & Blockers*
