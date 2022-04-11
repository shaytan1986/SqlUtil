/**********************************************************
* dbo.ExpressionSet
* Creator:		Shaytan1986
* Created:		4/11/2022 4:18 PM
* Description:  A collection of expression set rules to be evaluated in a particular context
* Sample Usage:

select top 100 * 
from [dbo].[ExpressionSet]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[ExpressionSet]
go
create table [dbo].[ExpressionSet]
(
    ExpressionSetSK int identity(1,1) not null, 
	Context varchar(100) not null,
    Ordering int not null,
    Description varchar(8000) not null,
    OutputValue nvarchar(1000) not null,
    IsActive bit not null constraint DF__dbo_ExpressionSet__IsActive default 1,
    constraint PKC__dbo_ExpressionSet__Context_Ordering_ExpressionSetSK primary key clustered (Context, Ordering, ExpressionSetSK) 
        with (data_compression = none)
)

go
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__dbo_ExpressionSet__ExpressionSetSK'
		and [object_id] = object_id('dbo.ExpressionSet')
)
begin
    create unique nonclustered index IXNU__dbo_ExpressionSet__ExpressionSetSK
        on dbo.ExpressionSet (ExpressionSetSK)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__dbo_ExpressionSet__ExpressionSetSK] on [dbo].[ExpressionSet]', 0, 1) with nowait
end
go

