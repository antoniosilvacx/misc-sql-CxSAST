use cxdb;

if object_id( N'tempdb..#tempGitRepos' ) is not null
	drop table #tempGitRepos;

if object_id( N'tempdb..#tempGitSummary' ) is not null
	drop table #tempGitSummary;


select 
	id,
	name,  
	path, 
	patindex( '%<url>%', path ) as 'URLStart', 
	patindex( '%</url>%', path ) as 'URLEnd',
	patindex( '%<subfolders>%', path ) as 'FolderStart',
	patindex( '%</subfolders>%', path ) as 'FolderEnd'
into
	#tempGitRepos
from projects with (nolock)
where path like '%projectGit%'

select id, name,
	case 
		when path like '%@%' then substring( path, charindex( '@', path, 0 ) + 1, URLEnd - charindex( '@', path, 0 ) - 1 ) 
		else substring( path, URLStart + 5, URLEnd - URLStart - 5)
	end as 'URL',
	substring( path, FolderStart + 12, FolderEnd - FolderStart - 12 ) as 'Folder',
	(select queuedon from taskscans ts with (nolock) where ts.projectid = #tempGitRepos.id) as 'Last Scan'
into #tempGitSummary
from #tempGitRepos;

select 
	id, Name,
	case 
		when url like '%://%' then substring( url, patindex( '%://%', url ) + 3, len( url ) )
		else url
	end as URL,
	folder as 'Branch',
	[Last Scan]
from #tempGitSummary
