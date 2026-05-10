-- TODO Indexing & EXPLAIN ANALYZE

EXPLAIN ANALYZE
SELECT 
	sl.location_name, 
	t.date, 
	SUM(t.quantity * t.unit_price) AS total_revenue
FROM analytics.transactions t
JOIN analytics.stores s ON t.store_id = s.store_id
JOIN analytics.store_locations sl ON s.location_id = sl.location_id
-- WHERE t.date BETWEEN '2026-01-01' AND '2026-01-31'
WHERE t.date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY sl.location_name, t.date
ORDER BY sl.location_name
;
