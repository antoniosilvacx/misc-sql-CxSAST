
	select 
		concat( min, '-', max, ' LOC' ) as LOC,
		(select count(*) from scanrequests sr where sr.stage = 4 and sr.loc between min and max) as 'Running Scans',
		(select count(*) from scanrequests sr where sr.stage < 4 and sr.loc between min and max) as 'Queued Scans',
		(select sum(max_scans) from EngineServers where (min+max)/2 between scanminloc and scanmaxloc and isalive = 1) as 'Suitable Engines',
		(select count(sr.id) from scanrequests sr left join EngineServers es on sr.ServerID=es.Id
		where sr.loc between scanminloc and scanmaxloc and sr.loc between min and max and isalive = 1 and sr.stage = 4) as 'Engine Utilization'
	from
		(values(0,20000),(20000,50000),(50000,100000),(100000,1000000),(1000000,2000000),(2000000,4000000),(4000000,10000000),(10000000,999999999)) as ranges(min,max)
