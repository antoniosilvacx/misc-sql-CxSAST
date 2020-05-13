use cxdb;

declare @plist as table (Id int);
insert into @plist values (16110),(58618),(19907),(29312),(43126),(428),(63250),(19908),(32593),(17347),(25313),(58919),(1166),(29309),(59786),(63743);


select data.*, concat( '\\', substring(serveruri, 8, len(serveruri) - 57), '\d$\Program Files\Checkmarx\Checkmarx Engine Server\Engine Server\Logs\ScanLogs\', projectname, '_', projectid ) as Path
from (
	select 'Running' as status, sr.createdon, sr.projectid, sr.projectname, sr.loc, sr.stagedetails as details, sr.sourceid, sr.serverid 
	from scanrequests sr 
	where sr.projectid in (select Id from @plist)
	union 
	select 'Finished' as status, ts.ScanRequestCreatedOn, ts.ProjectId, tse.projectname, tse.loc, 'Finished' as details, ts.SourceId, ts.ServerID
	from taskscans ts
	left join TaskScanEnvironment tse on tse.scanid = ts.id
	where ts.projectid in (select Id from @plist)
	and ts.ScanRequestCreatedOn >= dateadd( month, -12, getdate())
	union
	select 'Failed' as status, fs.CreatedOn, fs.ProjectID, fs.ProjectName, fs.loc, fs.Details, fs.sourceid, fs.serverid
	from FailedScans fs
	where fs.projectid in (select Id from @plist)
	and fs.createdon >= dateadd( month, -12, getdate()) ) as data

left join engineservers es on es.id = serverid

order by createdon desc