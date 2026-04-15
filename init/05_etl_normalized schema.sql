-- This SQL script is responsible for populating the staging table `analytics._stg_store_location_boundaries` with data from a CSV file. 
-- The staging table is used as an intermediate step in the ETL process to load data into the normalized schema of the analytics database.
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

-- Next, we populate the `analytics.stores` 
-- table by joining the raw coffee shop data with the store locations to associate each store with its location.
INSERT INTO analytics.stores (store_id, location_id)
SELECT
	DISTINCT
	store_id,
  	location_id
FROM analytics.coffee_shop_raw raw
JOIN analytics.store_locations sl ON raw.store_location = sl.location_name;

-- We then populate the `analytics.categories` table to store unique product categories.
INSERT INTO analytics.categories (category)
SELECT DISTINCT
	category
FROM analytics.coffee_shop_raw raw;

-- Then, we populate the `analytics.products` table by joining the raw coffee shop data with the categories 
-- to associate each product with its category.
INSERT INTO analytics.products (product_name, category_id)
SELECT DISTINCT
	product_name,
	category_id
FROM analytics.coffee_shop_raw raw
LEFT JOIN analytics.categories c ON raw.category = c.category;

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
