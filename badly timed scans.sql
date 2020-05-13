select
	p.name, tse.loc, ts.queuedon, ts.startTime, ts.ScanRequestCreatedOn, ts.ScanRequestCompletedOn, ts.finishtime
from
	taskscans ts
left join
	TaskScanEnvironment tse on tse.scanid = ts.id
left join
	projects p on p.id = ts.ProjectId
where 
	ts.queuedon > dateadd( month, -1, getDate())
and
	ts.ScanRequestCompletedOn < ts.ScanRequestCreatedOn