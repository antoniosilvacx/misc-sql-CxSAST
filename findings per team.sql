use cxdb;

select d.TeamId, d.FullName, d.ProjectID, d.ProjectID, ts.High, ts.Medium, ts.Low, ts.Information	
from (
	select 
		t.TeamId, t.FullName, p.id as ProjectID, p.name as ProjectName,
		(select top 1 id from taskscans ts with (nolock) where ts.projectid = p.id) as lastScanId
	from 
		teams t with (nolock)
	left join 
		projects p with (nolock) on p.owning_team = t.teamid
	) as d
left join taskscans ts with (nolock) on ts.id = lastScanId;

select d.TeamId, d.FullName, sum(ts.High) as 'High', sum(ts.Medium) as 'Medium', sum(ts.Low) as 'Low', sum(ts.Information) as 'Info'
from (
	select 
		t.TeamId, t.FullName, p.id as ProjectID, p.name as ProjectName,
		(select top 1 id from taskscans ts with (nolock) where ts.projectid = p.id) as lastScanId
	from 
		teams t with (nolock)
	left join 
		projects p with (nolock) on p.owning_team = t.teamid
	) as d
left join taskscans ts with (nolock) on ts.id = lastScanId
group by d.TeamId, d.FullName