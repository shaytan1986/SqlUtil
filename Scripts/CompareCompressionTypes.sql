
use [$(db)]
go
set nocount, xact_abort on
go
/*****************************
Compare all available compression types for a given table
*****************************/
declare
    @Schema nvarchar(128) = '$(schema)',
    @Table nvarchar(128) = '$(table)',
    @Msg nvarchar(max)

drop table if exists #results
create table #results
(
    RID int identity(1,1),
    BatchID int null,
    CompressionType nvarchar(60),
    ObjectName nvarchar(128) not null,
    SchemaName nvarchar(128) not null,
    IndexId int not null,
    PartitionNumber int not null,
    CurrentSizeKB decimal(38,5),
    CurrentSizeGB as CurrentSizeKB / power(1024, 2),
    EstimatedSizeKB decimal(38,5),
    EstimatedSizeGB as EstimatedSizeKB / power(1024, 2),
    CurrentSampleSizeKB decimal(38,5),
    CurrentSampleSizeMB as CurrentSampleSizeKB / 1024,
    EstimatedSampleSizeKB decimal(38,5),
    EstimatedSampleSizeMB as EstimatedSampleSizeKB / 1024,
    SavingsPct as 100 - convert(decimal(9,3), (100.0 * EstimatedSizeKB) / nullif(CurrentSizeKB, 0)),
    SampleSavingsPct as 100 - convert(decimal(9,3), (100.0 * EstimatedSampleSizeKB) / nullif(CurrentSampleSizeKB, 0))
)

declare 
    @CompressionType nvarchar(60),
    @BatchID int = 0

declare c cursor local fast_forward for
    select 'NONE' union all
    select 'ROW' union all
    select 'PAGE' union all
    select 'COLUMNSTORE' union all
    select 'COLUMNSTORE_ARCHIVE'
open c

fetch next from c into @CompressionType

while @@fetch_status = 0
begin

	select @msg = concat(quotename(sysutcdatetime()), ': Starting ', @CompressionType, ' compression'); raiserror(@msg, 0, 1) with nowait
    insert into #results
    (
        ObjectName,
        SchemaName,
        IndexId,
        PartitionNumber,
        CurrentSizeKB,
        EstimatedSizeKB,
        CurrentSampleSizeKB,
        EstimatedSampleSizeKB
    )    
    exec sys.sp_estimate_data_compression_savings
        @schema_name = @Schema,
        @object_name = @Table,
        @index_id = null, -- int
        @partition_number = null, -- int
        @data_compression = @CompressionType
    
    update #results
    set CompressionType = @CompressionType,
        BatchID = @BatchID
    where BatchID is null

    select @BatchID += 1
    fetch next from c into @CompressionType

end

deallocate c

select
    a.CompressionType,
    a.ObjectName,
    a.SchemaName,
    a.IndexId,
    IndexName = i.name,
    IsUnique = i.is_unique,
    IsPrimaryKey = i.is_primary_key,
    a.PartitionNumber,
    a.CurrentSizeGB,
    a.EstimatedSizeGB,
    a.CurrentSampleSizeMB,
    a.EstimatedSampleSizeMB,
    a.SavingsPct,
    a.SampleSavingsPct
from #results a
inner join sys.indexes i
    on object_id(a.SchemaName + '.' + a.ObjectName) = i.object_id
        and a.IndexId = i.index_id
order by i.is_primary_key desc, a.IndexId, 
    case a.CompressionType
        when 'NONE' then 0
        when 'ROW' then 1
        when 'PAGE' then 2
        when 'COLUMNSTORE' then 3
        when 'COLUMNSTORE_ARCHIVE' then 4
        else 5
    end