use cxdb;

select * from
	(
	select p.id, p.name, 
		(select avg(tse.LOC) from taskscans ts left join TaskScanEnvironment tse on tse.scanid = ts.id where ts.projectid = p.id and ts.ScanRequestCreatedOn >= dateadd( month, -12, getdate() ) and not tse.loc is null ) as 'Average LOC',
		(select count(*) from taskscans ts where ts.projectid = p.id and ts.ScanRequestCreatedOn >= dateadd( month, -12, getdate() ) and not ts.enginefinishedon is null) as 'Finished scans',
		(select count(*) from taskscans ts where ts.projectid = p.id and ts.ScanRequestCreatedOn >= dateadd( month, -12, getdate() ) and not ts.enginestartedon is null and ts.enginefinishedon is null) as 'Partial scans',
		(select count(*) from taskscans ts where ts.projectid = p.id and ts.ScanRequestCreatedOn >= dateadd( month, -12, getdate() ) and ts.enginestartedon is null) as 'Skipped scans',
		(select count(*) from failedscans fs where fs.projectid = p.id and fs.CreatedOn >= dateadd( month, -12, getdate() ) ) as 'Failed scans',
		(select count(*) from canceledscans cs where cs.projectid = p.id) as 'Canceled scans'
	from projects p
	where 
		p.is_deprecated = 0
	) d
where isnull(d.[Average LOC], 0) > 2000000