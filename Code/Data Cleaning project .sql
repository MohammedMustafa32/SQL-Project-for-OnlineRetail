select * from Online_Retail

-- المنتج ممكن يتكرر في الفاتورة الواحده اكتر من مره
select InvoiceNo, StockCode, Description, count(*) c
from Online_Retail
group by InvoiceNo, StockCode, Description
order by c desc, Description

select *
from Online_Retail
where InvoiceNo = '555524' and StockCode = '22698'


-- Reference date = 2011-12-10

-- No. of rows = 541,909 (all data before cleaning)

-- Delete (UnitPrice) that = 0 -> 2,515 rows
select * from Online_Retail
where UnitPrice = 0 or UnitPrice is null
--
delete from Online_Retail 
where UnitPrice = 0

-- No. of rows when customerID is NULL = 135,080 (25% from data)
select * from Online_Retail
where CustomerID is null
-- 308,950
select * from Online_Retail
where InvoiceDate is null
-- 74,903
select * from Online_Retail
where InvoiceDate is null and CustomerID is null



------------ Column StockCode
select * from Online_Retail order by StockCode desc

--StockCode (D) -> 77
select * from Online_Retail
where StockCode = 'D'
-- select * from Online_Retail where InvoiceNo = 'C577227'
-- select * from Online_Retail where CustomerID = '14527' order by InvoiceDate desc --> give discount in another invoiceNo

--StockCode (POST) -> 1,256
select * from Online_Retail
where StockCode = 'POST'
-- select * from Online_Retail where InvoiceNo = 'C539063'
-- select * from Online_Retail where CustomerID = '12583' order by InvoiceNo


--StockCode (S) -> 63 (will delete)
select * from Online_Retail where StockCode = 'S' order by StockCode
-- select * from Online_Retail where InvoiceNo = 'C537581'
delete from Online_Retail where StockCode = 'S'


------------ Column Quantity

--Quantity -> 9,227 (will delete)
select * from Online_Retail where Quantity < 0
-- select * from Online_Retail where InvoiceNo = 'C536383'
-- select * from Online_Retail where CustomerID = '15311'  order by InvoiceDate
-- select * from Online_Retail where CustomerID = '15311' and StockCode='20829' order by  InvoiceDate
--delete from Online_Retail where Quantity < 0


 -- 212
 select StockCode, COUNT(distinct Description) s
 from Online_Retail
 group by StockCode
 order by s desc

 select distinct StockCode, Description 
 from Online_Retail 
 where StockCode='22135'
 ----------------
 select Description, COUNT(distinct StockCode) s
 from Online_Retail
 group by Description
 order by s desc

 select distinct StockCode, Description 
 from Online_Retail 
 where Description='COLUMBIAN CANDLE ROUND'

 -----------
  select InvoiceNo , COUNT(distinct InvoiceDate) s
 from Online_Retail
 group by InvoiceNo
 order by s desc

  select distinct InvoiceNo,StockCode, InvoiceDate 
 from Online_Retail
 where InvoiceNo='543777'

 ---------
   select CustomerID , COUNT(distinct Country) s
 from Online_Retail
 group by CustomerID
 order by s desc

  select * 
 from Online_Retail
 where CustomerID='12429'



 -----------------------------------
 -- InvoiceDate -> replace NULL value of current row with the previous row
SELECT 
    ROW_NUMBER() OVER (ORDER BY InvoiceNo, StockCode) AS RowNum, *
INTO Temp_OnlineRetail
FROM Online_Retail;
-- ==
DECLARE @i INT = 2;
DECLARE @max INT;
SELECT @max =   MAX(RowNum) FROM Temp_OnlineRetail;

WHILE @i <= @max
BEGIN
    UPDATE t
    SET InvoiceDate = (
        SELECT TOP 1 format(InvoiceDate, 'yyyy-MM-dd') 
        FROM Temp_OnlineRetail 
        WHERE RowNum = @i - 1
    )
    FROM Temp_OnlineRetail t
    WHERE RowNum = @i AND InvoiceDate IS NULL;

    SET @i = @i + 1;
END

select *
from Temp_OnlineRetail
order by RowNum








SELECT 
	*,
    ROW_NUMBER() OVER (ORDER BY InvoiceNo ASC) AS RowNum
FROM Online_Retail;


WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY InvoiceNo ASC) AS RowNum
    FROM Online_Retail
)
UPDATE t
SET t.InvoiceDate = (
    SELECT TOP 1 InvoiceDate 
    FROM CTE c
    WHERE c.RowNum = t.RowNum - 1
	order by c.InvoiceDate desc
)
FROM Temp_OnlineRetail t
WHERE t.InvoiceDate IS NULL;
