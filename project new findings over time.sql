declare @projid int;
declare @startdate datetime;
set @projid = 54838
;
set @startDate = '2019-11-01';

select ts.id, ts.enginefinishedon, qv.Severity, 
	--qv.name, 
	count(*) as 'New'
from 	taskscans ts
left join PathResults pr on pr.resultid = ts.resultid
inner join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
where not exists( select * from pathresults pr2 left join taskscans ts on ts.resultid = pr2.resultid where pr2.Similarity_Hash = pr.Similarity_Hash and pr2.resultid < pr.resultid and ts.projectid = @projid )
and ts.projectid = @projid
and enginestartedon >= @startdate
--and qv.severity = 3

group by ts.id, ts.enginefinishedon, qv.Severity --, qv.name
order by 1 asc, 2 asc, 3 desc, 4 asc
