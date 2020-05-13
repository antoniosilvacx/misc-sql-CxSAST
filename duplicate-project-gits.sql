use cxdb;

select
	git, count(*) as Projects
from
(
	select id, name, substring( path, realfirst, length ) as git
	from (
		select id, name, substring( path, first, last-first ) as path, charindex( '/', substring( path, first, last-first ) ) as realfirst, last-first as length
		from
		(
			select id, name, path, patindex( '%.wdf.sap.corp%', path) as first, patindex( '%</Url>%', path) as last from projects
			where 
			is_deprecated = 0
			and path like '%git%'
		) as data
	) as data2
) as data3
group by git
order by 2 desc;