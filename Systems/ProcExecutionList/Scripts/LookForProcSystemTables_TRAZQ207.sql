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



select top 1000 *
from #obj
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





select top 100 * from [AP].[export].[Procedures]
select top 100 * from [Exports].[Immunology].[Procedures]