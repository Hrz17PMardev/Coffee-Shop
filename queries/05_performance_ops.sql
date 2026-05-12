/*
 * Performance Optimization Queries for Coffee Shop Analytics Database
 *
 * This file contains SQL queries and index creation statements designed to optimize
 * the performance of analytical queries on the coffee shop sales data. The database
 * includes normalized tables for transactions, stores, and store locations, with
 * spatial data for location boundaries.
 *
 * Key optimizations include:
 * - EXPLAIN ANALYZE statements to analyze query execution plans and performance.
 * - Index creation on frequently queried columns to reduce lookup times.
 * - Spatial indexing for geometry-based queries using PostGIS GIST indexes.
 *
 * These optimizations are crucial for handling large volumes of sales data efficiently,
 * enabling fast aggregation and reporting on revenue, sales, and location-based analytics.
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