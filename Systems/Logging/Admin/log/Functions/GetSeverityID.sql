use Admin
go
set nocount on
go

/**********************************************************
* SCALAR FUNCTION: log.GetSeverityID
* Creator:      TRIO\GTower
* Created:      2/3/2023 2:45 PM
* Notes:	
    Gets the ID for a log.Severity record from either the code or the name
* Sample Usage

        ;with inputs as
        (
            select CodeOrName = Code, Type = 'Code'
            from log.Severity
            union all
            select CodeOrName = Name, Type = 'Name'
            from log.Severity
            union all
            select 'NASEV
        ), b as
        (
            select 
                CodeOrName,
                Type,
                Result = log.GetSeverityID(CodeOrName)
            from inputs
        )
        select *
        from b
        inner join log.Severity s
            on b.Result = s.ID

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function log.GetSeverityID
(
    @CodeOrName varchar(5)
)
returns tinyint
with schemabinding
as
begin

return
(
	select top 1 SeverityID
    from log.Severity
    where Code = iif(len(@CodeOrName) = 1, @CodeOrName, Code)
        and Name = iif(len(@CodeOrName) > 1, @CodeOrName, Name)
)

end
go

