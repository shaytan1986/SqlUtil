use Admin
go
set nocount on
go
/**********************************************************
* TABLE TYPE: px.tNameSqlVariant
* Creator:      TRIO\GTower
* Created:      9/29/2022 9:44 AM
* Notes:	
	!!WARNING!! Changing table types is a pain in the butt later on.
        You have to drop every object which references the type, then drop the type, then change the type, then rebuild the objects
        Use these with care, and with known, stable schemas
* Sample Usage:

	declare @tNameSqlVariant px.tNameSqlVariant

    insert @tNameSqlVariant select '1', N'NVarchar'
    insert @tNameSqlVariant select '2', getdate()
    insert @tNameSqlVariant select '3', cast(0 as bit)
    insert @tNameSqlVariant select '4', sysutcdatetime()
    insert @tNameSqlVariant select '5', null
    insert @tNameSqlVariant select '6', 'Varchar'

    select * from @tNameSqlVariant

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if type_id('px.tNameSqlVariant') is null
begin
    create type px.tNameSqlVariant as table
    (
        Name nvarchar(128) not null,
        Value sql_variant null,
        BaseType as     try_convert(nvarchar(128), sql_variant_property(Value, 'BaseType')),
        Precision as    try_convert(int, sql_variant_property(Value, 'Precision')),
        Scale as        try_convert(int, sql_variant_property(Value, 'Scale')),
        TotalBytes as   try_convert(int, sql_variant_property(Value, 'TotalBytes')),
        Collation as    try_convert(nvarchar(128), sql_variant_property(Value, 'Collation')),
        MaxLength as    try_convert(int, sql_variant_property(Value, 'MaxLength'))
    )

    raiserror(N'Created Table Type: px.tNameSqlVariant', 0, 1) with nowait
    
end

go