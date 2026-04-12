ALTER TABLE analytics.coffee_shop_raw
ALTER COLUMN store_id TYPE INT;

-- Store table
CREATE TABLE analytics.stores (
	store_id INT PRIMARY KEY,
	location_id INT REFERENCES analytics.store_locations(location_id)
);

-- Temp table for stores' locations
CREATE TABLE analytics.store_locations (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL
);

CREATE TABLE analytics.store_location_boundaries (
    location_id INT PRIMARY KEY REFERENCES analytics.store_locations(location_id),
    geom GEOMETRY(Polygon, 4326)
);

CREATE TABLE IF NOT EXISTS analytics._stg_store_location_boundaries (
    location_id INT,
    wkt TEXT
);

