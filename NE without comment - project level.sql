use cxdb;

IF OBJECT_ID(N'tempdb..#tempNEFindings') IS NOT NULL
BEGIN
DROP TABLE #tempNEFindings
END
GO

declare @RootPath varchar(256);
select @RootPath = [value] from CxComponentConfiguration where [key] = 'WebServer';

select ProjectId, ResultId, PathID, SimilarityId, rlh.DateCreated, rlh.Data 
into #tempNEFindings
from resultslabels rl with (nolock) 
left join ResultsLabelsHistory rlh with (nolock) on 
	rlh.id = rl.id 
	and rlh.datecreated >= dateadd( hour, -1, rl.UpdateDate )
	and not rlh.data like 'Changed status to %'
where rl.stringdata = 'Changed status to Not Exploitable';

select 
	tnef.ProjectId, tnef.ResultId, ts.starttime as 'Scan Time', 
	concat( qg.PackageTypeName, ' -> ', qg.LanguageName, ' -> ', q.Name ) as 'Query', q.Severity, 
	--tnef.DateCreated as 'Audit Time', tnef.Data as 'Audit Comment',
	concat( @RootPath, '/CxWebClient/ViewerMain.aspx?scanid=', tnef.resultid, '&projectid=', tnef.projectid, '&pathid=', tnef.pathid ) as 'URL'
from #tempNEFindings tnef
inner join TaskScans ts with (nolock) on ts.ResultId = tnef.ResultId
left join pathresults pr with (nolock) on pr.resultid = tnef.resultid and pr.Similarity_Hash = tnef.SimilarityId
left join queryversion qv with (nolock) on qv.queryversioncode = pr.QueryVersionCode
left join query q with (nolock) on q.queryid = qv.queryid 
left join querygroup qg with (nolock) on qg.PackageId = q.PackageId
where tnef.DateCreated is null


