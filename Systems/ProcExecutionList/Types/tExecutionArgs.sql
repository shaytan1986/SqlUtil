use Admin
go
set nocount on
go

/**********************************************************
* TABLE TYPE: px.tExecutionArgs
* Creator:      TRIO\GTower
* Created:      9/29/2022 9:44 AM
* Notes:	
	!!WARNING!! Changing table types is a pain in the butt later on.
        You have to drop every object which references the type, then drop the type, then change the type, then rebuild the objects
        Use these with care, and with known, stable schemas
* Sample Usage:

	declare @tExecutionArgs px.tExecutionArgs

    select * from @tExecutionArgs

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if type_id('px.tExecutionArgs') is null
begin
    create type px.tExecutionArgs as table
    (
        DatabaseName varchar(128) null,
        SchemaName varchar(128) null,
        ProcedureName varchar(128) null,
        ExecutionOrder int null, -- if null, will apply to everything
        ParamName varchar(128) not null,
        ParamValue nvarchar(max) null

        unique clustered (DatabaseName, SchemaName, ProcedureName, ExecutionOrder, ParamName),
        check 
        (
            (DatabaseName is null and SchemaName is null and ProcedureName is null)
            or
            (DatabaseName is not null and SchemaName is not null and ProcedureName is not null)
        )
    )

    raiserror(N'Created Table Type: px.tExecutionArgs', 0, 1) with nowait
    
end

go