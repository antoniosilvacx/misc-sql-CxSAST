use cxdb;

select p.id, p.name, ts.enginefinishedon, qv.Severity, rs.name as audit, count(*) as count
into #TempAuditSummaryTable
from projects p
left join taskscans ts on ts.projectid = p.id and ts.id = (select top 1 id from taskscans where taskscans.projectid = p.id and not taskscans.enginefinishedon is null order by id desc)
left join PathResults pr on pr.resultid = ts.resultid 
left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
left join resultslabels rl on rl.projectid = ts.projectid and rl.SimilarityId = pr.Similarity_Hash and rl.NumericData is null
left join resultstate rs on rs.id = rl.labeltype and rs.LanguageId = 1033
where 
	p.id = 185
	and p.is_deprecated = 0
	and not ts.enginestartedon is null
	and ts.enginestartedon > dateadd( week, -1, getdate())
group by p.id, p.name, ts.enginefinishedon, qv.severity, rs.name;

select 
	d.id, d.name, d.[Last Scan], 
	case 
		when d.[Audited High] is null and d.[Unaudited High] is null then 100
		else cast( 100.0 * isnull(d.[Audited High],0)/( isnull(d.[audited high], 0) + isnull(d.[unaudited high],0)) as int ) 
	end as 'Audit % (High)',
	case 
		when d.[Audited Medium] is null and d.[Unaudited Medium] is null then 100
		else cast( 100.0 * isnull(d.[Audited Medium],0)/( isnull(d.[Audited Medium],0) + isnull(d.[Unaudited Medium],0)) as int ) 
	end as 'Audit % (Medium)',
	isnull(d.[Unaudited High],0) as [Unaudited High], isnull(d.[Audited High],0) as [Audited High], isnull( d.[Unaudited Medium],0) as [Unaudited Medium], isnull( d.[Audited medium],0) as [Audited medium], isnull( d.[Unaudited Low],0) as [Unaudited Low], isnull( d.[Audited Low],0) as [Audited Low], isnull( d.[Unaudited Info],0) as [Unaudited Info], isnull( d.[Audited Info],0) as [Audited Info]

from
	(
		select distinct p.id, p.name, p.enginefinishedon as 'Last Scan',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 3 and t1.audit is null) as 'Unaudited High',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 3 and not t1.audit is null) as 'Audited High',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 2 and t1.audit is null) as 'Unaudited Medium',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 2 and not t1.audit is null) as 'Audited Medium',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 1 and t1.audit is null) as 'Unaudited Low',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 1 and not t1.audit is null) as 'Audited Low',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 0 and t1.audit is null) as 'Unaudited Info',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 0 and not t1.audit is null) as 'Audited Info'
		from #TempAuditSummaryTable p
	) as d
order by 1 asc


drop table #TempAuditSummaryTable;