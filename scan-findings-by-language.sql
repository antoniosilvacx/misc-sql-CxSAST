use cxdb;

select 
	p.name, ts.ProjectId, ts.id, tse.loc, tse.failedloc, datediff( second, ts.enginestartedon, ts.enginefinishedon ) as 'scan seconds',
	(select count(*) from pathresults pr left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode left join querygroup qg on qg.packageid=qv.packageid where pr.resultid = ts.resultid and qg.languagename ='JavaScript') as 'JavaScript findings',
	(select count(*) from pathresults pr left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode left join querygroup qg on qg.packageid=qv.packageid where pr.resultid = ts.resultid and qg.languagename ='Typescript') as 'Typescript findings',
	(select count(*) from pathresults pr left join queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode left join querygroup qg on qg.packageid=qv.packageid where pr.resultid = ts.resultid and not qg.languagename in ('JavaScript','Typescript')) as 'Other findings',
	(select count(*) from ResultsLabels rl where rl.resultid = ts.resultid and ((LabelType = 3 and NumericData = 1) or (LabelType=2 and NumericData = 1))) as 'Recent FP',
	(select count(*) from ResultsLabels rl where rl.projectid = ts.projectid and ((LabelType = 3 and NumericData = 1) or (LabelType=2 and NumericData = 1))) as 'Total FP'
from
	taskscans ts with(nolock) 
left join
	TaskScanEnvironment tse with(nolock) on tse.scanid = ts.id
left join
	projects p on p.id = ts.projectid
where
	ts.id in (4141551,4141548,4141550,4141545,4141541,3801909,4141478,4141483,4141484,4141491,4141492,4439929,4141495,4141501,4141553,4141487,4141540,4141903,4534235,4555181,4555195,3806776,4542138,4554912,4141906)
order by
	projectid, scanid