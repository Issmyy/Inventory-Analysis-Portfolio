#Objective 1: Optimal Inventory Levels and Safety Stock 
#Calculate Reorder Point and Safety Stock

With RankedSales AS (
SELECT 
	InventoryId,
    Store,
    Brand,
	SalesQuantity, 
    percent_rank() Over (
		PARTITION BY InventoryId, Store, Brand
        ORDER BY SalesQuantity
	) AS Pr
    FROM Sales2
),
P95Sales AS (
SELECT
	InventoryId, 
    Store, 
    Brand,
    MIN(SalesQuantity) AS P95_daily_sales
FROM RankedSales
WHERE Pr>=0.95
GROUP BY InventoryId, Store, Brand
),
DailySalesMetrics AS (
	SELECT 
		s.InventoryId,
        s.Store,
        s.Brand, 
        AVG(s.SalesQuantity*1.0) AS avg_daily_sales,
        p.p95_daily_sales
	FROM Sales2 s
JOIN P95Sales p
	ON s.InventoryId = p.InventoryId
    AND s.Store = p.Store
    AND s.Brand = p.Brand 
    GROUP BY s.InventoryId, s.Store, s.Brand, p.p95_daily_sales
    ),
SupplierLeadTimes AS (
	SELECT
    p.Brand, 
    AVG(datediff(p.ReceivingDate, ip.PODate)*1.0) AS avg_lead_time_days,
    MAX(datediff(p.ReceivingDate, ip.PODate)) AS max_lead_time_days
	FROM Purchases2 p
    JOIN InvoicePurchases ip ON p.PONumber = ip.PONumber
    GROUP BY p.Brand 
    )
    
    SELECT 
		d.InventoryId,
        d.Store,
        d.Brand,
        round(d.avg_daily_sales, 2) AS avg_daily_sales, 
        round(l.avg_lead_time_days, 1) AS avg_lead_time_days,
        round((d.p95_daily_sales*l.max_lead_time_days) - (d.avg_daily_sales * l.avg_lead_time_days),
        0) AS dynamic_reorder_point
   FROM DailySalesMetrics d
   LEFT JOIN SupplierLeadTimes l ON d.Brand = l.Brand
   ORDER BY dynamic_reorder_point DESC;
        