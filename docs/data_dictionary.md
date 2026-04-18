# 📘 Data Dictionary – Coffee Shop Analytics

## Table: `analytics.store_locations`
| Column        | Data Type                | Description                                | Constraints |
|---------------|--------------------------|--------------------------------------------|-------------|
| location_id   | INT                      | Unique identifier for each store location  | Primary Key |
| location_name | VARCHAR(100)             | Name of the location/district              | NOT NULL    |
| geom          | GEOMETRY(Polygon, 4326)  | Spatial polygon representing district area | Spatial index (GIST) |

---

## Table: `analytics._stg_store_location_boundaries`
| Column        | Data Type    | Description                                | Constraints |
|---------------|--------------|--------------------------------------------|-------------|
| location_id   | INT          | Temporary ID for staging imports           | None        |
| location_name | VARCHAR(100) | Location name from raw CSV                 | NOT NULL    |
| wkt           | TEXT         | Well-Known Text representation of geometry | None        |

---

## Table: `analytics.stores`
| Column      | Data Type | Description                          | Constraints |
|-------------|-----------|--------------------------------------|-------------|
| store_id    | INT       | Unique identifier for each store     | Primary Key |
| location_id | INT       | Foreign key to `store_locations`     | FK → store_locations(location_id) |

---

## Table: `analytics.categories`
| Column      | Data Type    | Description                        | Constraints |
|-------------|--------------|------------------------------------|-------------|
| category_id | SERIAL       | Unique identifier for category     | Primary Key |
| category    | VARCHAR(50)  | Product category name              | None        |

---

## Table: `analytics.products`
| Column      | Data Type    | Description                        | Constraints |
|-------------|--------------|------------------------------------|-------------|
| product_id  | SERIAL       | Unique identifier for product      | Primary Key |
| product_name| VARCHAR(100) | Name of the product                | None        |
| category_id | INT          | Foreign key to `categories`        | FK → categories(category_id) |

---

## Table: `analytics.products_variants`
| Column            | Data Type    | Description                        | Constraints |
|-------------------|--------------|------------------------------------|-------------|
| product_variant_id| INT          | Unique identifier for product variant | Primary Key |
| product_variant   | VARCHAR(100) | Variant name (e.g., size/flavor)   | None        |
| product_id        | INT          | Foreign key to `products`          | FK → products(product_id) |

---

## Table: `analytics.transactions`
| Column            | Data Type     | Description                                | Constraints |
|-------------------|---------------|--------------------------------------------|-------------|
| transaction_id    | VARCHAR(20)   | Unique transaction identifier              | Primary Key |
| date              | DATE          | Date of transaction                        | None        |
| time              | TIME          | Time of transaction                        | None        |
| quantity          | INT           | Number of units sold                       | None        |
| unit_price        | NUMERIC(10,2) | Price per unit                             | None        |
| store_id          | INT           | Foreign key to `stores`                    | FK → stores(store_id) |
| product_variant_id| INT           | Foreign key to `products_variants`         | FK → products_variants(product_variant_id) |

**Indexes:**  
- `idx_store_id`  
- `idx_product_variant_id`  
- Composite indexes: `(date, store_id)`, `(store_id, product_variant_id)`, `(date, product_variant_id)`, `(transaction_id, store_id)`, etc.

---

## Table: `analytics.sales_by_store`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| store_id       | INT           | Store identifier                   | FK → stores(store_id) |
| location_name  | VARCHAR(100)  | Store location name                | None        |
| total_sales    | NUMERIC       | Total revenue for store            | None        |
| num_transactions | INT         | Number of transactions             | None        |
| total_units_sold | INT         | Total units sold                   | None        |

---

## Table: `analytics.sales_by_category`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| category_id    | INT           | Category identifier                | FK → categories(category_id) |
| category       | VARCHAR(50)   | Category name                      | None        |
| total_sales    | NUMERIC       | Total revenue by category          | None        |
| total_units_sold | INT         | Total units sold by category       | None        |

---

## Table: `analytics.daily_sales`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| date           | DATE          | Transaction date                   | None        |
| total_sales    | NUMERIC       | Total revenue for the day          | None        |
| total_units_sold | INT         | Units sold per day                 | None        |
| num_transactions | INT         | Number of transactions per day     | None        |

---

## Table: `analytics.top_products`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| product_id     | INT           | Product identifier                 | FK → products(product_id) |
| product_name   | VARCHAR(100)  | Product name                       | None        |
| total_sales    | NUMERIC       | Total revenue by product           | None        |
| total_units_sold | INT         | Total units sold by product        | None        |

---

## Table: `analytics.store_location_summary`
| Column         | Data Type                | Description                        | Constraints |
|----------------|--------------------------|------------------------------------|-------------|
| location_id    | INT                      | Location identifier                | FK → store_locations(location_id) |
| location_name  | VARCHAR(100)             | Location name                      | None        |
| geom           | GEOMETRY(Polygon, 4326)  | Spatial polygon of location        | Spatial index (GIST) |
| total_sales    | NUMERIC                  | Total revenue in location          | None        |
| total_units_sold | INT                    | Units sold in location             | None        |

---

## Table: `analytics.hourly_sales`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| hour           | INT           | Hour of day (0–23)                 | None        |
| total_sales    | NUMERIC       | Total revenue in that hour         | None        |

---

## Table: `analytics.price_trends`
| Column            | Data Type     | Description                        | Constraints |
|-------------------|---------------|------------------------------------|-------------|
| product_variant_id| INT           | Product variant identifier         | FK → products_variants(product_variant_id) |
| date              | DATE          | Transaction date                   | None        |
| avg_price         | NUMERIC(10,2) | Average unit price per day         | None        |

---

## Table: `analytics.store_rankings`
| Column         | Data Type     | Description                        | Constraints |
|----------------|---------------|------------------------------------|-------------|
| store_id       | INT           | Store identifier                   | FK → stores(store_id) |
| total_units_sold | INT         | Total units sold                   | None        |
| total_revenue  | NUMERIC       | Total revenue                      | None        |
| quantity_rank  | INT           | Rank by units sold                 | Window function |
| revenue_rank