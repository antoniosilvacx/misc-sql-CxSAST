use cxdb;
select
	LOC, concat(Running, '/', Capacity) as 'Engines Used', Queued as 'Scans Queued', [RecentStarted], [RecentFinished]
from (
	select
		concat( min, '-', max, ' LOC' ) as LOC,
		(select count(*) from scanrequests sr where sr.loc between min and max and sr.stage = 4 ) as 'Running',
		(select sum(max_scans) as capacity
			from
				(select 
					es.scanminloc, es.scanmaxloc, es.max_scans,
					(select count(*) from scanrequests sr where sr.ServerID=es.id and sr.stage = 4) as running
				from 
					engineservers es
				where
					es.IsAlive = 1) as es 
		where
			(min+max)/2 between scanminloc and scanmaxloc) as 'Capacity',
		(select count(*) from scanrequests sr where sr.loc between min and max and sr.stage < 4 ) as 'Queued',
		(select max(sr.EngineStartedOn) from scanrequests sr where sr.loc between min and max and sr.stage = 4) 'RecentStarted',
		(select max(ts.FinishTime) from taskscans ts left join TaskScanEnvironment tse on tse.scanid = ts.id where tse.loc between min and max) 'RecentFinished'
	from
		(values(0,20000),(20000,50000),(50000,100000),(100000,1000000),(1000000,2000000),(2000000,4000000),(4000000,10000000),(10000000,999999999) ) as ranges(min,max)
	) as data