/*
 * Performance Optimization Queries for Coffee Shop Analytics Database
 *
 * This file contains sample analytics queries instrumented with EXPLAIN ANALYZE
 * and index creation statements for the coffee shop analytics schema.
 *
 * It supports performance testing and tuning for queries such as:
 * - location-level revenue by date
 * - geospatial store location summaries
 * - store/product variant sales ranking
 * - transaction basket itemization
 *
 * It also creates indexes to improve query execution on:
 * - analytics.store_location_summary(location_id)
 * - analytics.store_location_summary(geom) using GIST
 * - analytics.transactions(store_id, product_variant_id)
 * - analytics.transactions(transaction_id, product_variant_id)
 *
 * These optimizations help reduce scan costs, speed joins, and make spatial and
 * multi-dimensional analytics more efficient.
 */


EXPLAIN ANALYZE
SELECT
	sl.location_name,
	t.date,
	SUM(t.quantity * t.unit_price) AS total_revenue
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
WHERE t.date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY sl.location_name, t.date
ORDER BY sl.location_name
;

CREATE INDEX IF NOT EXISTS idx_store_location_summary_location_id
    ON analytics.store_location_summary(location_id);

--==========================================================================================

EXPLAIN ANALYZE
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

-- spatial index for geometry
CREATE INDEX IF NOT EXISTS idx_store_location_summary_geom
    ON analytics.store_location_summary
    USING GIST (geom);

--==========================================================================================

EXPLAIN ANALYZE
SELECT 
	t.store_id, 
	pv.product_variant, 
	SUM(t.quantity) AS units_sold
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY t.store_id, pv.product_variant
ORDER BY units_sold DESC;

CREATE INDEX IF NOT EXISTS idx_transactions_store_category
    ON analytics.transactions(store_id, product_variant_id);

--==========================================================================================

EXPLAIN ANALYZE
SELECT DISTINCT
	transaction_id,
	product_variant
FROM analytics.transactions t
JOIN analytics.products_variants pv ON t.product_variant_id = pv.product_variant_id
GROUP BY transaction_id, product_variant

CREATE INDEX IF NOT EXISTS idx_transactions_id_product_variant
    ON analytics.transactions(transaction_id, product_variant_id);
