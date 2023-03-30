use Admin
go
set nocount on
go
/**********************************************************
* SCALAR FUNCTION: px.GetProcedureListSK
* Creator:      TRIO\GTower
* Created:      3/27/2023 3:37 PM
* Notes:	
    
* Sample Usage

	
    select
        HomeDatabase,
        Name,
        ActualProcedureListSK = pl.ProcedureListSK,
        UdfProcedureListSK = px.GetProcedureListSK(HomeDatabase, Name),
        Description,
        SystemName,
        SystemTag
    from px.ProcedureList pl

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function px.GetProcedureListSK
(
    @HomeDatabase nvarchar(128),
    @Name nvarchar(128)
)
returns int
as
begin

return
(
	select ProcedureListSK
    from px.ProcedureList
    where HomeDatabase = @HomeDatabase
        and Name = @Name
)

end
go
