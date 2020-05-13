use cxdb;


select 
projectid, projectname, 
case 
when details like 'Stage%' then 'Failed while scanning'
when (details like 'Git clone failed: could not read Username%' or details like 'Git clone failed: Authentication failed%' or details like 'Git clone failed: could not read Pass%') then 'Git Auth'
when (details like 'Git clone failed: Could not switch%' or details like 'Git clone failed: %Permission denied%' or details like 'Git clone failed: could not create work%' or  details like 'Git clone failed: destination path%' or details like 'Git clone failed: cannot copy%File exists%' or details like 'Git clone failed: Invalid path%' or details like 'Git clone failed: Not a git repo%' or details like 'Git clone failed: Cloning into%') then 'Bad CxSrc destination path'
when (details like 'Git clone failed: repository%not found%' or details like 'Git clone failed: unable to access%' or details like 'Git clone failed: Could not read from%' or details like 'Git clone failed: Project not found%' or details like 'Git clone failed: unable to checkout%' or details like 'Git clone failed: Remote branch%not found%') then 'Git bad repo'
when details like 'Git clone failed: cannot create directory%' then 'Repo folder uses invalid characters'
when (details like 'Git clone failed: internal server error%' or details like 'Git clone failed: could not set%') then 'Git internal error'
when details like 'Git%' then 'Git generic error'
when (details like 'Failed to send scan%' or details like '%worker failed%' or details like '%There was no endpoint%') then 'Network issue'
when (details like 'System error%') then 'Checkmarx issue'
when (details like 'Perforce login error%') then 'Perforce Auth'
when (details like 'Perforce sync%' or details like 'PerforceSourceControl%') then 'Perforce clone failed'
when (details like 'SVN%') then 'SVN error'
when (details like '<?xml%') then 'XML error'
else 'Other'
end as FailReason
into #TempFailReasons
from failedscans
where createdon > dateadd( month, -12, getdate() )
and failedscans.ServerID in (85,92,94,95,96,97,87,88)
--and projectid in (58779,79656,136,58034,68841,67215,59773,68783,63851,68781,63426,63692,60062,68661,62828,62807,63830,69101,79596,63821,18532,43720,19906,63500,35531,67345,25313,68766,68707,15932,63442,19907,58919,29309,58618,13636,63985,29305,79768)
;

declare @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
SET @columns = N'';
select @columns += N', tfr.' + QUOTENAME(FailReason)
from (select distinct FailReason from #TempFailReasons) as tfr order by FailReason asc;

set @sql = N'
select projectid, projectname, ' + stuff(@columns, 1, 2, '') + ', (select count(*) from #tempfailreasons t2 where t2.projectname = tfr.projectname) as Total
from (select * from #TempFailReasons) as j
pivot
(
count(FailReason) for FailReason IN ('
+ STUFF(replace(@columns, ', tfr.[', ',['), 1, 1, '')
+ ')
) as tfr where [Failed while scanning] > 0;';
--print @sql;
exec sp_executesql @sql;

drop table #TempFailReasons
