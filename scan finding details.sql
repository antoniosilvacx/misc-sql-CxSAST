use cxdb;
SELECT D.[Name] AS ProjectName, c.projectid, A.ScanId, B.Name as ResultState, a.severity, ss.name as Query, qg.Name as Language, count(a.id) as Count
       FROM CxEntities.Result A
       left join CxEntities.ResultState B ON A.State = B.Id
       left join CxEntities.Scan C ON A.scanId = C.Id
       left join CxEntities.Project D ON C.ProjectId = D.Id 
       left join QueryVersion ss on ss.queryversioncode = a.QueryVersionId
	   left join QueryGroup qg on qg.PackageId = ss.PackageId
where
       A.scanid in 
		(
			select 
				max(ts.id) as scanid 
			from 
				taskscans as ts 
		 where 
				ts.projectid in (14,17)
					--(13075,17284,18641,25313,25314,27232,29162,29197,29537,29557,31954,32550,32948,34300,34307,34312,34359,34391,35042,38671,41072)  
					--(34307)
				--and ts.is_Incremental = 0
			group by 
				ts.projectid  
		)

--		and qg.LanguageName = 'Typescript'
group by 
	D.[Name], c.projectid, A.ScanId, B.Name, a.severity, ss.name, qg.name
order by 
	d.name, b.name, a.severity desc, ss.name asc