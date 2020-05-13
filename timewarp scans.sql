use cxdb;
select 
	*, timewarp*1.0/ok
from (
	select
		es.servername,
		(select count(*) from taskscans ts where ts.ServerID = es.id and ts.StartTime > dateadd( month, -2, getDate()) and ts.ScanRequestCompletedOn < ts.ScanRequestCreatedOn) as 'Timewarp', 
		(select count(*) from taskscans ts where ts.ServerID = es.id and ts.StartTime > dateadd( month, -2, getDate()) and ts.ScanRequestCompletedOn > ts.ScanRequestCreatedOn) as 'OK'
	from
		engineservers es) as data
order by 4 desc;
select 
	*
from (
	select
		p.name,
		(select avg(tse.loc) from taskscans ts left join TaskScanEnvironment tse on tse.scanid = ts.id where ts.projectid = p.id) as LOC,
		(select count(*) from taskscans ts where ts.projectid = p.id and ts.StartTime > dateadd( month, -2, getDate()) and ts.ScanRequestCompletedOn < ts.ScanRequestCreatedOn) as 'Timewarp', 
		(select count(*) from taskscans ts where ts.projectid = p.id and ts.StartTime > dateadd( month, -2, getDate()) and ts.ScanRequestCompletedOn > ts.ScanRequestCreatedOn) as 'OK'
	from
		projects p) as data
order by 3 desc;