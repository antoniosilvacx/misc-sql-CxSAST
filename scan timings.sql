use cxdb;

declare @projID as integer = 67457;

select 
	is_incremental, cast( avg(scanMinutes)/60.0 as decimal(10,1) ) 'avgHours', avg(loc) as 'avgLOC'
from
	(
		select top 5 is_incremental, datediff( minute, enginestartedon, enginefinishedon ) as scanMinutes, loc
		from taskscans
		left join TaskScanEnvironment on scanid = taskscans.id
		where projectid = @projID and
		not enginefinishedon is null and
		is_incremental = 0
		order by enginestartedon desc
		union 
		select top 5 is_incremental, datediff( minute, enginestartedon, enginefinishedon ) as scanMinutes, loc
		from taskscans
		left join TaskScanEnvironment on scanid = taskscans.id
		where projectid = @projID and
		not enginefinishedon is null and
		is_incremental = 1
		order by enginestartedon desc
	) as d
group by is_incremental