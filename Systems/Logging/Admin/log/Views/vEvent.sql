use Admin
go
set nocount on
go
/**********************************************************
* VIEW: log.vEvent
* Creator:      TRIO\GTower
* Created:      2/3/2023 3:20 PM
* Notes:	
    

* Sample Usage:

	select top 1000 *
    from log.vEvent

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter view log.vEvent
as

select
    EventID = e.EventID,
    ServerName = e.ServerName,
    SeverityID = e.SeverityID,
    SeverityCode = s.Code,
    SeverityName = s.Name,
    Category = e.Category,
    SubCategory = e.SubCategory,
    RunGuid = e.RunGuid,
    SourceName = e.SourceName,
    Msg = e.Msg,
    StructuredDetails = e.StructuredDetails,
    CreatedBy = e.CreatedBy,
    InsertDateUtc = e.InsertDateUtc
from log.Event e
inner join log.Severity s
    on e.SeverityID = s.SeverityID

go

