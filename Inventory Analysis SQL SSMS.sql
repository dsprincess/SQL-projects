WITH DailyInventory AS (
-- Calculate daily inventory levels by adjusting the balance with units added and removed.
    SELECT 
        i.ProductKey,
        d.FullDateAlternateKey AS InventoryDate,
        (i.UnitsBalance + ISNULL(i.UnitsIn, 0) - ISNULL(i.UnitsOut, 0)) AS DailyInventory
    FROM [dbo].[FactProductInventory] i
    JOIN [dbo].[DimDate] d ON i.DateKey = d.DateKey
),
COGSData AS (
-- Compute Cost of Goods Sold (COGS) for each product by summing up the standard cost of sold units within the specified date range.
	SELECT 
    s.ProductKey,
    SUM(s.OrderQuantity * s.ProductStandardCost) AS COGS
	FROM [dbo].[FactInternetSales] s
	JOIN [dbo].[DimDate] d ON s.OrderDateKey = d.DateKey
	WHERE d.FullDateAlternateKey BETWEEN '2012-01-01' AND '2012-12-31'
    GROUP BY s.ProductKey),
AverageInventory AS (
-- Calculate the average inventory for each product over the specified date range.
    SELECT 
        ProductKey,
        AVG(DailyInventory) AS AvgInventory
    FROM DailyInventory
    WHERE InventoryDate BETWEEN '2012-01-01' AND '2012-12-31'
    GROUP BY ProductKey),
ProductDetails AS (
-- Retrieve detailed product information including name, category, and subcategory.
	SELECT
		p.ProductKey,
		p.EnglishProductName,
		pc.EnglishProductCategoryName,
		psc.EnglishProductSubcategoryName
	FROM [AdventureWorksDW2022].[dbo].[DimProduct] p
	LEFT JOIN [dbo].[DimProductSubCategory] AS psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
	LEFT JOIN [dbo].[DimProductCategory] AS pc ON pc.ProductCategoryKey = psc.ProductCategoryKey)

--Combine COGSData, AverageInventory, and ProductDetails to calculate and display the Inventory Turnover Ratio for each product.	
SELECT 
    c.ProductKey,
	pd.EnglishProductName,
	pd.EnglishProductCategoryName, 
    c.COGS,
    a.AvgInventory,
    (c.COGS / NULLIF(a.AvgInventory, 0)) AS InventoryTurnoverRatio
FROM COGSData c
JOIN AverageInventory a ON c.ProductKey = a.ProductKey
LEFT JOIN ProductDetails pd ON c.ProductKey = pd.ProductKey
ORDER BY InventoryTurnoverRatio DESC



--Overstocks
WITH DailyInventory AS (
-- Calculate daily inventory levels by adjusting the balance with units added and removed.
    SELECT 
        i.ProductKey,
        d.FullDateAlternateKey AS InventoryDate,
        (i.UnitsBalance + ISNULL(i.UnitsIn, 0) - ISNULL(i.UnitsOut, 0)) AS DailyInventory
    FROM [dbo].[FactProductInventory] i
    JOIN [dbo].[DimDate] d ON i.DateKey = d.DateKey
),
COGSData AS (
-- Compute Cost of Goods Sold (COGS) for each product by summing up the standard cost of sold units within the specified date range.
	SELECT 
    s.ProductKey,
    SUM(s.OrderQuantity * s.ProductStandardCost) AS COGS,
	SUM(s.OrderQuantity) AS TotalUnitsSold
	FROM [dbo].[FactInternetSales] s
	JOIN [dbo].[DimDate] d ON s.OrderDateKey = d.DateKey
	WHERE d.FullDateAlternateKey BETWEEN '2012-01-01' AND '2012-12-31'
    GROUP BY s.ProductKey),
AverageInventory AS (
-- Calculate the average inventory for each product over the specified date range.
    SELECT 
        ProductKey,
        AVG(DailyInventory) AS AvgInventory
    FROM DailyInventory
    WHERE InventoryDate BETWEEN '2012-01-01' AND '2012-12-31'
    GROUP BY ProductKey),
ProductDetails AS (
-- Retrieve detailed product information including name, category, and subcategory.
	SELECT
		p.ProductKey,
		p.EnglishProductName,
		pc.EnglishProductCategoryName,
		psc.EnglishProductSubcategoryName
	FROM [AdventureWorksDW2022].[dbo].[DimProduct] p
	LEFT JOIN [dbo].[DimProductSubCategory] AS psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
	LEFT JOIN [dbo].[DimProductCategory] AS pc ON pc.ProductCategoryKey = psc.ProductCategoryKey)

--Combine COGSData, AverageInventory, and ProductDetails to calculate and display stock status.	
SELECT 
    c.ProductKey,
	pd.EnglishProductName,
	pd.EnglishProductCategoryName, 
    c.COGS,
    a.AvgInventory,
	c.TotalUnitsSold,
    CASE 
        WHEN a.AvgInventory > (c.TotalUnitsSold * 3) THEN 'Overstocked' -- Define threshold, e.g., inventory > 3x sales
        ELSE 'Normal'
    END AS StockStatus
FROM COGSData c
JOIN AverageInventory a ON c.ProductKey = a.ProductKey
LEFT JOIN ProductDetails pd ON c.ProductKey = pd.ProductKey
WHERE (c.COGS / NULLIF(a.AvgInventory, 0)) < 1 -- Filter for low inventory turnover
   OR a.AvgInventory > (c.TotalUnitsSold * 3) -- Filter for high inventory relative to sales
ORDER BY StockStatus DESC, a.AvgInventory DESC;


--Stockouts
WITH DailyInventory AS (
-- Calculate daily inventory levels by adjusting the balance with units added and removed.
    SELECT 
        i.ProductKey,
        d.FullDateAlternateKey AS InventoryDate,
        (i.UnitsBalance + ISNULL(i.UnitsIn, 0) - ISNULL(i.UnitsOut, 0)) AS DailyInventory
    FROM [dbo].[FactProductInventory] i
    JOIN [dbo].[DimDate] d ON i.DateKey = d.DateKey
),
ProductDetails AS (
-- Retrieve detailed product information including name, category, and subcategory.
	SELECT
		p.ProductKey,
		p.EnglishProductName,
		pc.EnglishProductCategoryName,
		psc.EnglishProductSubcategoryName
	FROM [AdventureWorksDW2022].[dbo].[DimProduct] p
	LEFT JOIN [dbo].[DimProductSubCategory] AS psc ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
	LEFT JOIN [dbo].[DimProductCategory] AS pc ON pc.ProductCategoryKey = psc.ProductCategoryKey)

SELECT 
    i.ProductKey,
	pd.EnglishProductName,
	pd.EnglishProductCategoryName, 
    COUNT(*) AS StockoutDays
FROM DailyInventory i
JOIN ProductDetails pd ON i.ProductKey = pd.ProductKey
WHERE i.DailyInventory = 0
GROUP BY i.ProductKey, pd.EnglishProductName, pd.EnglishProductCategoryName 
ORDER BY 4 DESC;