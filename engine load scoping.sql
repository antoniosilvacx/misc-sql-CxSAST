/*

	Want better data to estimate the engine usage and appropriate provisioning.
	To support these decisions, need the following data:
		- For each LOC range, the average duration of a scan (per LOC)
		- For each LOC range, the number of scans that have been submitted in the last X period
		- For each LOC range, the total number of LOC that were scanned in the last X period
		- Time (per engine?) per LOC?

*/
use cxdb;
/* avg min/10k loc for each LOC range */
select 

	concat( min, '-', max) as LOC,
	(
		select 
			count(*) 
		from 
			TaskScans ts
		left join
			TaskScanEnvironment tse on tse.ScanId = ts.id
		where 
			tse.loc between min and max
		and
			ts.EngineStartedOn >= dateadd( month, -1, getdate())
	) as ScanCount,
	cast( (
		select 
			avg( datediff( minute, ts.EngineStartedOn, ts.EngineFinishedOn )/ (tse.LOC / 10000.0) ) as avgTPL
		from 
			TaskScans ts
		left join
			TaskScanEnvironment tse on tse.ScanId = ts.id
		where 
			tse.loc between min and max
		and
			tse.loc  > 0
		and
			ts.EngineStartedOn >= dateadd( month, -1, getdate())
	) as Decimal(10,1)) as MinPer10kLOC
from
	(values(0,20000),(20000,50000),(50000,100000),(100000,1000000),(1000000,2000000),(2000000,4000000),(4000000,10000000),(10000000,999999999) ) as ranges(min,max)
