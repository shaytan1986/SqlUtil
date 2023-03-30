use Admin
go
set nocount on
go
/**********************************************************
* TABLE TYPE: px.tNameNVarchar
* Creator:      TRIO\GTower
* Created:      9/29/2022 9:44 AM
* Notes:	
	!!WARNING!! Changing table types is a pain in the butt later on.
        You have to drop every object which references the type, then drop the type, then change the type, then rebuild the objects
        Use these with care, and with known, stable schemas
* Sample Usage:

	declare @tNameNVarchar px.tNameNVarchar

    insert @tNameNVarchar select 'foo', 'bar'

    select * from @tNameNVarchar

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if type_id('px.tNameNVarchar') is null
begin
    create type px.tNameNVarchar as table
    (
        Name nvarchar(128) not null,
        Value nvarchar(max) null
    )

    raiserror(N'Created Table Type: px.tNameNVarchar', 0, 1) with nowait
    
end

go