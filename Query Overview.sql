select qg.LanguageName, qg.Name as 'Group Name', q.name as 'Query Name', q.QueryId, qg.PackageTypeName as 'Scope', 
       case
             when qg.PackageType = 2 then (select name from projects where id = qg.project_id)
             when qg.PackageType = 3 then (select teamname from teams where teamid = owning_team)
             else '-'
       end as 'Owner', qv.QueryVersionCode, qv.UpdateTime
from query q
left join querygroup qg on qg.packageid = q.packageid
left join queryversion qv on qv.queryid = q.queryid

order by LanguageName, [Group Name], [Query Name], Scope, UpdateTime desc
