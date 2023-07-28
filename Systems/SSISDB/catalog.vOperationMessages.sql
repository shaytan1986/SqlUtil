use ssisdb
go
set nocount, xact_abort on
go

/**********************************************************
* VIEW: catalog.vOperationMessages
* Creator:      TRIO\GTower
* Created:      5/11/2023 5:06 PM
* Notes:	
    notes

* Sample Usage:

	select top 1000 *
    from catalog.vOperationMessages
    

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter view catalog.vOperationMessages
as

select
    operation_message_id, 
    operation_id,
    message_time,
    message_type,
    message_type_desc = 
        case message_type
            when -1 then 'Unknown'            
            when 10 then 'Pre-validate'
            when 20 then 'Post-validate'
            when 30 then 'Pre-execute'
            when 40 then 'Post-execute'
            when 50 then 'StatusChange'
            when 60 then 'Progress'
            when 70 then 'Information'
            when 80 then 'VariableValueChanged'
            when 90 then 'Diagnostic'
            when 100 then 'QueryCancel'
            when 110 then 'Warning'
            when 120 then 'Error'
            when 130 then 'TaskFailed'
            when 140 then 'DiagnosticEx'
            when 200 then 'Custom'
            when 400 then 'NonDiagnostic'
            else null
        end,
    message_source_type,
    message_source_type_desc = 
        case message_source_type
            when 10 then 'Entry APIs, such as T-SQL and CLR Stored procedures'
            when 20 then 'External process used to run package (ISServerExec.exe)'
            when 30 then 'Package-level objects'
            when 40 then 'Control Flow tasks'
            when 50 then 'Control Flow containers'
            when 60 then 'Data Flow task'
            else null
        end

from catalog.operation_messages


go

