use cxdb;

declare @preset1 int = 100141;
declare @preset2 int = 100167; -- RPA

select name from presets where id in (@preset1, @preset2);

select 
	pd.presetid, pd.queryid
into #TempPresetComparison
from
	preset_details pd
where
	pd.presetid in (@preset1, @preset2);

select 
	qg.languagename, qg.name as groupname, q.name as queryname, q.queryid, 
	(select count(*) from #TempPresetComparison tpc2 where tpc2.queryid = tpc.queryid and tpc2.PresetId = @preset1) as 'preset1',
	(select count(*) from #TempPresetComparison tpc2 where tpc2.queryid = tpc.queryid and tpc2.PresetId = @preset2) as 'preset2'
into #TempPresetSummary
from
	(select distinct queryid from #TempPresetComparison) as tpc
left join
	query q on q.queryid = tpc.queryid
left join
	querygroup qg on qg.PackageId = q.PackageId
order by 1,2,3;

select * from #TempPresetSummary;

drop table #TempPresetSummary;
drop table #temppresetcomparison;





/*	select p.name, qg.languagename, qg.name, q.name  from preset_details pd 
	left join presets p on p.id = pd.PresetId
	left join query q on q.QueryId = pd.queryid
	left join querygroup qg on q.packageid = qg.packageid
	where pd.presetid = 100167

	*/