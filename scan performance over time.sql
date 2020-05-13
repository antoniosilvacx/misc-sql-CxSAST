select 
	es.ServerName, p.name, tse.loc, datediff( minute, ts.queuedon, ts.FinishTime) as scanminutes, ts.QueuedOn
from 
	taskscans ts
left join
	projects p on p.id = ts.ProjectId
right join
	engineservers es on es.id = ts.ServerID
left join
	TaskScanEnvironment tse on tse.ScanId = ts.id
where 
	ts.QueuedOn > dateadd( month, -1, getdate())