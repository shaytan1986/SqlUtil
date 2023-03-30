use Admin
go
set nocount on
go

/**********************************************************
* TABLE: px.ProcedureListExecution
* Creator:		TRIO\GTower
* Created:		3/28/2023 10:05 AM
* Notes:
	Logs a specific execution of a Procedure list
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureListExecution]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureListExecution') is null
begin
    create table [px].[ProcedureListExecution]
    (
        ProcedureListExecutionSK bigint identity(1,1) not null, 
        ProcedureListSK int not null,
        StartDateUtc datetime2(7) not null constraint DF__px_ProcedureListExecution__StartDateUtc default sysutcdatetime(),
        EndDateUtc datetime2(7) null,
        ErrorMessage nvarchar(4000) null,
        IsComplete as convert(bit, iif(EndDateUtc is not null, 1, 0)),
        IsError as convert
            (
                bit, 
                case
                    when EndDateUtc is null then null
                    when ErrorMessage is null then 0
                    else 1
                end
            ),
        InvokedBy nvarchar(128) not null constraint DF__px_ProcedureListExecution__InvokedBy default suser_sname()
        constraint PKC__px_ProcedureListExecution__ProcedureListExecutionSK primary key clustered (ProcedureListExecutionSK) 
            with (data_compression = none)
    )
end
go

