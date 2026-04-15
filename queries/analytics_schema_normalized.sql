-- PostGis extension for GEOMETRY
DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis;
SELECT PostGIS_Version();

-- Change columns' types from numeric to INT to save the space
ALTER TABLE analytics.coffee_shop_raw
ALTER COLUMN store_id TYPE INT,
ALTER COLUMN product_id TYPE INT;
    

--     Creating Store Locations (Geographic hierarchy)  and Stores tables
-----------------------------------------------------------------------------------------

-- Tables for stores' locations

-- Spatial table (geometry type in EPSG:4326)
DROP TABLE IF EXISTS analytics.store_locations CASCADE;

CREATE TABLE analytics.store_locations (
    location_id INT PRIMARY KEY,
	location_name VARCHAR(100) NOT NULL,
    geom GEOMETRY(Polygon, 4326)
);

SELECT * FROM analytics.store_locations;

-- Staging table for raw WKT imports
DROP TABLE IF EXISTS analytics._stg_store_location_boundaries CASCADE;

CREATE TABLE IF NOT EXISTS analytics._stg_store_location_boundaries (
   	location_id INT,
	location_name VARCHAR(100) NOT NULL,
    wkt TEXT
);

-- Store table
DROP TABLE IF EXISTS analytics.stores CASCADE;

CREATE TABLE analytics.stores (
	store_id INT PRIMARY KEY,
	location_id INT REFERENCES analytics.store_locations(location_id)
);

SELECT * FROM analytics.stores;

--     Populating Store Locations (Geographical hierarchy)  and Stores tables
-----------------------------------------------------------------------------------------

COPY analytics._stg_store_location_boundaries
FROM '/docker-entrypoint-initdb.d/data/analytics_schema/store_location_boundaries.csv'
CSV HEADER;

-- After loading the data into the staging table, we convert the WKT (Well-Known Text) 
-- representation of geometries into PostGIS geometry objects and populate the `analytics.store_locations` table.
INSERT INTO analytics.store_locations (location_id, location_name, geom)
SELECT
  location_id,
  location_name,
  ST_GeomFromText(wkt, 4326)
FROM analytics._stg_store_location_boundaries;

-- Check if geometries are valid
SELECT ST_IsValid(geom) FROM analytics.store_locations;

-- Next, we populate the `analytics.stores` 
-- table by joining the raw coffee shop data with the store locations to associate each store with its location.
INSERT INTO analytics.stores (store_id, location_id)
SELECT
	DISTINCT
	store_id,
  	location_id
FROM analytics.coffee_shop_raw raw
JOIN analytics.store_locations sl ON raw.store_location = sl.location_name;


--     Creating Category table
-----------------------------------------------------------------------------------------
DROP TABLE IF EXISTS analytics.categories CASCADE;

CREATE TABLE analytics.categories (
	category_id SERIAL PRIMARY KEY,
	category VARCHAR(50)
);

-- We then populate the `analytics.categories` table to store unique product categories.
INSERT INTO analytics.categories (category)
SELECT DISTINCT
	category
FROM analytics.coffee_shop_raw raw;

SELECT * FROM analytics.categories;

-- Creating Products table
-------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS analytics.products CASCADE;

CREATE TABLE analytics.products (
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(100),
	category_id INT REFERENCES analytics.categories(category_id)
);


-- Then, we populate the `analytics.products` table by joining the raw coffee shop data with the categories 
-- to associate each product with its category.
INSERT INTO analytics.products (product_name, category_id)
SELECT DISTINCT
	product_name,
	category_id
FROM analytics.coffee_shop_raw raw
LEFT JOIN analytics.categories c ON raw.category = c.category;

SELECT * FROM analytics.products;

-- Creating product Variants table
--------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS analytics.products_variants CASCADE;

CREATE TABLE analytics.products_variants (
	product_variant_id INT PRIMARY KEY,
	product_variant VARCHAR(100),
	product_id INT REFERENCES analytics.products(product_id)
);

-- After populating the products table, we populate the `analytics.products_variants` table by joining the raw coffee shop data with the products 
-- to associate each product variant with its corresponding product.
INSERT INTO analytics.products_variants (product_variant_id, product_variant, product_id)
SELECT DISTINCT
	raw.product_id,
 	product_detail,
	p.product_id
FROM analytics.coffee_shop_raw raw
LEFT JOIN analytics.products p ON raw.product_name = p.product_name
;

SELECT * FROM analytics.products_variants;

-- Creating Transactions table
--------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS analytics.transactions CASCADE;

CREATE TABLE analytics.transactions (
	transaction_id VARCHAR(20) PRIMARY KEY,
	date DATE,
	time TIME,
    quantity INT,
	unit_price NUMERIC(10,2),
	store_id INT REFERENCES analytics.stores(store_id),
	product_variant_id INT REFERENCES analytics.products_variants(product_variant_id)
);

-- Finally, we populate the `analytics.transactions` table by joining the raw coffee shop data with the products variants and stores 
-- to associate each transaction with its corresponding product variant and store.
INSERT INTO analytics.transactions (transaction_id, date, time, quantity, unit_price, store_id, product_variant_id)
SELECT DISTINCT
	raw.transaction_id,
	date,
	time,
	quantity,
	unit_price,
	s.store_id,
	pv.product_variant_id
FROM analytics.coffee_shop_raw raw 
JOIN analytics.stores s             ON raw.store_id = s.store_id
JOIN analytics.products_variants pv ON raw.product_detail = pv.product_variant
;

SELECT * FROM analytics.transactions;

-----------------------------------------------------------------------------------------------------

-- Data Quality Checks
SELECT COUNT (DISTINCT store_id) FROM analytics.stores;                          -- 3
SELECT COUNT (DISTINCT location_id) FROM analytics.store_locations;              -- 3
SELECT COUNT (DISTINCT category_id) FROM analytics.categories;                   -- 9            
SELECT COUNT (DISTINCT product_id) FROM analytics.products;                      -- 29
SELECT COUNT (DISTINCT product_variant_id) FROM analytics.products_variants;     -- 80

-- Creating indexes to optimize query performance on the transactions table
CREATE INDEX IF NOT EXISTS idx_store_id   ON analytics.transactions(store_id);
CREATE INDEX IF NOT EXISTS idx_product_variant_id ON analytics.transactions(product_variant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_date_store
    ON analytics.transactions(date, store_id);

CREATE INDEX IF NOT EXISTS idx_transactions_store_category
    ON analytics.transactions(store_id, product_variant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_date_category
    ON analytics.transactions(date, product_variant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_store_date
    ON analytics.transactions(store_id, date);

CREATE INDEX IF NOT EXISTS idx_transactions_date_product_variant
    ON analytics.transactions(date, product_variant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_store_product_variant
    ON analytics.transactions(store_id, product_variant_id);

CREATE INDEX IF NOT EXISTS idx_transactions_id_product_variant
    ON analytics.transactions(transaction_id, product_variant_id);

