use cxdb;

declare @scanid int;
set @scanid = 5436315;

select qv.Severity, qv.name, pr.similarity_hash
from PathResults pr 
inner join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
--left join resultslabels rl on rl.projectid = 42624 and rl.SimilarityId = pr.Similarity_Hash and rl.NumericData is null and rl.resultid = pr.resultid
--left join resultstate rs on rs.id = rl.labeltype and rs.LanguageId = 1033
where pr.resultid = (select resultid from taskscans where id = @scanid)
--and not exists( select * from pathresults pr2 left join taskscans ts on ts.resultid = pr2.resultid where pr2.Similarity_Hash = pr.Similarity_Hash and pr2.resultid < pr.resultid and ts.projectid = (select projectid from taskscans where id = @scanid) )
--and qv.severity = 1

--group by p.id, p.name, p.Owning_team, ts.enginestartedon, qv.name, qv.severity, rs.name
order by 1 desc, 2 asc;

