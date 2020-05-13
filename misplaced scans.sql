select sr.id, sr.projectname, sr.loc, es.servername, es.scanminloc, es.scanmaxloc 
from scanrequests sr left join engineservers es on es.id = sr.serverid 
where sr.stage = 4 and sr.loc between 0 and 20000
and not( sr.loc between scanminloc and scanmaxloc)
order by id;

select name, avg(loc) as AvgLOC, count(*) as Count from
(
	select
		p.name, tse.loc, es.ServerName, concat(es.scanminloc, '-', es.scanmaxloc) as ServerLOCRange
	from taskscans ts
	left join TaskScanEnvironment tse on tse.ScanId=ts.id
	left join projects p on p.id = ts.ProjectId
	left join EngineServers es on es.id = ts.ServerID
	where 
		ts.enginestartedon >= dateadd( day, -1, getdate())
		and not(tse.loc between es.scanminloc and es.scanmaxloc)
) as data 
group by name
order by 3 desc;


select servername,serverlocrange, avg(loc) as AvgLOC, count(*) as Count from
(
	select
		p.name, tse.loc, es.ServerName, concat(es.scanminloc, '-', es.scanmaxloc) as ServerLOCRange
	from taskscans ts
	left join TaskScanEnvironment tse on tse.ScanId=ts.id
	left join projects p on p.id = ts.ProjectId
	left join EngineServers es on es.id = ts.ServerID
	where 
		ts.enginestartedon >= dateadd( day, -1, getdate())
		and not(tse.loc between es.scanminloc and es.scanmaxloc)
) as data 
group by servername,serverlocrange
order by 4 desc;