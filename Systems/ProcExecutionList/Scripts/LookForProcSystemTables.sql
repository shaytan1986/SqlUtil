use Admin
go
set nocount on
go

drop table if exists #obj
create table #obj
(
    DbName nvarchar(128),
    SchemaName nvarchar(128),
    SchemaId int,
    TableName nvarchar(128),
    ObjectId int,
    Stmt as concat
    (
        'select top 100 * from ', quotename(DbName), '.', quotename(SchemaName), '.', quotename(TableName)
    )
)
exec sp_msforeachdb N'
use ?

insert into #Obj
select DbName = ''?'', SchemaName = schema_name(schema_id), SchemaId = schema_id, TableName = name, ObjectId = object_id
from ?.sys.tables o
where name like ''%proc%''
    and 0 <
    (
        select max(rows)
        from sys.partitions i
        where o.object_id = i.object_id
    )'


delete #obj
where 
    TableName like 'sys%'
or Tablename like 'sql%'
or TableName like 'tmp%'
or TableName like '%[0-9]%'
or TableName like 'DBA%'


drop table if exists ##ProcListTables
create table ##ProcListTables
(
    DbName nvarchar(128) not null,
    SchemaName nvarchar(128) not null,
    TableName nvarchar(128) not null
)
insert into ##ProcListTables
values
('OMOP'        , 'Mdx'      ,'ProcedureList'         ),
('OMOP'        , 'Mdx'      ,'ProcedureListHistory'  ),
('OMOP'        , 'Mdx'      ,'TrioOMOPProcedureList' ),
('StageOMOP'   , 'Mdx'      ,'ETLProcedureGroup'     ),
('StageOMOP'   , 'Mdx'      ,'ETLProcedureList'      ),
('Portal'      , 'Reporting','DownloadProcedure'     ),
('Portal'      , 'Form'     ,'FormProcedure'         ),
('Portal'      , 'Form'     ,'FormProcedureHistory'  ),
('MDX'         , 'Core'     ,'ScrubProcedure'        ),
('TrioOMOP'    , 'Mdx'      ,'TrioOMOPProcedureList' ),
('TrioOMOP'    , 'Mdx'      ,'ProcedureList'         ),
('TrioOMOP'    , 'Mdx'      ,'ProcedureListHistory'  ),
('Augmedix'    , 'Reporting','DownloadProcedure'     ),
('Augmedix'    , 'Form'     ,'FormProcedure'         ),
('Augmedix'    , 'Form'     ,'FormProcedureHistory'  )

select top 1000 
concat
(
    'select HomeDatabase = ', quotename(DBName, ''''), ', SchemaName = ', quotename(SchemaName, ''''), ', TableName = ', quotename(TableName, ''''), ', * from ', quotename(DBName), '.', quotename(SchemaName), '.', quotename(TableName)
)
from ##proclistTables

select top 1000 *
from admin.px.ProcedureListItem

use OMOP
go
set nocount on
go

exec sp_helptext 'Mdx.OMOPPersonSource'


select ETLProcedureGroupName,
    concat
    (
        'exec ', quotename(ETLProcedureDatabase), '.dbo.sp_helptext ', quotename(concat(ETLProcedureSchema, '.', ETLProcedureName), ''''), ' -- ', ETLProcedureGroupName
    )
from StageOMOP.Mdx.ETLProcedureGroup g
inner join StageOMOP.Mdx.ETLProcedureList p
    on g.ETLProcedureGroupID = p.ETLProcedureGroupID
order by ETLProcedureGroupName
    
exec [StageOMOP].dbo.sp_helptext 'Mdx.EndMirthCheck' -- Start Mirth
exec [StageOMOP].dbo.sp_helptext 'Mdx.StartMirthCheck' -- Stop Mirth

select top 1000 *
from Mdx.Core.ScrubProcedure

select top 1000 schema_name(schema_id),*
from TrioOMOP.Mdx.ProcedureList a
inner join Mdx.sys.objects b
    on a.ProcedureListName = b.name
select top 1000 *
from TrioOMOP.Mdx.TrioOMOPProcedureList a
inner join Trioomop.sys.objects b
    on parsename(a.ProcedureListName, 1) = b.Name

    exec sp_helptext 'Mdx.ProviderDrugModeSource'
select top 1000 *
from OMOP.Mdx.ProcedureList
select top 1000 *
from OMOP.Mdx.TrioOMOPProcedureList


select top 1000 schema_name(schema_id),*
from mdx.sys.objects
where name = 'TrioOMOPDrugEraSource_PsAAS'


exec Mdx.dbo.sp_helptext 'core.TrioOMOPPersonProviderUpdate'
exec sp_helptext 'ccda.TrioOMOPPersonProviderUpdate'