use cxdb;

declare @resultid1 int;
declare @resultid2 int;
set @resultid1 = 5155241;
set @resultid2 = 5183998;--5494459;



--select * from pathresults where resultid = @resultid1 order by Similarity_Hash asc;
--select * from pathresults where resultid = @resultid2 order by Similarity_Hash asc;


select qv.Severity, qv.name
from PathResults pr 
inner join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
--left join resultslabels rl on rl.projectid = 42624 and rl.SimilarityId = pr.Similarity_Hash and rl.NumericData is null and rl.resultid = pr.resultid
--left join resultstate rs on rs.id = rl.labeltype and rs.LanguageId = 1033
where pr.resultid = @resultid2
and not exists( select * from pathresults pr2 where pr2.Similarity_Hash = pr.Similarity_Hash and pr2.resultid = @resultid1 )
--and qv.severity = 3

--group by p.id, p.name, p.Owning_team, ts.enginestartedon, qv.name, qv.severity, rs.name
order by 1 desc, 2 asc;

