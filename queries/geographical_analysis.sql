-- Area of each Store Location
SELECT 
	location_name, 
	ST_Area(geom::geography)/1000000 AS area_km2
FROM analytics.store_location_summary;


-- Sales Density
SELECT
	*
FROM analytics.sales_density;