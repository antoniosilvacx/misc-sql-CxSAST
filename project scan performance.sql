use cxdb;

select
	p.name, min(TPL) as min, max(TPL) as max, avg(TPL) as AvgTPL, stdev(TPL) as stdev
from
	(
		select 
			ts.projectid, tse.loc, datediff( minute, ts.ScanRequestCreatedOn, ts.ScanRequestCompletedOn)/ (tse.LOC / 10000.0) as TPL
		from 
			TaskScans ts
		left join
			TaskScanEnvironment tse on tse.ScanId = ts.id
		where 
			tse.loc  > 0
		and
			ts.QueuedOn >= dateadd( month, -1, getdate())
	) as data

left join
	projects p on p.id = projectid
group by
	p.name
