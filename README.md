# ☕ NYC Coffee Shop Data Engineering & Analytics

A comprehensive PostgreSQL-based ELT project analyzing retail operations across three key New York City neighborhoods. This repository demonstrates full-cycle data handling: from environment containerization and raw data ingestion to complex analytical modeling.

## 📁 Repository Structure

*   **`data/`**: Source datasets including product variants, store boundaries (GeoJSON/CSV), and transaction logs.
*   **`init/`**: SQL initialization scripts for database setup, raw data loading, and ELT processes.
*   **`analytics_schema/`**: Final transformed tables optimized for BI tools and reporting.
*   **`docs/`**: Data dictionary and detailed technical documentation.
*   **`erd/`**: Entity Relationship Diagrams showing the normalized database architecture.

## 🛠 Technical Stack
- **Database:** PostgreSQL (Advanced features: Window functions, CTEs, Geo-spatial logic)
- **Environment:** Docker (Multi-container setup)
- **Tools:** VS Code, pgAdmin4
- **Methodology:** ELT (Extract, Load, Transform)

## 🛠️ Technical Deep Dive

### 1. Spatial Analytics (PostGIS)
Since the dataset provides neighborhood boundaries rather than specific coordinates, I implemented **PostGIS** to calculate spatial metrics:
*   **Density Analysis:** Calculated sales revenue per km² by mapping transactions to store boundaries.
*   **Schema Design:** Utilized `GEOMETRY(Polygon, 4326)` for the `store_locations` table and implemented a staging workflow for WKT (Well-Known Text) data imports.

### 2. Performance Optimization & Indexing
To ensure the `analytics_schema` remains performant as transaction volume grows, I implemented a strategic indexing plan:
*   **B-Tree Indexes:** Applied to foreign keys (`store_id`, `product_variant_id`) to accelerate join operations.
*   **Composite Indexes:** Optimized frequent analytical patterns, such as `(date, store_id)` and `(store_id, product_variant_id)`, reducing query execution time for time-series and categorical reporting.
*   **Storage Optimization:** Refactored data types (e.g., `Numeric` to `INT` where appropriate) to minimize disk footprint and memory overhead.

### 3. Data Normalization (3NF)
Transformed raw Kaggle CSVs into a structured relational model:
*   **Hierarchical Mapping:** `Categories` -> `Products` -> `Product Variants`.
*   **Integrity:** Enforcement of Primary and Foreign Key constraints to ensure data consistency across the `transactions` ledger.


## 🏗 Database Architecture & ELT Process
The project follows a modern data warehouse approach:
1.  **Raw Ingestion:** Transactions and product metadata are loaded into a `raw` schema.
2.  **Transformation:** Data is cleaned and normalized into a structured relational model (refer to `erd/coffee_shop.png`).
3.  **Analytics Layer:** Final business logic is applied to create the `analytics_schema`, designed for rapid querying of KPIs.

## 📊 Analytics Focus Areas
- **Revenue Intelligence:** Analysis of `coffee-shop-sales-revenue.csv` to identify high-margin product variants.
- **Geospatial Insights:** Utilizing `store_location_boundaries.csv` to analyze performance based on neighborhood demographics and footprint.
- **Product Strategy:** Mapping `categories` and `product_variants` to understand stock-keeping unit (SKU) performance.
- **Temporal Patterns:** Transactional analysis to determine peak-hour staffing requirements for Manhattan, Brooklyn, and Queens locations.

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose installed.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Hrz17PMardev/Coffee-Shop.git
   ```
2. Spin up the environment:
   ```bash
   docker-compose up -d
   ```
   *The scripts in `/init` will automatically run in sequence to build the DB, create schemas, and load the CSV data.*

3. Connect to the database via pgAdmin4 or VS Code on `localhost:5432`.

## 📈 Roadmap
- [x] Database Schema Design & Normalization
- [x] Containerization with Docker
- [ ] **Next:** Python-based ETL scripts for automated data validation.
- [ ] **Next:** Interactive Dashboard in Tableau (June 2026).
- [ ] **Next:** Final Business Insights Presentation (.pdf coming soon).
