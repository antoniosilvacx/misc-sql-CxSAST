use cxdb;


IF OBJECT_ID (N'ufn_GetCompleteScansBetween', N'IF') IS NOT NULL  
    DROP FUNCTION ufn_GetCompleteScansBetween;  
GO  
CREATE FUNCTION ufn_GetCompleteScansBetween (@startDate DATETIME,	@endDate DATETIME)  
RETURNS TABLE  
AS  
RETURN   
(  
	select 
		ts.serverid, ts.projectid, tse.loc, ts.EngineStartedOn as EngineStart, ts.EngineFinishedOn as EngineEnd
	from
		taskscans ts
	left join
		TaskScanEnvironment tse on ts.id = tse.scanid
	where 
		ts.enginefinishedon is not null 
	and
		(
			ts.EngineStartedOn >= @startDate
		and
			ts.EngineFinishedOn <= @endDate 
		)
);