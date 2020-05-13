use cxdb;
-- average LOC per project
select 
	p.name,
	is_Incremental,
	tpl
	
from
	(
		select
			data.ProjectId,
			data.is_Incremental,
			avg( data.time ) as avgTime,
			avg( data.loc ) as avgLoc,
			avg( cast( data.time as decimal(10,4) ) / cast( data.loc as decimal(10,4) ) ) as tpl,
			count(*) as scancount
		from
			(
				select 
				ts.projectid, ts.is_Incremental, 
				datediff( minute, EngineStartedOn, EngineFinishedOn ) as time, tse.LOC/10000.0 as LOC
				from taskscans ts
				left join TaskScanEnvironment tse on tse.ScanId=ts.id
				where ts.ScanRequestCreatedOn > dateadd( month, -3, getdate())
				and tse.loc > 0
			) as data
		group by
			data.projectid, data.is_Incremental
	) as data
left join
	projects p on p.id = data.projectid
where
	scancount > 5
order by 1,2
