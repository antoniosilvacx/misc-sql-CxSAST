select
	qg.languagename, qg.name, qv.name, rs.name, count(*) as count
from
	(
		select
			rl.resultid, rl.pathid, max(updatedate) updatedate
		from
			resultslabels rl
		left join
			resultstate on resultstate.id = rl.LabelType and resultstate.LanguageId = 1033
		where
			updatedate > dateadd( month, -6, getdate())
		group by
			rl.resultid, rl.pathid
	) as lastupdate
left join
	resultslabels rl on rl.resultid = lastupdate.resultid and rl.pathid = lastupdate.pathid and rl.updatedate = lastupdate.updatedate
left join 
	resultstate rs on rs.id = rl.labeltype and rs.languageid = 1033
left join
	pathresults pr on pr.Path_Id = rl.PathID and pr.ResultId = rl.ResultId
left join 
	queryversion qv on qv.QueryVersionCode = pr.QueryVersionCode
left join 
	querygroup qg on qg.PackageId = qv.PackageId
group by
	qg.languagename, qg.name, qv.name, rs.name
order by
	qg.languagename, qg.name, qv.name, rs.name