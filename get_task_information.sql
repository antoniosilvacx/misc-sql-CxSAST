use cxdb;

declare @taskid as integer = 79638


;

select top 20 data.*, es.servername, concat( '\\', substring(serveruri, 8, len(serveruri) - 57), '\d$\Program Files\Checkmarx\Checkmarx Engine Server\Engine Server\Logs\ScanLogs\', projectname, '_', projectid ) as Path
from (
	select 'Running' as status, sr.createdon, sr.projectid, sr.projectname, sr.loc, sr.stagedetails as details, sr.sourceid, sr.serverid, sr.enginestartedon, sr.enginefinishedon
	from scanrequests sr 
	where sr.taskid = @taskid
	union 
	select 'Finished' as status, ts.ScanRequestCreatedOn, ts.ProjectId, tse.projectname, tse.loc, convert(nvarchar(20), ts.comment) as details, ts.SourceId, ts.ServerID, ts.EngineStartedOn, ts.EngineFinishedOn
	from taskscans ts
	left join TaskScanEnvironment tse on tse.scanid = ts.id
	where ts.taskid = @taskid
	union
	select 'Failed' as status, fs.CreatedOn, fs.ProjectID, fs.ProjectName, fs.loc, fs.Details, fs.sourceid, fs.serverid, fs.enginestartedon, null
	from FailedScans fs
	where fs.taskid = @taskid
	union
	select 'Canceled' as status, null, cs.ProjectId, p.name, null, cs.StageDetails, null, null, null, null
	from CanceledScans cs
	left join projects p on p.id = cs.projectid
	where cs.Id = @taskid ) as data
left join engineservers es on es.id = serverid

order by createdon desc