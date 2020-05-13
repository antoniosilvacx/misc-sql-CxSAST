use cxdb;

declare @projID as integer = 59312

;

select top 1 ts.id, tse.projectname, ts.projectid, ts.sourceid, ts.EngineStartedOn, es.servername, concat( '\\', substring(serveruri, 8, len(serveruri) - 57), '\d$\Program Files\Checkmarx\Checkmarx Engine Server\Engine Server\Logs\ScanLogs\', projectname, '_', projectid ) as Path
from taskscans ts
left join TaskScanEnvironment tse on tse.scanid = ts.id
left join engineservers es on es.id = ts.ServerID
where --is_incremental = 0 and
--not enginefinishedon is null and
projectid = @projID
order by enginestartedon desc


