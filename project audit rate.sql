use cxdb;

select p.owning_team, p.id, p.name, ts.enginefinishedon, qv.Severity, rs.name as audit, count(*) as count
into #TempAuditSummaryTable
from projects p
left join taskscans ts on ts.projectid = p.id and ts.id = (select top 1 id from taskscans where taskscans.projectid = p.id and not taskscans.enginefinishedon is null order by id desc)
left join PathResults pr on pr.resultid = ts.resultid 
left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
left join resultslabels rl on rl.projectid = ts.projectid and rl.SimilarityId = pr.Similarity_Hash and rl.NumericData is null
left join resultstate rs on rs.id = rl.labeltype and rs.LanguageId = 1033
where 
	p.is_deprecated = 0
	and not ts.enginestartedon is null
--	and ts.enginestartedon > dateadd( week, -1, getdate())
group by p.owning_team, p.id, p.name, ts.enginefinishedon, qv.severity, rs.name;

select 
	d.owning_team, d.id as ProjectID, d.name, d.[Last Scan], 
	isnull(d.[Unaudited High],0) as [Unaudited High], isnull(d.[Audited High],0) as [Audited High], isnull(d.[High FP],0) as [High FP], 
	case 
		when d.[Audited High] is null and d.[Unaudited High] is null then null
		else cast( 100.0 * isnull(d.[High FP],0)/( isnull(d.[Audited High],0) + isnull(d.[Unaudited High],0)) as int ) 
	end as 'FP % (High)',
	case 
		when d.[Audited High] is null and d.[Unaudited High] is null then null
		else cast( 100.0 * isnull(d.[Audited High],0)/( isnull(d.[audited high], 0) + isnull(d.[unaudited high],0)) as int ) 
	end as 'Audit % (High)',

	isnull( d.[Unaudited Medium],0) as [Unaudited Medium], isnull( d.[Audited medium],0) as [Audited medium], isnull(d.[Medium FP],0) as [Medium FP], 
	case 
		when d.[Audited Medium] is null and d.[Unaudited Medium] is null then null
		else cast( 100.0 * isnull(d.[Medium FP],0)/( isnull(d.[Audited Medium],0) + isnull(d.[Unaudited Medium],0)) as int ) 
	end as 'FP % (Medium)',
	case 
		when d.[Audited Medium] is null and d.[Unaudited Medium] is null then null
		else cast( 100.0 * isnull(d.[Audited Medium],0)/( isnull(d.[Audited Medium],0) + isnull(d.[Unaudited Medium],0)) as int ) 
	end as 'Audit % (Medium)',

	isnull( d.[Unaudited Low],0) as [Unaudited Low], isnull( d.[Audited Low],0) as [Audited Low], isnull(d.[Low FP],0) as [Low FP], 
	isnull( d.[Unaudited Info],0) as [Unaudited Info], isnull( d.[Audited Info],0) as [Audited Info], isnull(d.[Info FP],0) as [Info FP]
into
	#tempPerProjectAuditStatus
from
	(
		select distinct p.owning_team, p.id, p.name, p.enginefinishedon as 'Last Scan',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 3 and t1.audit is null) as 'Unaudited High',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 3 and not t1.audit is null) as 'Audited High',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 3 and t1.audit = 'Not Exploitable') as 'High FP',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 2 and t1.audit is null) as 'Unaudited Medium',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 2 and not t1.audit is null) as 'Audited Medium',			
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 2 and t1.audit = 'Not Exploitable') as 'Medium FP',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 1 and t1.audit is null) as 'Unaudited Low',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 1 and not t1.audit is null) as 'Audited Low',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 1 and t1.audit = 'Not Exploitable') as 'Low FP',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 0 and t1.audit is null) as 'Unaudited Info',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 0 and not t1.audit is null) as 'Audited Info',
			(select sum(count) from #TempAuditSummaryTable t1 where t1.id = p.id and t1.Severity = 0 and t1.audit = 'Not Exploitable') as 'Info FP'
		from #TempAuditSummaryTable p
	) as d


select * from #tempPerProjectAuditStatus order by 1 asc;

select 
	p.owning_team,
	sum([Unaudited High]) as 'Unaudited High', sum([Audited High]) as 'Audited High', sum([High FP]) as 'High FP', 
	sum([Unaudited Medium]) as 'Unaudited Medium', sum([Audited Medium]) as 'Audited Medium', sum([Medium FP]) as 'Medium FP', 
	sum([Unaudited Low]) as 'Unaudited Low', sum([Audited Low]) as 'Audited Low', sum([Low FP]) as 'Low FP', 
	sum([Unaudited Info]) as 'Unaudited Info', sum([Audited Info]) as 'Audited Info', sum([Info FP]) as 'Info FP'
into #tempPerTeamAuditStatus
from #tempPerProjectAuditStatus
left join projects p with (nolock) on p.id = projectId
group by p.Owning_Team;

select t.FullName, tptas.*, 
	case
		when tptas.[Unaudited High] + tptas.[Audited High] > 0 then cast( 100.0 * tptas.[High FP] / (tptas.[Unaudited High] + tptas.[Audited High])  as int)
		else null
	end as 'FP % (High)',
	case
		when tptas.[Unaudited Medium] + tptas.[Audited Medium] > 0 then cast( 100.0 * tptas.[Medium FP] / (tptas.[Unaudited Medium] + tptas.[Audited Medium])  as int)
		else null
	end as 'FP % (Medium)'

from #tempPerTeamAuditStatus tptas
left join teams t with (nolock) on t.teamid = tptas.Owning_Team;

drop table #TempAuditSummaryTable;
drop table #tempPerProjectAuditStatus;
drop table #tempPerTeamAuditStatus;