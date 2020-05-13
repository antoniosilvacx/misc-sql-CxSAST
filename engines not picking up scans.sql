select * 
from
	(
	select 
		es.ServerName, (select count(*) from scanrequests with (nolock) where serverid = es.id) as Scans, es.MAX_SCANS, es.ScanMinLoc, es.ScanMaxLoc,
		(select count(*) from scanrequests with (nolock) where serverid is null and loc between es.scanminloc and es.scanmaxloc and queuedon < dateadd( minute, -20, getdate()) ) as ScansQueued20Min,
		datediff( minute, (select max(ts.enginefinishedon) as endtime from taskscans ts with (nolock) where ts.ServerID = es.id and ts.enginefinishedon > dateadd( week, -1, getdate()) ), getdate()) as LastScanFinished
	from
		engineservers es with (nolock)
	where
		es.isalive = 1 and
		es.IsBlocked = 0
	) as data
where
	data.scans < data.max_scans and
	data.ScansQueued20Min > 0 and
	data.LastScanFinished > 20