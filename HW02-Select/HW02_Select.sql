/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

  SELECT 
  StockItemID as '�� ������'
, StockItemName as '������������ ������'
  FROM [WideWorldImporters].[Warehouse].[StockItems]
  where [StockItemName] like 
  '%urgent%' or [StockItemName] like 'Animal%'

  /*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/
SELECT  t.[SupplierID]
       ,t.[SupplierName]
FROM [WideWorldImporters].[Purchasing].[Suppliers] t
left join [WideWorldImporters].[Purchasing].[PurchaseOrders] z on t.SupplierID = z.SupplierID 
where z.SupplierID is null

/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT distinct
  t.[OrderID]
 ,t1.CustomerName
 ,convert(nvarchar,t.[OrderDate],104) as OrderDate
 ,datename(month,t.[OrderDate]) as �����
 ,datepart(quarter,t.[OrderDate]) as �������
 ,iif(month(t.[OrderDate]) between 1 and 4,1,iif(month(t.[OrderDate]) between 5 and 8,2,3)) as '����� ����'
	 

  FROM [WideWorldImporters].[Sales].[Orders] t
  left join [WideWorldImporters].[Sales].[Customers] t1 on t.CustomerID = t1.CustomerID
  left join [WideWorldImporters].[Sales].[OrderLines]  t2 on t.OrderID = t2.OrderID 

where t.[PickingCompletedWhen] is not null 
and (t2.[UnitPrice] > 100 or t2.[Quantity] > 20)



-- ������������ �������
declare @m int = 100

SELECT 
  t.[OrderID]
 ,t1.CustomerName
 ,convert(nvarchar,t.[OrderDate],104) as OrderDate
 ,datename(month,t.[OrderDate]) as �����
 ,datepart(quarter,t.[OrderDate]) as �������
 ,iif(month(t.[OrderDate]) between 1 and 4,1,iif(month(t.[OrderDate]) between 5 and 8,2,3)) as '����� ����'
	 

  FROM [WideWorldImporters].[Sales].[Orders] t
  left join [WideWorldImporters].[Sales].[Customers] t1 on t.CustomerID = t1.CustomerID
  left join [WideWorldImporters].[Sales].[OrderLines]  t2 on t.OrderID = t2.OrderID 

where t.[PickingCompletedWhen] is not null 
and (t2.[UnitPrice] > 100 or t2.[Quantity] > 20)

group by
  t.[OrderID]
 ,t1.CustomerName
 ,convert(nvarchar,t.[OrderDate],104)
 ,datename(month,t.[OrderDate]) 
 ,datepart(quarter,t.[OrderDate]) 
 ,iif(month(t.[OrderDate]) between 1 and 4,1,iif(month(t.[OrderDate]) between 5 and 8,2,3)) 
 ,t.[OrderDate] 

order by 
 datepart(quarter,t.[OrderDate])
,iif(month(t.[OrderDate]) between 1 and 4,1,iif(month(t.[OrderDate]) between 5 and 8,2,3))
,t.[OrderDate] 

offset 1000 rows -- ���������� 1000 �����
fetch next @m rows only -- ������� @m �����

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT distinct
 d.DeliveryMethodName as '������ ��������'
,t.[ExpectedDeliveryDate] as '���� ��������'
,s.SupplierName as '��� ����������'
,p.FullName as '��� ����������� ���� ������������ �����'


  FROM [WideWorldImporters].[Purchasing].[PurchaseOrders] t  --������
  left join [WideWorldImporters].[Application].[DeliveryMethods] d on t.DeliveryMethodID = d.DeliveryMethodID --��������
  left join [WideWorldImporters].[Purchasing].[Suppliers] s on t.SupplierID = s.SupplierID -- ����������
  left join [WideWorldImporters].[Application].[People] p on t.ContactPersonID = p.PersonID --����
  where t.[ExpectedDeliveryDate] between '2013-01-01' and '2013-01-31'
  and d.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
  and t.[IsOrderFinalized] = 1 -- ��������

  /*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

SELECT top 10
 c.CustomerName 
,p.FullName 

FROM [WideWorldImporters].[Sales].[Orders] t
left join [WideWorldImporters].[Sales].[Customers] c on t.[CustomerID] = c.CustomerID
left join [WideWorldImporters].[Application].[People] p on t.[SalespersonPersonID] = p.PersonID
order by [OrderDate] desc


--������� � ���������� ����������

SELECT top 10 WITH TIES 
 c.CustomerName 
,p.FullName 

FROM [WideWorldImporters].[Sales].[Orders] t
left join [WideWorldImporters].[Sales].[Customers] c on t.[CustomerID] = c.CustomerID
left join [WideWorldImporters].[Application].[People] p on t.[SalespersonPersonID] = p.PersonID
order by [OrderDate] desc

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/

SELECT distinct 
 c.[CustomerID] as ID
,c.CustomerName as ������
,c.[PhoneNumber] as �������
FROM [WideWorldImporters].[Sales].[Orders] t
left join [WideWorldImporters].[Sales].[Customers] c on t.[CustomerID] = c.CustomerID
where t.[OrderID] in (SELECT t.OrderID
FROM [WideWorldImporters].[Sales].[OrderLines] t
left join [WideWorldImporters].[Warehouse].[StockItems] t1 on t.StockItemID = t1.StockItemID
 where t1.StockItemName = 'Chocolate frogs 250g')




