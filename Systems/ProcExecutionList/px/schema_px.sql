use util
go
set nocount, xact_abort on
go
if schema_id('px') is null
begin
    exec (N'create schema px')
    raiserror('Created schema [px]', 0, 1) with nowait

    declare 
        @RDFS_COMMENT nvarchar(128) = N'rdfs:comment',
        @Description nvarchar(4000) = N'Schema holds objects related to the Proc Execution (PX) subsystem'

    exec sys.sp_addextendedproperty
        @name = 'rdfs:comment', -- sysname
        @value = @Description,
        @level0type = 'SCHEMA',
        @level0name = N'px'

    raiserror('schemas:px %s "%s".', 0, 1, @RDFS_COMMENT, @Description)
end