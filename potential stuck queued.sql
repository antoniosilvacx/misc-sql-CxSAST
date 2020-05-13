use cxdb;


select *
from (
	select 
		ProjectName, es.ServerName, datediff( minute, sr.CreatedOn, getDate() ) as 'Queue Minutes',
		sr.SourceLocationPath,
		LOC,
		cast( datediff( minute, sr.CreatedOn, getDate() ) / (loc/10000.0) as decimal(10,1) ) as QueueMinPer10kLOC
	from 
		scanrequests sr
	left join
		engineservers es on es.id = sr.ServerID
	where sr.stage < 4
) as data
where
	( data.[Queue Minutes] > 20 and LOC is null ) or
	( data.[Queue Minutes] > 20 and data.QueueMinPer10kLOC > 500 )