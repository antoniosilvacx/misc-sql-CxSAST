use cxdb;
SELECT c.projectid, D.[Name] AS ProjectName, C.EngineFinishedOn, C.LOC, C.High, C.Medium, C.Low, C.Info
       from CxEntities.Scan C
       left join CxEntities.Project D ON C.ProjectId = D.Id 
where
       C.id in 
		(
			select 
				max(ts.id) as scanid 
			from 
				taskscans as ts 
		 where 
				ts.projectid not in (1)
					--(13075,17284,18641,25313,25314,27232,29162,29197,29537,29557,31954,32550,32948,34300,34307,34312,34359,34391,35042,38671,41072)  
					--(34307)
				--and ts.is_Incremental = 0
			group by 
				ts.projectid  
		)

--		and qg.LanguageName = 'Typescript'
order by 
	d.name