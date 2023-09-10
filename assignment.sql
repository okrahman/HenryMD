
-- Submitted by Omari-Khalid Rahman

/* Question 1 */

SELECT
    C.CustomerName,
    COALESCE(COUNT(O.OrderID),0) AS OrderCount -- will return 0 for null values of orderid (customers with no orders)
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerName
ORDER BY OrderCount DESC;

/* Question 2 */

UPDATE Customers
SET City = 'New York'
WHERE CustomerID IN (
    SELECT DISTINCT C.CustomerID
    FROM Customers C
    INNER JOIN Orders O ON C.CustomerID = O.CustomerID
    WHERE C.City = 'London'
);


/* Question 3 */

SELECT
    EXTRACT(YEAR FROM OrderDate) AS Year,
    EXTRACT(MONTH FROM OrderDate) AS Month,
    SUM(UnitsSold) AS TotalUnitsSold
FROM Orders
GROUP BY Year, Month
ORDER BY Year ASC, Month ASC;

/* Question 4 */

WITH RankedCus AS (
    SELECT
        C.CustomerName,
        SUM(O.TotalAmount) AS TotalOrderAmount,
        RANK() OVER (ORDER BY SUM(O.TotalAmount) DESC) AS RankNum
    FROM Customers C
    INNER JOIN Orders O ON C.CustomerID = O.CustomerID
    GROUP BY C.CustomerName
)

SELECT
    CustomerName,
    TotalOrderAmount
FROM RankedCus
WHERE RankNum <= 5
ORDER BY 2 DESC;


/* Question 5 */

WITH RankedCus AS (
    SELECT
        C.CustomerName,
        SUM(O.TotalAmount) AS TotalOrderAmount,
        RANK() OVER (ORDER BY SUM(O.TotalAmount) DESC) AS CusRank
    FROM Customers C
    INNER JOIN Orders O ON C.CustomerID = O.CustomerID
    WHERE O.OrderDate >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
    GROUP BY C.CustomerName
)

SELECT
    CustomerName,
    TotalOrderAmount
FROM RankedCus
WHERE CusRank <= 3;

/* Question 6 */


WITH MonthlySales AS (
    SELECT
        P.ProductID,
        P.ProductName,
        EXTRACT(YEAR_MONTH FROM O.OrderDate) AS MonthYear,
        SUM(O.TotalAmount) AS MonthlySales
    FROM Products P
    LEFT JOIN Orders O ON P.ProductID = O.ProductID
    GROUP BY P.ProductID, P.ProductName, MonthYear
),
SalesWithPreviousMonth AS (
    SELECT
        ProductID,
        ProductName,
        MonthYear,
        MonthlySales,
        LAG(MonthlySales) OVER(PARTITION BY ProductID ORDER BY MonthYear) AS PreviousMonthSales
    FROM MonthlySales
)

SELECT
    S.ProductID,
    S.ProductName,
    S.MonthYear,
    S.MonthlySales,
    ROUND(
        CASE
            WHEN S.PreviousMonthSales IS NULL THEN 0
            ELSE ((S.MonthlySales - S.PreviousMonthSales) / S.PreviousMonthSales) * 100
        END,
        2
    ) AS SalesGrowthRate
FROM SalesWithPreviousMonth S
ORDER BY S.ProductID ASC, S.MonthYear ASC;
