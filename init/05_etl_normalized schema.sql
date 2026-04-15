-- This SQL script is responsible for populating the staging table `analytics._stg_store_location_boundaries` with data from a CSV file. 
-- The staging table is used as an intermediate step in the ETL process to load data into the normalized schema of the analytics database.
COPY analytics._stg_store_location_boundaries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/store_location_boundaries.csv'
CSV HEADER;

-- After loading the data into the staging table, we convert the WKT (Well-Known Text) representation of geometries into PostGIS geometry objects
--  and populate the `analytics.store_locations` table.
COPY analytics.store_locations
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/store_locations.csv'
CSV HEADER;

-- Next, we populate the `analytics.stores` table by joining the raw coffee shop data with the store locations to associate each store with its location.
COPY analytics.stores
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/stores.csv'
CSV HEADER;

-- We then populate the `analytics.categories` table to store unique product categories.
COPY analytics.categories
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/categories.csv'
CSV HEADER;

-- Then, we populate the `analytics.products` table by joining the raw coffee shop data with the categories to associate each product with its category.
COPY analytics.products
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/products.csv'
CSV HEADER;

-- After populating the products table, we populate the `analytics.products_variants` table by joining the raw coffee shop data with the products to associate each product variant with its corresponding product.
COPY analytics.products_variants
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/products_variants.csv'
CSV HEADER;

-- Finally, we populate the `analytics.transactions` table by joining the raw coffee shop data with the products variants and stores to associate each transaction with its corresponding product variant and store.
COPY analytics.transactions
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/coffee_shop/transactions.csv'
CSV HEADER;
