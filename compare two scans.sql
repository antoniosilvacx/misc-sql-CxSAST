use cxdb;

declare @projectID int;



declare @scan1 int;
declare @scan2 int;

set @scan1 = 1000072;
set @scan2 = 1000073;

select Query, 
	case 
		when Severity = 0 then 'Info'
		when severity = 1 then 'Low'
		when severity = 2 then 'Medium'
		when severity = 3 then 'High'
	end as Severity
, sum(count1) as 'Zeineb', sum(count2) as 'BKimminich'
from

(	SELECT a.severity, ss.name as Query, count(a.id) as Count1, 0 as Count2
		   FROM CxEntities.Result A
		   left join CxEntities.ResultState B ON A.State = B.Id
		   left join CxEntities.Scan C ON A.scanId = C.Id
		   left join CxEntities.Project D ON C.ProjectId = D.Id 
		   left join QueryVersion ss on ss.queryversioncode = a.QueryVersionId
		   left join QueryGroup qg on qg.PackageId = ss.PackageId
	where
		   A.scanid = @scan1
	group by 
		D.[Name], c.projectid, A.ScanId, B.Name, a.severity, ss.QueryId, ss.name, qg.name
union
	SELECT a.severity, ss.name as Query, 0 as Count1, count(a.id) as Count2
		   FROM CxEntities.Result A
		   left join CxEntities.ResultState B ON A.State = B.Id
		   left join CxEntities.Scan C ON A.scanId = C.Id
		   left join CxEntities.Project D ON C.ProjectId = D.Id 
		   left join QueryVersion ss on ss.queryversioncode = a.QueryVersionId
		   left join QueryGroup qg on qg.PackageId = ss.PackageId
	where
		   A.scanid = @scan2
	group by 
		D.[Name], c.projectid, A.ScanId, B.Name, a.severity, ss.QueryId, ss.name, qg.name ) as data
group by
	severity, query
order by 
	data.severity desc, query asc