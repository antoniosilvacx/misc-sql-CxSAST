use cxdb;
select es.ServerName, concat( es.scanminloc, ' - ', es.scanmaxloc ) as 'LOC Range',
	lastmonth.LOC, lastmonth.scanminutes, lastmonth.scanminutes/(lastmonth.LOC/10000.0) as MinPer10kLOC
from 
	(
		select 
			ts.serverid, sum(tse.LOC) as LOC, sum(datediff( minute, ts.EngineStartedOn, ts.EngineFinishedOn )) as scanminutes
		from
			taskscans ts
		left join	
			TaskScanEnvironment tse on tse.ScanId = ts.Id
		where
			ts.engineStartedOn > dateadd( month, -1, getdate() )
		group by 
			ts.serverid
	) as lastmonth
left join
	engineservers es on es.id = lastmonth.ServerID
where
	es.isalive = 1
order by 
	1 asc, 5 desc
;