-------------------------------------------------------
-------------------- Data Cleaning --------------------
-------------------------------------------------------
-- No. of all data = 541,909 (all data before cleaning)
select * from Online_Retail
---

-- Delete (UnitPrice) that = 0 or NULL --> 2,517 Rows 
select * from Online_Retail 
where UnitPrice = 0 or UnitPrice is null
--
delete from Online_Retail  where UnitPrice = 0 or UnitPrice is null

--StockCode(S) -> [ Description(sample) , Quantity(-1) , CustomerID(NULL) ] --> 63 Rows
select * from Online_Retail 
where StockCode = 'S' 
order by StockCode
--select * from Online_Retail where InvoiceNo = 'C537581'
--
delete from Online_Retail where StockCode = 'S'

--Quantity -> 9,227 (will delete)
select * from Online_Retail where Quantity < 0
-- select * from Online_Retail where InvoiceNo = 'C536391'
-- select * from Online_Retail where CustomerID = '17548' order by InvoiceNo
--
delete from Online_Retail where Quantity < 0

-- Update Country (Israel to Palestine) 295 Rows
select * from Online_Retail
where Country = 'Israel'
--
update Online_Retail
set Country = 'Palestine'
where Country = 'Israel'



-- Column InvoiceDate -> fills any missing (NULL) values in the InvoiceDate column by copying the previous value from previous row
--                       [ replace NULL value of current row with the previous row ]
-- Run Python Script from VS-Code --> file name [ SQL data cleaning.py ]

-- Null values -> 308,950 rows  ( 58.3 % from the all Database )
select * from Online_Retail where InvoiceDate is null




select * from Online_Retail
-- No. of all data = 530,102 rows (after cleaning)





-------------------------------------------------------------------------------------
-----------------------------( Analytical SQL Project ) -----------------------------
-------------------------------------------------------------------------------------
------- ( Q1 )
-- 1- get Top 10 CustomerID by Revenue
select top 10 CustomerID, round(sum(Quantity * UnitPrice), 0) as TotalRevenue
from Online_Retail
where CustomerID is not null
group by CustomerID
order by TotalRevenue desc

-- 2- get Top 10 selling product by Quantity
select top 10 Description, sum(Quantity) as [No. of Orders], round(sum(Quantity * UnitPrice), 0) as RevenuePerProduct
from Online_Retail
where CustomerID is not null
group by Description
order by [No. of Orders] desc


 
-- 3- monthly sales to total revenue at the monthly level (for 22 month)
select format(InvoiceDate, 'yyyy-MM') as YearMonth, round(sum(Quantity * UnitPrice), 0) as [Revenue Per Month]
from Online_Retail
where InvoiceDate is not null
group by format(InvoiceDate, 'yyyy-MM')
order by [Revenue Per Month] desc

select top 100 StockCode, round(sum(Quantity * UnitPrice), 0) as [Revenue Per Month]
from Online_Retail
--where InvoiceDate is not null
group by StockCode
order by [Revenue Per Month] desc

/*
select top 300 format(InvoiceDate, 'yyyy-MM') as YearMonth, StockCode, round(sum(Quantity * UnitPrice), 0) as MonthlyRevenue
from Online_Retail
where InvoiceDate like '2010-07%'
group by StockCode, format(InvoiceDate, 'yyyy-MM')
order by MonthlyRevenue desc
 */




-- 4- get top 3 selling product every year (by Revenue)
select *
from (
	   select format(InvoiceDate, 'yyyy-MM') as YearMonth
			 ,StockCode
			 ,round(sum(Quantity * UnitPrice), 0) as [Revenue Per Month]
			 ,row_number() over(partition by format(InvoiceDate, 'yyyy-MM') order by round(sum(Quantity * UnitPrice), 0) desc) as rnk
	   from Online_Retail
	   --where InvoiceDate like '201[0-9]-[0-9][0-9]-%'
	   group by format(InvoiceDate, 'yyyy-MM'), StockCode
) tab
where tab.rnk <= 3
order by tab.YearMonth , tab.[Revenue Per Month] desc 



-- 5- Calculates of the revenue and customer distribution for each country
--    Query insights into how each country contributes to the overall sales and customer base.
--    It allows for comparing revenue, number of customers, and sales performance across different countries.
with CTE_totalRevenue as(
	select round(sum(Quantity * UnitPrice), 0) as totalRevenue
	from Online_Retail
),
CTE_totalCustomer as(
	select count(distinct CustomerID) as totalCustomer
	from Online_Retail
)
select Country
      ,count(distinct customerID) as [No. Customer]
	  ,c.totalCustomer
	  ,sum(Quantity) as [No. of Items]
      ,round(sum(Quantity * UnitPrice), 0) as [Revenue Per Country]
	  ,r.totalRevenue
      ,round( (round(sum(Quantity * UnitPrice), 0) / r.totalRevenue)*100, 1 ) as [Sales Rate]
	  ,round( count(distinct customerID) / c.totalCustomer , 1) as [Customer Rate]
from Online_Retail, CTE_totalRevenue r, CTE_totalCustomer c
group by Country, c.totalCustomer, r.totalRevenue
order by [Revenue Per Country] desc



-- all customers in all country -> 4338
select count(distinct CustomerID)
from Online_Retail

select Country, sum(Quantity) as [No. of Items], ROW_NUMBER() over(order by sum(Quantity) desc) as rnk
from Online_Retail
group by Country;






-------- ( Q2 )
----------------------- RFM ---------- 4,338 rows
with CTE_RFM as (
			  select CustomerID 
			  ,max(format(InvoiceDate, 'yyyy-MM-dd')) as [Last Purchase Date]
			  ,DATEDIFF(day, max(InvoiceDate), '2011-12-10') as Recency  -- how recent the last transaction
			  ,count(distinct InvoiceNo) as Frequency  -- how many times the customer has bought from our store
			  ,round(sum(Quantity * UnitPrice), 0) as Monetray  -- how much each customer has paid for our products
			  from Online_Retail
			  where CustomerID is not null 
			  group by CustomerID 
			  --order by Frequency desc  
			  ),

-- use dynamic range (case when)
CTE_RFM_Score as (
					select *
						  ,case 
							  when Recency between 0 and 70    then 5
							  when Recency between 71 and 130  then 4
							  when Recency between 131 and 230 then 3
							  when Recency between 231 and 320 then 2
							  when Recency between 321 and 697 then 1
						   end as Recency_Score
						  ,case 
							  when Frequency between 1 and 12   then 1
							  when Frequency between 13 and 24  then 2
							  when Frequency between 25 and 37  then 3
							  when Frequency between 38 and 57  then 4
							  when Frequency between 58 and 209 then 5
						   end as Frequency_Score
						  ,case 
							  when Monetray between 1 and 499       then 1
							  when Monetray between 500 and 1049    then 2
							  when Monetray between 1050 and 1869   then 3
							  when Monetray between 1870 and 3529   then 4
							  when Monetray between 3530 and 280206 then 5
						   end as Monetray_Score
					from CTE_RFM
					-- order by Monetray desc
					),

CTE_FM_AVG_Score as (
					select *, round( (Frequency_Score + Monetray_Score)/2 , 0) as FM_AVG_Score
			    	from CTE_RFM_Score 
					)

select *
      ,case 
		 when Recency_Score = 5 and FM_AVG_Score in (5,4) then 'Champions'
		 when Recency_Score = 4 and FM_AVG_Score = 5 then 'Champions'
		 when Recency_Score in (5,4) and FM_AVG_Score = 2 then 'Potential Loyalists'
		 when Recency_Score in (4,3) and FM_AVG_Score = 3 then 'Potential Loyalists'
		 when Recency_Score = 5 and FM_AVG_Score = 3 then 'Loyal Customers'
		 when Recency_Score = 4 and FM_AVG_Score = 4 then 'Loyal Customers'
		 when Recency_Score = 3 and FM_AVG_Score in (5,4) then 'Loyal Customers'
		 when Recency_Score = 5 and FM_AVG_Score = 1 then 'Recent Customers'
		 when Recency_Score in (4,3) and FM_AVG_Score = 1 then 'Promising'
		 when Recency_Score = 3 and FM_AVG_Score = 2 then 'Customer Needing Attention'
		 when Recency_Score = 2 and FM_AVG_Score in (3,2) then 'Customer Needing Attention'
		 when Recency_Score = 2 and FM_AVG_Score in (5,4) then 'At Risk'
		 when Recency_Score = 1 and FM_AVG_Score = 3 then 'At Risk'
		 when Recency_Score = 1 and FM_AVG_Score in (5,4) then 'Cant Lose Them'
		 when Recency_Score = 2 and FM_AVG_Score = 1 then 'Hibernating'
		 when Recency_Score = 1 and FM_AVG_Score = 2 then 'Hibernating'
		 when Recency_Score = 1 and FM_AVG_Score = 1 then 'Lost'
	   end as [Customer Segmentation]

from CTE_FM_AVG_Score
order by Recency desc

------------------------- THE END -------------------------








/*
-- 127 rows
select distinct Recency
from CTE_RFM
order by Recency desc

-- 59 rows
select distinct Frequency
from CTE_RFM
order by Frequency desc

-- 2,246 rows
select distinct Monetray
from CTE_RFM
order by Monetray desc


 recency from 697 to 0

    600:697 -> 3
    500:599 -> 3
	400:499 -> 3
	300:399 -> 19
	200:299 -> 29
	100:199 -> 33
	0:99    -> 38


score 1		321:697 -> 20
score 2		231:320 -> 28
score 3		131:230 -> 31
score 4		71:130  -> 20
score 5		0:70    -> 28

697
666
638
577
546
516
485
454
424
363
342
341
340
339
338
337
336
335
333
332
311
310
307
305
304
303
302
301
283
282
281
280
279
278
277
275
274
253
252
251
250
249
247
246
245
244
243
242
223
220
219
218
217
216
215
214
212
192
191
190
189
188
187
186
184
183
182
181
162
161
160
159
157
156
155
154
153
152
151
130
129
128
127
126
125
124
123
121
120
100
99
98
96
95
93
92
91
90
89
70
69
68
67
66
65
64
63
61
60
39
38
37
36
35
33
32
31
30
29
9
6
5
4
3
2
1
0
NULL

/*