-- What is the general statistical summary of coffee shop condition?
SELECT
	MAX(date) AS max_date,                                                    
	MIN(date) AS min_date,                                                    
	MAX(date) - MIN(date) AS date_interval,                                   
	SUM(quantity) AS total_quantity,
	ROUND(AVG(quantity), 2) AS avg_quantity_per_trans,
	MAX(quantity) AS max_quantity,
	MIN(quantity) AS min_quantity,
	MAX(quantity) - MIN(quantity) AS quantity_range,
	SUM(quantity*unit_price) AS total_revenue,
	ROUND(AVG(quantity*unit_price), 2) AS avg_revenue_per_trans,
	MAX(quantity*unit_price) AS max_revenue,
	MIN(quantity*unit_price) AS min_revenue,
	MAX(quantity*unit_price) - MIN(quantity*unit_price) AS transaction_revenue_range
FROM analytics.transactions
;


-- The data is about the sales for 180 days 
-- The quantity of products is likely centered around the 1-3 range 
-- The revenue is likely centered around the 3.99 -5.5 range 

-- Sales by Store
DROP TABLE IF EXISTS analytics.sales_by_store CASCADE;

CREATE TABLE analytics.sales_by_store AS
SELECT
    s.store_id,
    sl.location_name,
    SUM(t.quantity * t.unit_price) AS total_sales,
    COUNT(DISTINCT t.transaction_id) AS num_transactions,
    SUM(t.quantity) AS total_units_sold
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
GROUP BY s.store_id, sl.location_name;

CREATE INDEX IF NOT EXISTS idx_sales_by_store_store_id
    ON analytics.sales_by_store(store_id);


--  Sales by Category
DROP TABLE IF EXISTS analytics.sales_by_category CASCADE;

CREATE TABLE analytics.sales_by_category AS
SELECT
    c.category_id,
    c.category,
    SUM(t.quantity * t.unit_price) AS total_sales,
    SUM(t.quantity) AS total_units_sold
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
JOIN analytics.products p ON pv.product_id = p.product_id
JOIN analytics.categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category;

CREATE INDEX IF NOT EXISTS idx_sales_by_category_category_id
    ON analytics.sales_by_category(category_id);


-- Dayly Sales Trends
DROP TABLE IF EXISTS analytics.daily_sales CASCADE;

CREATE TABLE analytics.daily_sales AS
SELECT
    t.date,
    SUM(t.quantity * t.unit_price) AS total_sales,
    SUM(t.quantity) AS total_units_sold,
    COUNT(DISTINCT t.transaction_id) AS num_transactions
FROM analytics.transactions t
GROUP BY t.date
ORDER BY t.date;

CREATE INDEX IF NOT EXISTS idx_daily_sales_date
    ON analytics.daily_sales(date);


-- Top Product
DROP TABLE IF EXISTS analytics.top_products CASCADE;

CREATE TABLE analytics.top_products AS
SELECT
    p.product_id,
    p.product_name,
    SUM(t.quantity * t.unit_price) AS total_sales,
    SUM(t.quantity) AS total_units_sold
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
JOIN analytics.products p ON pv.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;

CREATE INDEX IF NOT EXISTS idx_top_products_product_id
    ON analytics.top_products(product_id);


-- Store Location Geospatial Summary
DROP TABLE IF EXISTS analytics.store_location_summary CASCADE;

CREATE TABLE analytics.store_location_summary AS
SELECT
    sl.location_id,
    sl.location_name,
    sl.geom,
    SUM(t.quantity * t.unit_price) AS total_sales,
    SUM(t.quantity) AS total_units_sold
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
GROUP BY sl.location_id, sl.location_name, sl.geom;

CREATE INDEX IF NOT EXISTS idx_store_location_summary_location_id
    ON analytics.store_location_summary(location_id);

-- spatial index for geometry
CREATE INDEX IF NOT EXISTS idx_store_location_summary_geom
    ON analytics.store_location_summary
    USING GIST (geom);

 -- Hours Analysis
DROP TABLE IF EXISTS analytics.hourly_sales CASCADE;
 
CREATE TABLE analytics.hourly_sales AS
SELECT 
	EXTRACT(HOUR FROM time) AS hour, 
	SUM(quantity*unit_price) AS total_sales
FROM analytics.transactions
GROUP BY hour
;

-- Price Sensitivity / Average Unit Price Trends
DROP TABLE IF EXISTS analytics.price_trends CASCADE;

CREATE TABLE analytics.price_trends AS
SELECT 
	product_variant_id, 
	date, 
	ROUND(AVG(unit_price), 2) AS avg_price
FROM analytics.transactions
GROUP BY product_variant_id, date;


-- Store Performance Ranking
DROP TABLE IF EXISTS analytics.store_rankings CASCADE;

CREATE TABLE analytics.store_rankings AS
SELECT 
	store_id, 
	SUM(quantity) AS total_units_sold,
	SUM(quantity*unit_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(quantity) DESC) AS quantity_rank,
    RANK() OVER (ORDER BY SUM(quantity*unit_price) DESC) AS revenue_rank
FROM analytics.transactions
GROUP BY store_id;

-- Sales density per km2
DROP TABLE IF EXISTS analytics.sales_density CASCADE;

CREATE TABLE analytics.sales_density AS
SELECT 
	location_id, 
	location_name,
    SUM(total_sales)/ST_Area(geom::geography) AS sales_per_m2
FROM analytics.store_location_summary
GROUP BY location_id, location_name, geom;



