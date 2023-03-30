use Admin
go
set nocount on
go

/**********************************************************
* VIEW: px.vProcExecutionListItem
* Creator:      TRIO\GTower
* Created:      3/28/2023 4:36 PM
* Notes:	
    

* Sample Usage:

	select top 1000 *
    from px.vProcExecutionListItem

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter view px.vProcedureListExecutionItem
as

select
    ProcedureListExecutionSK = x.ProcedureListExecutionSK,
    ProcedureListSK = x.ProcedureListSK,
    ExecutionStartDateUtc = x.StartDateUtc,
    ExecutionEndDateUtc = x.EndDateUtc,
    ExecutionElapsedSec = 
        iif
        (
            datediff(day, x.StartDateUtc, x.EndDateUtc) > 24,
            datediff(second, x.StartDateUtc, x.EndDateUtc) ,
            datediff(ms, x.StartDateUtc, x.EndDateUtc) / 1000.0
        ),
    ExecutionErrorMessage = x.ErrorMessage,
    ExecutionIsComplete = x.IsComplete,
    ExecutionIsError = x.IsError,
    ProcedureListExecutionItemSK = xi.ProcedureListExecutionItemSK,
    ExecutionItemStartDateUtc = xi.StartDateUtc,
    ExecutionItemEndDateUtc = xi.EndDateUtc,
    ExecutionItemElapsedSec = 
        iif
        (
            datediff(day, xi.StartDateUtc, xi.EndDateUtc) > 24,
            datediff(second, xi.StartDateUtc, xi.EndDateUtc) ,
            datediff(ms, xi.StartDateUtc, xi.EndDateUtc) / 1000.0
        ),
    ExecutionItemErrorMessage = xi.ErrorMessage,
    ExecutionItemIsComplete = xi.IsComplete,
    ExecutionItemIsError = xi.IsError
from px.ProcedureListExecution x
left outer join px.ProcedureListExecutionItem xi
    on x.ProcedureListExecutionSK = xi.ProcedureListExecutionSK
left outer join px.ProcedureListItem pli
    on xi.ProcedureListItemSK = pli.ProcedureListItemSK




go