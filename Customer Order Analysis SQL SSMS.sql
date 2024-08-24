-- Task: Customer Order Analysis

WITH 
    -- Create a CTE to Aggregate Sales by Year and Product Category
    Sales AS (
        SELECT 
            salesheader.SalesOrderID,
            YEAR(salesheader.OrderDate) AS OrderYear,
            salesdetail.ProductID,
            productcategory.Name AS ProductCategory,
            salesdetail.OrderQty,
            salesdetail.LineTotal,
            salesheader.CustomerID
        FROM Sales.SalesOrderHeader AS salesheader
        LEFT JOIN Sales.SalesOrderDetail AS salesdetail
            ON salesheader.SalesOrderID = salesdetail.SalesOrderID
        LEFT JOIN Production.Product AS product
            ON product.ProductID = salesdetail.ProductID
        LEFT JOIN Production.ProductSubcategory AS productsubcategory
            ON product.ProductSubcategoryID = productsubcategory.ProductSubcategoryID
        LEFT JOIN Production.ProductCategory AS productcategory
            ON productsubcategory.ProductCategoryID = productcategory.ProductCategoryID
    ),
    
    -- Create a View for Customer Demographics:
    Customer AS (
        SELECT 
            customer.CustomerID,
            COALESCE(person.FirstName + ' ' + person.LastName, store.Name) AS CustomerName,
            emailaddress.EmailAddress,
            phone.PhoneNumber AS Phone,
            country.Name AS CountryRegion,
            address.AddressLine1 + ISNULL(' ' + address.AddressLine2, '') AS FullAddress
        FROM Sales.Customer AS customer
        LEFT JOIN Person.Person AS person
            ON customer.PersonID = person.BusinessEntityID
        LEFT JOIN Sales.Store AS store
            ON customer.StoreID = store.BusinessEntityID
        LEFT JOIN Person.BusinessEntityAddress AS bea
            ON person.BusinessEntityID = bea.BusinessEntityID
        LEFT JOIN Person.EmailAddress AS emailaddress
            ON emailaddress.BusinessEntityID = person.BusinessEntityID
        LEFT JOIN Person.PersonPhone AS phone
            ON phone.BusinessEntityID = person.BusinessEntityID
        LEFT JOIN Person.Address AS address
            ON bea.AddressID = address.AddressID
        LEFT JOIN Person.StateProvince AS stateprovince
            ON address.StateProvinceID = stateprovince.StateProvinceID
        LEFT JOIN Person.CountryRegion AS country
            ON stateprovince.CountryRegionCode = country.CountryRegionCode
    )

-- Final Select: Aggregate Sales Data Per Year Per Customer
SELECT 
    s.OrderYear,
    c.CustomerName,
    CAST(SUM(s.LineTotal) AS DECIMAL(10, 2)) AS TotalSales,
    CAST(CASE WHEN SUM(s.OrderQty) = 0 THEN 0 ELSE SUM(s.LineTotal) / SUM(s.OrderQty) END AS DECIMAL(10, 2)) AS AverageOrderValue,
    
    -- Running Total Sales by Customer within each Year
    CAST(SUM(SUM(s.LineTotal)) OVER (PARTITION BY s.OrderYear, c.CustomerName ORDER BY s.OrderYear, c.CustomerName ROWS UNBOUNDED PRECEDING) AS DECIMAL(10, 2)) AS RunningTotalSales,

    -- Rank Customers by Total Sales within each Year
    RANK() OVER (PARTITION BY s.OrderYear ORDER BY SUM(s.LineTotal) DESC) AS SalesRank
FROM Sales AS s
LEFT JOIN Customer AS c
    ON s.CustomerID = c.CustomerID
GROUP BY s.OrderYear, c.CustomerName
ORDER BY s.OrderYear DESC, TotalSales DESC

/*-- Final Select: Top Product Category Per Year
SELECT 
    s.OrderYear,
    s.ProductCategory,
    CAST(SUM(s.LineTotal) AS DECIMAL(10, 2)) AS TotalSales,
    CAST(CASE WHEN SUM(s.OrderQty) = 0 THEN 0 ELSE SUM(s.LineTotal) / SUM(s.OrderQty) END AS DECIMAL(10, 2)) AS AverageOrderValue,
	RANK() OVER (PARTITION BY s.OrderYear ORDER BY SUM(s.LineTotal) DESC) AS SalesRank
FROM Sales AS s
GROUP BY s.OrderYear, s.ProductCategory
ORDER BY s.OrderYear DESC, TotalSales DESC;   */
