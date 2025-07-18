use chinook;
-- SALES BY COUNTRY
SELECT
  i.BillingCountry,
  COUNT(i.InvoiceId) AS InvoiceCount,
  ROUND(SUM(i.Total), 2) AS TotalRevenue
FROM Invoice i
GROUP BY i.BillingCountry
ORDER BY TotalRevenue DESC;

-- TOP GENRES SOLD IN USA
SELECT
  g.Name AS Genre,
  SUM(il.Quantity) AS TracksSold,
  ROUND(100.0 * SUM(il.Quantity) /
    (SELECT SUM(il2.Quantity)
     FROM Invoice i2
     JOIN InvoiceLine il2 ON i2.InvoiceId = il2.InvoiceId
     WHERE i2.BillingCountry = 'USA'), 2) AS pct_of_usa_sales
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE i.BillingCountry = 'USA'
GROUP BY g.Name
ORDER BY TracksSold DESC;


-- REVENUE PER EMPLOYEE
SELECT
  e.FirstName , e.LastName ,
  COUNT(DISTINCT c.CustomerId) AS NumCustomers,
  ROUND(SUM(i.Total), 2) AS TotalRevenue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY TotalRevenue DESC;



-- ALBUM V/S INDIVIDUAL TRACK PURCHASE
WITH invoice_types AS (
  SELECT
    il.InvoiceId,
    CASE WHEN COUNT(DISTINCT t.AlbumId) = 1
        AND COUNT(il.TrackId) = (SELECT COUNT(*) FROM Track WHERE AlbumId = MIN(t.AlbumId))
      THEN 'Whole Album'
      ELSE 'Individual/Multiple'
    END AS PurchaseType
  FROM InvoiceLine il
  JOIN Track t ON il.TrackId = t.TrackId
  GROUP BY il.InvoiceId
)
SELECT
  PurchaseType,
  COUNT(*) AS InvoiceCount,
  ROUND(100.0 * COUNT(*) /
    (SELECT COUNT(*) FROM invoice_types), 2) AS pct
FROM invoice_types
GROUP BY PurchaseType;



