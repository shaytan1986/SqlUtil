use Admin
go
set nocount on
go

if schema_id('px') is null
begin
    exec (N'create schema px')
    raiserror('Created schema px', 0, 1) with nowait
end