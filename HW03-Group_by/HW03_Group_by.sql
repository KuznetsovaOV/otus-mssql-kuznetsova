/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT 
  year(t.[InvoiceDate]) as '��� �������'
, month(t.[InvoiceDate]) as '����� �������'
, avg(t1.[UnitPrice]) as '������� ���� �� ����� �� ���� �������'
, sum(t1.[Quantity]*t1.[UnitPrice]) as '����� ����� ������ �� �����'
  
FROM [WideWorldImporters].[Sales].[Invoices] t
left join [WideWorldImporters].[Sales].[InvoiceLines] t1 on t.InvoiceID = t1.InvoiceID
where 
year(t.[InvoiceDate]) = 2015 
and month(t.[InvoiceDate]) = 4

group by
  year(t.[InvoiceDate]) 
, month(t.[InvoiceDate])

/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000

�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
SELECT 
  year(t.[InvoiceDate]) as '��� �������'
, month(t.[InvoiceDate]) as '����� �������'
, sum(t1.[Quantity]*t1.[UnitPrice]) as '����� ����� ������ �� �����'
  
FROM [WideWorldImporters].[Sales].[Invoices] t
left join [WideWorldImporters].[Sales].[InvoiceLines] t1 on t.InvoiceID = t1.InvoiceID
--where 
--year(t.[InvoiceDate]) = 2015 
--and month(t.[InvoiceDate]) = 4

group by
  year(t.[InvoiceDate]) 
, month(t.[InvoiceDate])

having
sum(t1.[Quantity]*t1.[UnitPrice]) > 4600000

/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.

�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������

������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
SELECT 
  year(t.[InvoiceDate]) as '��� �������'
, month(t.[InvoiceDate]) as '����� �������'
, t2.StockItemName as '������������ ������'
, sum(t1.[Quantity]*t1.[UnitPrice]) as '����� ������'
, min(t.[InvoiceDate]) as '���� ������ �������'
, sum(t1.[Quantity]) as '���������� ����������'

  
FROM [WideWorldImporters].[Sales].[Invoices] t
left join [WideWorldImporters].[Sales].[InvoiceLines] t1 on t.InvoiceID = t1.InvoiceID
left join [WideWorldImporters].[Warehouse].[StockItems] t2 on t1.StockItemID = t2.StockItemID

group by
  year(t.[InvoiceDate]) 
, month(t.[InvoiceDate])
, t2.StockItemName

having 
sum(t1.[Quantity]) < 50

-- ---------------------------------------------------------------------------
-- �����������
-- ---------------------------------------------------------------------------
/*
�������� ������� 2-3 ���, ����� ���� � �����-�� ������ �� ���� ������,
�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
*/
--�������� ���������
DECLARE @Year INT = 2013
DECLARE @YearCnt INT = 4 
DECLARE @StartDate DATE = DATEFROMPARTS(@Year, 01,'01')
DECLARE @EndDate DATE = DATEADD(DAY, -1, DATEADD(YEAR, @YearCnt, 
@StartDate))

;WITH Cal(n) AS
(
SELECT 0 UNION ALL SELECT n + 1 FROM Cal
WHERE n < DATEDIFF(DAY, @StartDate, @EndDate)
),
FnlDt(d) AS
(
SELECT DATEADD(DAY, n, @StartDate) FROM Cal
),
FinalCte AS
(
SELECT
[Date] = CONVERT(DATE,d),
[Day] = DATEPART(DAY, d),
[Month] = DATENAME(MONTH, d),
[Year] = DATEPART(YEAR, d),
[DayName] = DATENAME(WEEKDAY, d)

FROM FnlDt
)
SELECT * 
into #Calendar
FROM finalCte
ORDER BY [Date]
OPTION (MAXRECURSION 0)

/*������ 2*/

select 
  year(cal.Date) as '��� �������'
, month(cal.Date) as '����� �������'
, isnull(sum(t1.[Quantity]*t1.[UnitPrice]),0) as '����� ����� ������ �� �����'
from #Calendar cal
left join [WideWorldImporters].[Sales].[Invoices] t on cal.Date = t.[InvoiceDate]
left join [WideWorldImporters].[Sales].[InvoiceLines] t1 on t.InvoiceID = t1.InvoiceID

group by
  year(cal.Date) 
, month(cal.Date)

having sum(t1.[Quantity]) is null
or (year(cal.Date) = 2015  and month(cal.Date) = 4 and sum(t1.[Quantity]*t1.[UnitPrice]) > 4600000)

order by 
  year(cal.Date) 
, month(cal.Date)