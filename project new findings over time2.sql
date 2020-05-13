use cxdb;
declare @projid int;
declare @startdate datetime;
set @projid = 54838;
set @startDate = '2019-11-01';

select ts.projectid, ts.id, ts.enginestartedon, ts.enginefinishedon, tse.loc, tse.failedloc, ts.high, ts.medium, ts.low, ts.Information,
	(select count(*) from PathResults pr inner join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode where pr.resultid = ts.resultid
	and not exists( select * from pathresults pr2 left join taskscans ts2 on ts2.resultid = pr2.resultid where pr2.Similarity_Hash = pr.Similarity_Hash and pr2.resultid < pr.resultid and ts2.projectid = ts.projectid )) as 'New'
from 	taskscans  ts
left join TaskScanEnvironment tse on tse.scanid = ts.id
where
	ts.projectid = @projid
and ts.enginefinishedon >= @startDate;

