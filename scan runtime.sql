use cxdb;
select 
	data.name as Project, 
	case 
		when data.avgfulltimeMin is null then
			'Never run'
		else 
			case
				when data.avgfulltimeMin < 120 THEN
					concat(data.avgfulltimeMin, ' minutes')
				when data.avgfulltimeMin < 24*60 THEN
					concat( str(cast(data.avgfulltimeMin as numeric(10,4))/60, 3, 2), ' hours')
				else 
					concat( str(cast(data.avgfulltimeMin as numeric(10,4))/(24*60), 3, 2), ' days')
			end
	end as 'Avg time (Full scan)',
	case 
		when data.avginctimeMin is null then
			'Never run'
		else
			case
				when data.avginctimeMin < 120 THEN
					concat(data.avginctimeMin, ' minutes')
				when data.avginctimeMin < 24*60 THEN 
					concat( str(cast(data.avginctimeMin as numeric(10,4))/60, 3, 2), ' hours')
				else 
					concat( str(cast(data.avginctimeMin as numeric(10,4))/(24*60), 3, 2), ' days')
			end
	end as 'Avg time (Incremental)'							
from (
		select p.name, 
              (
                      select AVG(time) 
                      from (
                             select top 5
                                    datediff( minute, EngineStartedOn, EngineFinishedOn ) as time
                             from taskscans ts
                             where ts.is_Incremental = 0 and ts.projectid = p.id
                             order by EngineFinishedOn desc
                      ) as avgtime
              ) as avgfulltimeMin,
			  
              (
                      select AVG(time) 
                      from (
                             select top 5
                                    datediff( minute, EngineStartedOn, EngineFinishedOn ) as time
                             from taskscans ts
                             where ts.is_Incremental = 1 and ts.projectid = p.id
                             order by EngineFinishedOn desc
                      ) as avgtime
              ) as avginctimeMin
		from dbo.projects p
		where p.id in (13075,17284,18641,25313,25314,27232,29162,29197,29537,29557,31954,32550,32948,34300,34307,34312,34359,34391,35042,38671,41072)  
	) as data
order by Project asc