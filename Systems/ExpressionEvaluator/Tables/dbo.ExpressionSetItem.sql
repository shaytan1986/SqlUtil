/**********************************************************
* dbo.ExpressionSetItem
* Creator:		Shaytan1986
* Created:		4/11/2022 4:22 PM
* Description:  Individual expression rules (items) to be AND-ed together to evaluate whether an ExpressionSetevalutes to true or not.
* Sample Usage:

select top 100 * 
from [dbo].[ExpressionSetItem]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[ExpressionSetItem]
go
create table [dbo].[ExpressionSetItem]
(
    ExpressionSetItemSK bigint identity(1,1) not null, 
	ExpressionSetSK int not null,
    Field nvarchar(128) not null,
    OperatorCode varchar(10) not null,
    Comparator nvarchar(max) not null,
    ArgMayBeNull bit not null constraint DF__dbo_ExpressionSetItem__ArgMayBeNull default 0
    constraint PKC__dbo_ExpressionSetItem__ExpressionSetSK_Field primary key clustered (ExpressionSetSK, Field) 
        with (data_compression = none)
)

go
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__dbo_ExpressionSetItem__ExpressionSetItemSK'
		and [object_id] = object_id('dbo.ExpressionSetItem')
)
begin
    create unique nonclustered index IXNU__dbo_ExpressionSetItem__ExpressionSetItemSK
        on dbo.ExpressionSetItem (ExpressionSetItemSK)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__dbo_ExpressionSetItem__ExpressionSetItemSK] on [dbo].[ExpressionSetItem]', 0, 1) with nowait
end
go
/*****************************
Foreign Key: 
    dbo.ExpressionSetItem > dbo.Operator
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__dbo_ExpressionSetItem__OperatorCode'
		and [object_id] = object_id('dbo.ExpressionSetItem')
)
begin
    create nonclustered index IXN__dbo_ExpressionSetItem__OperatorCode
        on dbo.ExpressionSetItem (OperatorCode)
        with (data_compression = none, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('dbo.ExpressionSetItem')
		and name = 'FK__dbo_ExpressionSetItem__dbo_Operator__OperatorCode'
)
begin
    alter table dbo.ExpressionSetItem
		add constraint FK__dbo_ExpressionSetItem__dbo_Operator__OperatorCode
		foreign key (OperatorCode) references dbo.Operator (Code)
end
go