-- Working Capital Optimization (EOQ & Inventory Turnover)
-- Memakai BegInv, EndInv, Sales, dan PurchasePricesDec untuk rasio keuangan

WITH AverageInventory AS (
	SELECT 
    b.Brand,
    b.`Description`,
    AVG ((b.onHand * b.Price)+(e.onHand * e.Price)) / 2.0 AS avg_inventory_value
    FROM beginv2 b
    JOIN endinv2 e ON b.InventoryId = e.InventoryId
    GROUP BY b.Brand, b.`Description`
    ),
COGSAndCosts AS (
	SELECT 
		s.Brand,
        SUM(s.SalesQuantity * pp.purchaseprice) AS annual_cogs,
        MAX(PP.Volume) AS unit_volume
	FROM Sales2 s 
    JOIN Purchaseprices pp ON s.Brand = pp.Brand
    GROUP BY s.Brand
    )
    SELECT
		a.Brand, 
        a.`Description`,
        c.annual_cogs,
        a.avg_inventory_value, 
	-- Inventory Turnover Ratio (ITS)
	ROUND(c.annual_cogs / NULLIF(a.avg_inventory_value, 0), 2) AS inventory_turnover_ratio,
    -- Days Sales of Inventory (DSI)
    ROUND(365.0 / NULLIF(c.annual_cogs / NULLIF(a.avg_inventory_value, 0), 0), 0) AS days_sales_inventory,
    -- Economic Order Quantity (EOQ) (Asumsi fixed ordering cost = $50 & 20% holding cost)
    ROUND(
        SQRT(
            (2 * (c.annual_cogs / NULLIF(a.avg_inventory_value, 0)) * 50) / 
            NULLIF(a.avg_inventory_value * 0.20, 0)
        ), 
    0) AS optimal_eoq_units
FROM AverageInventory a
JOIN COGSAndCosts c ON a.Brand = c.Brand
ORDER BY days_sales_inventory DESC;
