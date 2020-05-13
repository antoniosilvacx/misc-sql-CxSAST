use cxdb;

select servername, (select datediff( minute, max(ts.enginefinishedon), getdate())/60.0 from taskscans ts where ts.enginefinishedon > dateadd( month, -1, getdate() ) and ts.serverid = es.id ) as 'Hours since last scan finish' ,
	concat( ( select count(*) from scanrequests sr where sr.serverid = es.id ), '/', es.MAX_SCANS ) as 'Scan slots in use', es.ScanMinLoc, es.ScanMaxLoc, (select count(*) from scanrequests sr where sr.ServerID is null and sr.loc between es.ScanMinLoc and es.ScanMaxLoc) as 'Queued'
from engineservers es
where active = 1 and isblocked = 0 and (select count(*) from scanrequests sr where sr.serverid = es.id) < es.MAX_SCANS
and (select count(*) from scanrequests sr where sr.ServerID is null and sr.loc between es.ScanMinLoc and es.ScanMaxLoc) > 0
order by 1 asc