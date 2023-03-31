drop table if exists #obj
create table #obj
(
    DbName nvarchar(128),
    SchemaName nvarchar(128),
    SchemaId int,
    ProcName nvarchar(128),
    ObjectId int,
    ObjectType nchar(2),
    ObjectTypeDesc nvarchar(128),
    Stmt as concat
    (
        'exec ', quotename(DbName), '.dbo.sp_helptext ', quotename(concat(quotename(SchemaName), '.', quotename(ProcName)), '''')
    )
)
exec sp_msforeachdb N'
use ?

insert into #Obj
select DbName = ''?'', SchemaName = schema_name(schema_id), SchemaId = schema_id, ProcName = name, ObjectId = object_id, type, type_desc
from ?.sys.objects o
where name like ''%proc%''
    and type = ''P'''


delete #obj
where 
    ProcName like 'sys%'
or ProcName like 'sql%'
or ProcName like 'tmp%'
or ProcName like '%[0-9]%'
or ProcName like 'DBA%'
or ProcName like 'usp%'
or ProcName like '%[_]%'

select top 1000 *
from #obj


select top 1000 *,
concat('select Db = ', quotename(DBName, ''''), ', Obj = ', quotename(concat(SchemaName, '.', TableName), ''''), ', * from ', quotename(DbName), '.sys.dm_sql_referencing_entities(', quotename(concat(SchemaName, '.', TableName), ''''), ', N''OBJECT'') r inner join ', quotename(DBName), '.sys.objects o on r.referencing_id = o.object_id and o.type != ''TR''')
from ##ProcListTables

select Db = 'OMOP', Obj = 'Mdx.ProcedureList', * from [OMOP].sys.dm_sql_referencing_entities('Mdx.ProcedureList', N'OBJECT') r inner join [OMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'OMOP', Obj = 'Mdx.ProcedureListHistory', * from [OMOP].sys.dm_sql_referencing_entities('Mdx.ProcedureListHistory', N'OBJECT') r inner join [OMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'OMOP', Obj = 'Mdx.TrioOMOPProcedureList', * from [OMOP].sys.dm_sql_referencing_entities('Mdx.TrioOMOPProcedureList', N'OBJECT') r inner join [OMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'StageOMOP', Obj = 'Mdx.ETLProcedureGroup', * from [StageOMOP].sys.dm_sql_referencing_entities('Mdx.ETLProcedureGroup', N'OBJECT') r inner join [StageOMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'StageOMOP', Obj = 'Mdx.ETLProcedureList', * from [StageOMOP].sys.dm_sql_referencing_entities('Mdx.ETLProcedureList', N'OBJECT') r inner join [StageOMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Portal', Obj = 'Reporting.DownloadProcedure', * from [Portal].sys.dm_sql_referencing_entities('Reporting.DownloadProcedure', N'OBJECT') r inner join [Portal].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Portal', Obj = 'Form.FormProcedure', * from [Portal].sys.dm_sql_referencing_entities('Form.FormProcedure', N'OBJECT') r inner join [Portal].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Portal', Obj = 'Form.FormProcedureHistory', * from [Portal].sys.dm_sql_referencing_entities('Form.FormProcedureHistory', N'OBJECT') r inner join [Portal].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'MDX', Obj = 'Core.ScrubProcedure', * from [MDX].sys.dm_sql_referencing_entities('Core.ScrubProcedure', N'OBJECT') r inner join [MDX].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'TrioOMOP', Obj = 'Mdx.TrioOMOPProcedureList', * from [TrioOMOP].sys.dm_sql_referencing_entities('Mdx.TrioOMOPProcedureList', N'OBJECT') r inner join [TrioOMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'TrioOMOP', Obj = 'Mdx.ProcedureList', * from [TrioOMOP].sys.dm_sql_referencing_entities('Mdx.ProcedureList', N'OBJECT') r inner join [TrioOMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'TrioOMOP', Obj = 'Mdx.ProcedureListHistory', * from [TrioOMOP].sys.dm_sql_referencing_entities('Mdx.ProcedureListHistory', N'OBJECT') r inner join [TrioOMOP].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Augmedix', Obj = 'Reporting.DownloadProcedure', * from [Augmedix].sys.dm_sql_referencing_entities('Reporting.DownloadProcedure', N'OBJECT') r inner join [Augmedix].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Augmedix', Obj = 'Form.FormProcedure', * from [Augmedix].sys.dm_sql_referencing_entities('Form.FormProcedure', N'OBJECT') r inner join [Augmedix].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'
union all select Db = 'Augmedix', Obj = 'Form.FormProcedureHistory', * from [Augmedix].sys.dm_sql_referencing_entities('Form.FormProcedureHistory', N'OBJECT') r inner join [Augmedix].sys.objects o on r.referencing_id = o.object_id and o.type != 'TR'



-- Execution proc
exec StageOMOP.dbo.sp_helptext 'Mdx.ETLExecution'
-- Execution Proc
exec TrioOMOP.dbo.sp_helptext 'Mdx.TrioOMOPETLExecution'
-- Execution Proc
exec Portal.dbo.sp_helptext 'Reporting.DownloadProcedureGetList'