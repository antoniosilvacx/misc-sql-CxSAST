use cxdb;

IF OBJECT_ID (N'ufn_GetScansBetween', N'IF') IS NOT NULL  
    DROP FUNCTION ufn_GetScansBetween;  
GO  
CREATE FUNCTION ufn_GetScansBetween (@startDate DATETIME,	@endDate DATETIME)  
RETURNS TABLE  
AS  
RETURN   
(  
	select 
		ts.serverid, ts.projectid, tse.loc,
		case
			when ts.EngineStartedOn < @startDate then	
				@startDate
			else
				ts.EngineStartedOn
		end as EngineStart,
		case
			when ts.EngineFinishedOn > @endDate then	
				@endDate
			else
				ts.EngineFinishedOn
		end as EngineEnd,
		'Finished' as State
	from
		taskscans ts
	left join
		TaskScanEnvironment tse on ts.id = tse.scanid
	where 
		ts.enginefinishedon is not null 
	and
		(
			ts.EngineStartedOn between @startDate and @endDate
		or
			ts.EngineFinishedOn between @startDate and @endDate 
		)
	
	union 

	select 
		sr.serverid, sr.projectid, sr.loc,
		case
			when sr.EngineStartedOn < @startDate then	
				@startDate
			else
				sr.EngineStartedOn
		end as EngineStart,
		case
			when sr.enginefinishedon is null then
				getDate()
			when sr.EngineFinishedOn > @endDate then	
				@endDate
			else
				sr.EngineFinishedOn
		end as EngineEnd,
		case
			when sr.stage = 4 then
				'Scanning'
			else
				'Clean-up'
		end as State
	from
		scanrequests sr
	where
		sr.stage >= 4 and
		sr.ServerID <> 0
);

