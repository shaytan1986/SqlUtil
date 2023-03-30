use Admin
go
set nocount on
go
/**********************************************************
* SCRIPT:       Evaluate Proc List Execution
* Creator:      TRIO\GTower
* Created:      3/30/2023 11:07 AM
* Notes:	
	This script shows you all the logged information for a run of a given ProcedureList

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
-- Parameters
declare 
    @HomeDatabase nvarchar(128) = 'Admin',
    @ProcedureListName nvarchar(128) = 'TestList'

/*****************************
Begin Script
*****************************/
declare
    @ProcedureListSK int,
    @ProcedureListExecutionSK bigint

-- Look up the proper ProcedureListSK
select @ProcedureListSK = px.GetProcedureListSK(@HomeDatabase, @ProcedureListName)

-- Get the most recent execution of the list
select top 1 @ProcedureListExecutionSK = ProcedureListExecutionSK
from px.ProcedureListExecution
where ProcedureListSK = @ProcedureListSK
order by ProcedureListExecutionSK desc

-- Metrics of the top-level Procedure List
select top 1000 *
from px.ProcedureListExecution
where ProcedureListExecutionSK = @ProcedureListExecutionSK

-- List of the provided args to the procedure
select top 1000 *
from px.ProcedureListExecutionArg
where ProcedureListExecutionSK = @ProcedureListExecutionSK

-- Metrics of individual item executions within the list
select top 1000 *
from px.ProcedureListExecutionItem
where ProcedureListExecutionSK = @ProcedureListExecutionSK

-- List of the actual evaluated args provided to each execution item
select
    ProcedureListExecutionItemSK = xi.ProcedureListExecutionItemSK,
    ExecutionOrder = li.ExecutionOrder,
    DatabaseName = li.DatabaseName,
    SchemaName = li.SchemaName,
    ProcedureName = li.ProcedureName,
    ParamName = xa.ParamName,
    ParamValue = xa.ParamValue
from px.ProcedureListExecutionItem xi
inner join px.ProcedureListItem li
    on xi.ProcedureListItemSK = li.ProcedureListItemSK
left outer join px.ProcedureListExecutionItemArg xa
    on xi.ProcedureListExecutionItemSK = xa.ProcedureListExecutionItemSK
where xi.ProcedureListExecutionSK = @ProcedureListExecutionSK