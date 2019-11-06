SELECT *
FROM [Sales].[SalesOrderDetail]
	,[Production].[TransactionHistory]
	,[Production].[TransactionHistoryArchive]
	,[Production].[WorkOrder]
	,[Production].[WorkOrderRouting]

