use util
go
set nocount, xact_abort on
go

/**********************************************************
* SCRIPT:       LoadAllergyPartners
* Creator:      TRIO\GTower
* Created:      1/30/2023 3:21 PM
* Notes:	
	Sets up Proc Execution configuration for LoadAllergyPartners

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
declare
    @Msg nvarchar(max)

/** Create List **/
declare 
    @ListSK int,
    @ListName nvarchar(128) = 'LoadAllergyPartners'

select @ListSK = ListSK
from px.List
where Name = @ListName

if @ListSK is null
begin

    insert into px.List
    (
        Name,
        Label,
        Description,
        SystemName,
        SystemTag,
        CreatedBy,
        ModifiedBy
    )
    values
        ('LoadAllergyPartners', 'Load Allergy Partners', 'SystemName', 'APLoad', 'Orchestrator', suser_sname(), null)

    select @ListSK = scope_identity()
end

select @msg = concat(quotename(sysutcdatetime()), ': ListSK: ', @ListSK); raiserror(@msg, 0, 1) with nowait

/** Create List Items **/ 
declare @src table
(
    DatabaseName nvarchar(128) not null,
    SchemaName nvarchar(128) not null,
    ProcName nvarchar(128) not null,
    ExecOrder int not null
)

insert into @src
(
    DatabaseName,
    SchemaName,
    ProcName,
    ExecOrder
)
select 'StageAP', 'dbo', 'LoadEncounter', 0 union all
select 'StageAP', 'dbo', 'LoadMedicationDiagnosis', 1 union all
select 'StageAP', 'dbo', 'LoadPatient', 2 union all
select 'StageAP', 'dbo', 'LoadProviders', 3 union all
select 'StageAP', 'dbo', 'LoadAllergy', 4 union all
select 'StageAP', 'dbo', 'LoadMedication', 5 union all
select 'StageAP', 'dbo', 'LoadDiagnosis', 6 union all
select 'StageAP', 'dbo', 'LoadLocation', 7 union all
select 'StageAP', 'dbo', 'LoadObservation', 8

if exists
(
    select 
        DatabaseName,
        SchemaName,
        ProcName,
        ExecOrder
    from @src
    except
    select
        DatabaseName,
        SchemaName,
        ProcName,
        ExecOrder
    from px.ListItem
    where ListSK = @ListSK
)
    begin
        select @msg = concat(quotename(sysutcdatetime()), ': Changes detected in ListItems.'); raiserror(@msg, 0, 1) with nowait

        delete a
        from px.ListItem a
        where @ListSK = @ListSK

        select @msg = concat(quotename(sysutcdatetime()), ': Deleting ', @@rowcount, ' ListItem row(s) for ListSK: ', @ListSK); raiserror(@msg, 0, 1) with nowait

        insert into px.ListItem
        (
            ListSK,
            DatabaseName,
            SchemaName,
            ProcName,
            ExecOrder
        )
        select
            ListSK = @ListSK,
            DatabaseName,
            SchemaName,
            ProcName,
            ExecOrder
        from @src
    
        select @msg = concat(quotename(sysutcdatetime()), ': Inserted ', @@rowcount, ' ListItem row(s) for ListSK: ', @ListSK); raiserror(@msg, 0, 1) with nowait

    end
else
    begin

        select @msg = concat(quotename(sysutcdatetime()), ': No changes to ListItems. Skipping ListItem [Re]population'); raiserror(@msg, 0, 1) with nowait
        
    end