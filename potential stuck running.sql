use cxdb;

select *
from
	(
		select 
			ProjectName, 
			es.servername,
			LOC,
			datediff( minute, sr.EngineStartedOn, getDate() ) as 'Current Scan Minutes',
			sr.enginestartedon,	
			cast( datediff( minute, sr.EngineStartedOn, getDate() ) / (loc/10000.0) as decimal(10,1) ) as ScanMinPer10kLOC
		from 
			scanrequests sr
		left join 
			engineservers es on es.id = sr.serverid
		where sr.stage = 4
	) as data
where 
	data.[Current Scan Minutes] > 20 and
	data.ScanMinPer10kLOC > 500

/*
select 
	ProjectName, sr.serverid, datediff( minute, sr.CreatedOn, getDate() ) as 'Queue Minutes',
	sr.SourceLocationPath,
	LOC,
	cast( datediff( minute, sr.CreatedOn, getDate() ) / (loc/10000.0) as decimal(10,1) ) as QueueMinPer10kLOC
from 
	scanrequests sr
where sr.stage < 4
order by 6 desc;

*/