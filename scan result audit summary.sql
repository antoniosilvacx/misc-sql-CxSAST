use cxdb;

select p.id, p.name, ts.enginestartedon, qv.name, qv.Severity, rs.name, count(*) as count
from projects p
left join taskscans ts on ts.projectid = p.id and ts.id = (select top 1 id from taskscans where taskscans.projectid = p.id and not taskscans.enginefinishedon is null order by id desc)
left join PathResults pr on pr.resultid = ts.resultid 
left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
left join resultslabels rl on rl.projectid = ts.projectid and rl.SimilarityId = pr.Similarity_Hash and rl.NumericData is null
left join resultstate rs on rs.id = rl.labeltype and rs.LanguageId = 1033
where not ts.enginestartedon is null
and ts.enginestartedon > dateadd( week, -1, getdate())
group by p.id, p.name, ts.enginestartedon, qv.name, qv.severity, rs.name
order by 1, 2 desc, 3 asc;

