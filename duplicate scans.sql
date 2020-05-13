select
	projectname,
	case	
		when min < 60 then
			concat(min, ' minutes')
		when min < 24*60 then
			concat( cast( min/60.0 as decimal(10,1) ), ' hours' )
		else
			concat( cast( min/(24.0 * 60.0) as decimal(10,1) ), ' days' )
	end as 'Age',
	case
		when stage < 4 then
			'Queued'
		when stage = 4 then
			'Running'
		else
			'Cleanup'
	end as 'Status',
	LOC
from
(
	select
		sr.ProjectName, datediff( minute, sr.CreatedOn, getDate()) as 'min', sr.Stage, sr.LOC
	from
		scanrequests sr
	where
		(select count(*) from scanrequests sr2 where sr2.projectid = sr.projectid) > 1
) as data
order by projectname asc, stage desc, age desc