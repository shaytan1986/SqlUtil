use ssisdb
go

select
    operation_id,
    operation_type,
    operation_type_desc = 
        case operation_type
            when 1 then 'Integration Services Initialization'
            when 2 then 'Retention Window'
            when 3 then 'MaxProjectVersion'
            when 101 then 'deploy project'
            when 102 then 'get project'
            when 106 then 'restore project'
            when 200 then 'create/start execution'
            when 202 then 'stop operation'
            when 300 then 'validate project'
            when 301 then 'validate package'
            when 1000 then 'configure catalog'
            else null
        end,
    created_time,
    object_type,
    object_type_desc = 
        case object_type
            when 10 then 'folder'
            when 20 then 'project'
            when 30 then 'package'
            when 40 then 'environment'
            when 50 then 'execution instance'
            else null
        end,
    object_id,
    object_id_type =
        case
            when operation_type in (101,102,106,200,202,300,301) then 'Project ID'
            else null
        end,
    object_name,
    object_name_type =
        case
            when operation_type in (101, 102, 106, 300) then 'Project name'
            when operation_type in (301) then 'Package name'
            else null
        end,
    status,
    status_desc = choose(status, 'created', 'running', 'canceled', 'failed', 'pending', 'ended unexpectedly', 'succeeded', 'stopping', 'completed'),
    start_time,
    end_time,
    caller_sid,
    caller_name,
    process_id,
    stopped_by_sid,
    stopped_by_name,
    server_name,
    machine_name,
    operation_guid
from catalog.operations

