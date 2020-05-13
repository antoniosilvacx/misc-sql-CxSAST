use cxdb;

select 
	ProjectName, 
	es.servername,
	sr.enginestartedon as 'Scanning Since',	
	(select avg( datediff( minute, ts.EngineStartedOn, ts.EngineFinishedOn ) ) from taskscans ts where ts.projectid = sr.ProjectID and ts.EngineStartedOn > dateadd(month,-1,getdate()) and ts.enginefinishedon is not null) as AvgMinLastMonth,
	datediff( minute, sr.EngineStartedOn, getDate() ) as 'Current Scan Minutes',
	cast(datediff( hour, sr.EngineStartedOn, getDate() )/24.0 as decimal(10,1)) as 'Current Scan Days',
	sr.SourceLocationPath,
	LOC,
	cast( datediff( minute, sr.EngineStartedOn, getDate() ) / (loc/10000.0) as decimal(10,1) ) as ScanMinPer10kLOC,	

	(select count(*) from taskscans ts where ts.projectid = sr.ProjectID and ts.EngineStartedOn > dateadd(month,-1,getdate()) and ts.enginefinishedon is not null) as RecentScanCount
from 
	scanrequests sr
left join 
	engineservers es on es.id = sr.serverid
where sr.stage = 4
order by 9 desc;


select 
	ProjectName, sr.serverid, datediff( minute, sr.CreatedOn, getDate() ) as 'Queue Minutes',
	sr.SourceLocationPath,
	LOC,
	cast( datediff( minute, sr.CreatedOn, getDate() ) / (loc/10000.0) as decimal(10,1) ) as QueueMinPer10kLOC
from 
	scanrequests sr
where sr.stage < 4
order by 6 desc;