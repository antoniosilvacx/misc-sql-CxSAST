use cxdb;
select data.id, p.name, data.LOC, data.CreatedOn, data.CompletedOn, datediff( minute, data.createdon, data.completedon ) as 'Minutes' from
(
	select
		sr.id,
		sr.projectid, sr.LOC, sr.createdon, sr.CompletedOn
	from
		scanrequests sr
	where
		sr.ServerID = 39
	union
	select 
		ts.id,
		ts.ProjectId, tse.loc, ts.starttime, ts.finishtime
	from 
		taskscans ts
	left join
		TaskScanEnvironment tse on tse.scanid = ts.id	
	where ts.ServerID = 39
	and ts.ScanRequestCompletedOn > dateadd( day, -1, getdate())
) as data
left join
	projects p on p.id = data.ProjectID
order by createdon asc, completedon asc
	-- e13 = 39