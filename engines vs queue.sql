use cxdb;

select id, ServerName, [LOC Range], Utilization as 'Running/MAX scans',  concat(cast( 100.0*[utilpct] as Decimal(10,1) ), '%') as 'Utilization', Queued, 
	case
		when data.LastScanStarted > 0 then concat(LastScanStarted, ' min ago') 
		else 'No active scans'
	end as LastScanStarted, 
	case
		when not data.LastScanFinished is null then concat(LastScanFinished, ' min ago') 
		else 'No previous scans'
	end as LastScanFinished, Hostname
from (
		select 
			es.id, es.ServerName, 
			concat( es.scanminloc, ' - ', es.scanmaxloc ) as 'LOC Range', 
			case 
				when queue.count > 0 then concat( queue.count, '/', es.max_scans ) 
				else concat( 0, '/', es.max_scans ) 
			end as 'Utilization', 
			
			case 
				when queue.count > 0 then cast(queue.count as decimal(10,4))/cast( es.max_scans as decimal(10,4)) 
				else 0
			end as 'utilpct',

			(select count(*) from scanrequests sr where stage < 4 and loc between es.scanminloc and es.scanmaxloc) as 'Queued',
			datediff(minute, (select max(sr.EngineStartedOn) from ScanRequests sr where stage >= 4 and sr.ServerID = queue.serverid), getDate()) as 'LastScanStarted',
			datediff(minute, (select max(ts.EngineFinishedOn) from taskscans ts where ts.ServerID = es.id and ts.EngineFinishedOn is not null), getDate()) as 'LastScanFinished',
			substring(serveruri, 8, len(serveruri) - 57) as 'Hostname'
		from
			engineservers es 
		left join
			(
				select serverid, count(*) as 'count' from scanrequests
				where stage <= 4
				group by serverid
			) as queue on es.id = queue.serverid
		where 
			es.isblocked = 0
		) as data
--where queued > 0 and utilpct < 1
order by 2;--data.LastScanFinished desc