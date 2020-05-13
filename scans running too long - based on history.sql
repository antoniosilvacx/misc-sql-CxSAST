use cxdb;

select 
	sr.id, sr.createdon, sr.projectid, sr.enginestartedon, sr.loc, isincremental,
	(select sum(tse.LOC) from taskscans ts left join TaskScanEnvironment tse on tse.scanid = ts.id where ts.projectid = sr.projectid and ts.enginestartedon > dateadd( month, -6, getdate()) and not ts.enginefinishedon is null and ts.is_Incremental = sr.IsIncremental) as 'hLOC',
	(select sum(datediff( minute, ts.enginestartedon, ts.enginefinishedon)) from taskscans ts left join TaskScanEnvironment tse on tse.scanid = ts.id where ts.projectid = sr.projectid and ts.enginestartedon > dateadd( month, -6, getdate()) and not ts.enginefinishedon is null and ts.is_Incremental = sr.IsIncremental) as 'hMin',
	es.servername, sr.taskid, sr.sourceid 
into
	#TempQueueTiming
from
	( select distinct id, taskid, serverid, projectid, EngineStartedOn, loc, IsIncremental, createdon, sourceid from scanrequests ) as sr
left join engineservers es on es.id = sr.serverid;

select
	*,
	case
		when isnull(loc,0) = 0 then 'Source pulling'
		when [enginestartedon] is null then 'Queued'
		when [estimated end] is null then 'No previous scans'
		when [Estimated end] < getdate() then concat( datediff( minute, [estimated end], getdate() ), ' minutes overdue' )
		else concat( 'Due in ', datediff( minute, getdate(), [estimated end] ), ' minutes' )
	end as 'Status',
	case
		when not( enginestartedon is null or [Estimated end] is null ) and datediff( minute, enginestartedon, [estimated end] ) > 0 then
			cast( (100.0 * cast( datediff(minute, enginestartedon, getdate()) as float ) / ( cast( datediff( minute, enginestartedon, [estimated end] ) as float) )) as int )
		else null
	end as 'Percent'
from
	(
	select 
		sr.id, sr.createdon, p.name, sr.loc, sr.enginestartedon, 
		case 
			when sr.enginestartedon is null or sr.hLOC is null or sr.loc is null or sr.hmin is null or sr.hloc = 0 then null
			else dateadd( minute, sr.loc * cast( sr.hMin as float) / cast( sr.hLOC as float), sr.enginestartedon )
		end as 'Estimated end'
	from #TempQueueTiming sr
	left join projects p on p.id = sr.projectid ) as d
order by 8 desc;

drop table #TempQueueTiming;
