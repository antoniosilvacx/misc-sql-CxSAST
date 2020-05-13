use cxdb;


select 
projectname, 
case 
when details like 'Stage%' then 'Failed while scanning'
when (details like 'Git clone failed: could not read Username%' or details like 'Git clone failed: Authentication failed%' or details like 'Git clone failed: could not read Pass%') then 'Git Auth'
when (details like 'Git clone failed: Could not switch%' or details like 'Git clone failed: %Permission denied%' or details like 'Git clone failed: could not create work%' or  details like 'Git clone failed: destination path%' or details like 'Git clone failed: cannot copy%File exists%' or details like 'Git clone failed: Invalid path%' or details like 'Git clone failed: Not a git repo%' or details like 'Git clone failed: Cloning into%') then 'Bad CxSrc destination path'
when (details like 'Git clone failed: repository%not found%' or details like 'Git clone failed: unable to access%' or details like 'Git clone failed: Could not read from%' or details like 'Git clone failed: Project not found%' or details like 'Git clone failed: unable to checkout%' or details like 'Git clone failed: Remote branch%not found%') then 'Git bad repo'
when details like 'Git clone failed: cannot create directory%' then 'Repo folder uses invalid characters'
when (details like 'Git clone failed: internal server error%' or details like 'Git clone failed: could not set%') then 'Git internal error'
when details like 'Git%' then 'Git generic error'
when (details like 'Failed to send scan%' or details like 'System error%' or details like '%worker failed%' or details like '%There was no endpoint%') then 'Checkmarx issue'
when (details like 'Perforce login error%') then 'Perforce Auth'
when (details like 'Perforce sync%' or details like 'PerforceSourceControl%') then 'Perforce clone failed'
when (details like 'SVN%') then 'SVN error'
when (details like '<?xml%') then 'XML error'
else 'Other'
end as FailReason
into #TempFailReasons
from failedscans
where createdon > dateadd( month, -1, getdate() );

declare @columns NVARCHAR(MAX);
SET @columns = N'select ';
select @columns += N'(select count(*) from #TempFailReasons where FailReason = ''' + tfr.FailReason + N''') as ''' + FailReason + N''','
from (select distinct FailReason from #TempFailReasons) as tfr order by FailReason asc;

select @columns += N' (select count(*) from #TempFailReasons) as Total';

exec sp_executesql @columns;

drop table #TempFailReasons;
