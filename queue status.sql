use cxdb;
select
	concat( min, '-', max, ' LOC' ) as LOC,
	(select count(*) from scanrequests sr where sr.loc between min and max and sr.stage = 4 ) as 'Running',
	(select count(*) from scanrequests sr where sr.loc between min and max and sr.stage < 4 ) as 'Queued',
	(select sum(max_scans - running) as capacity
		from
			(select 
				es.scanminloc, es.scanmaxloc, es.max_scans,
				(select count(*) from scanrequests sr where sr.ServerID=es.id and sr.stage = 4) as running
			from 
				engineservers es
			where
				es.IsAlive = 1) as es 
	where
		(min+max)/2 between scanminloc and scanmaxloc) as 'Spare Capacity',
	(select
		case when oldest is null then
			'None'
		when oldest < 120 then
			concat( oldest, ' minutes' )
		when oldest < 24*60 then
			concat( cast( (oldest/60.0) as decimal(10,1) ), ' hours' )
		else
			concat( cast( (oldest/(60*24.0)) as decimal(10,1) ), ' days' )
		end 
	from 
		(select datediff( minute, min(sr.CreatedOn), getdate() ) as oldest from scanrequests sr where sr.loc between min and max and sr.stage = 4 ) as data
	) as 'Oldest Running',
	(select
		case when youngest is null then
			'None'
		when youngest < 120 then
			concat( youngest, ' minutes' )
		when youngest < 24*60 then
			concat( cast( (youngest/60.0) as decimal(10,1) ), ' hours' )
		else
			concat( cast( (youngest/(60*24.0)) as decimal(10,1) ), ' days' )
		end 
	from 
		(select datediff( minute, max(sr.CreatedOn), getdate() ) as youngest from scanrequests sr where sr.loc between min and max and sr.stage = 4 ) as data
	) as 'Youngest Running',
	(select
		case when oldest is null then
			'None'
		when oldest < 120 then
			concat( oldest, ' minutes' )
		when oldest < 24*60 then
			concat( cast( (oldest/60.0) as decimal(10,1) ), ' hours' )
		else
			concat( cast( (oldest/(60*24.0)) as decimal(10,1) ), ' days' )
		end 
	from 
		(select datediff( minute, min(sr.CreatedOn), getdate() ) as oldest from scanrequests sr where sr.loc between min and max and sr.stage < 4 ) as data
	) as 'Oldest Queued',
	(select
		case when youngest is null then
			'None'
		when youngest < 120 then
			concat( youngest, ' minutes' )
		when youngest < 24*60 then
			concat( cast( (youngest/60.0) as decimal(10,1) ), ' hours' )
		else
			concat( cast( (youngest/(60*24.0)) as decimal(10,1) ), ' days' )
		end 
	from 
		(select datediff( minute, max(sr.CreatedOn), getdate() ) as youngest from scanrequests sr where sr.loc between min and max and sr.stage < 4 ) as data
	) as 'Youngest Queued'
from
	(values(0,50000),(50000,1000000),(1000000,4000000),(4000000,999999999) ) as ranges(min,max)
