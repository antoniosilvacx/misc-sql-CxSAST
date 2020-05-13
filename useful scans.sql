use cxdb;



select
	data.projectid, data.taskId, data.lastTaskId,
--	data.*,ts.enginefinishedon, ts.high, ts.medium, ts.low, ts.information, tse.loc,
	case 
		when data.high = ts.high and data.medium = ts.medium and data.low = ts.low and data.Information = ts.Information and data.loc = tse.loc then 0
		else 1
	end as 'Useful'
into #TemporaryUsefulScansTable
from
	(
	select ts.projectid, ts.id as taskId, ts.enginefinishedon, ts.high, ts.medium, ts.low, ts.information, tse.loc, (select top 1 ts2.id from taskscans ts2 where ts2.projectid = ts.projectid and ts2.id < ts.id order by ts2.id desc) as lastTaskId
	from taskscans ts with (nolock)
	left join TaskScanEnvironment tse with (nolock) on tse.scanid = ts.id
	where ts.enginefinishedon > dateadd( month, -1, getdate())
	) as data
left join
	taskscans ts with (nolock) on ts.id = data.lastTaskId
left join
	TaskScanEnvironment tse with (nolock) on tse.scanid = ts.id
	;

select
	data.projectid, (select count(*) from #TemporaryUsefulScansTable where projectid=data.projectid and Useful=1) as 'Useful scans', (select count(*) from #TemporaryUsefulScansTable where projectid=data.projectid) as 'Total scans'
from 
	(
	select
		distinct projectid
	from 
		#TemporaryUsefulScansTable
	) as data
;

drop table #TemporaryUsefulScansTable;