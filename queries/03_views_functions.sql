/*
 * Analytical Views and Performance Functions
 *
 * This script defines an analytics view and two helper SQL functions for the
 * coffee shop analytics schema. The view combines store ranking data with
 * geographical location labels, while the functions classify stores based on
 * revenue performance and sold quantity performance.
 *
 * Definitions included:
 * - store_ranks_by_quantity_revenue: view joining store rankings to store and
 *   location metadata.
 * - store_revenue_performance(): function mapping total revenue into Low/Medium/High.
 * - sold_quantity_per_store(): function mapping total units sold into
 *   Developing/Rising/Elite.
 */

-------------------------------------------------------------------------------
                       -- VIEW: Store Ranks by Quantity and revenue 
-------------------------------------------------------------------------------

CREATE OR REPLACE VIEW store_ranks_by_quantity_revenue AS
SELECT
	location_name,
	total_units_sold,
	total_revenue,
	quantity_rank,
	revenue_rank
FROM analytics.store_rankings sr
JOIN analytics.stores s ON s.store_id = sr.store_id
JOIN analytics.store_locations sl ON sl.location_id = s.location_id
;

-------------------------------------------------------------------------------
                 -- Store Revenue segmentation function
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION store_revenue_performance ( 
	p_total_revenue numeric(10,2) 
	)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT 
		CASE
            WHEN p_total_revenue < 229000.0 THEN 'Low'
            WHEN p_total_revenue BETWEEN 229000.0 AND 235000.0 THEN 'Medium'
            ELSE 'High'
        END;
	;
$$;

-------------------------------------------------------------------------------
                 -- Sold Quantity by Store segmentation function 
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION sold_quantity_per_store ( 
	p_total_units_sold BIGINT 
	)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT 
		CASE
            WHEN p_total_units_sold < 71000 THEN 'Developing'
            WHEN p_total_units_sold BETWEEN 71000 AND 71650 THEN 'Rising'
            ELSE 'Elite'
        END;
	;
$$;