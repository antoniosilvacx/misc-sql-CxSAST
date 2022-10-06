use cxdb;
delete from scanrequests;
delete from enginesessiontoserver;
delete from QRTZ_CRON_TRIGGERS where trigger_name = 'ScanJob';
delete from PostScanActions;

update engineservers set serveruri = replace( serveruri, '://', '://old-'), IsBlocked = 1;
update accesscontrol.samlserviceprovider set 
	EncryptedCertificate = '123',
	EncryptedCertificatePassword = '321'
	where id = 1;
update IssueTrackingSystems set systemsettings = replace( systemsettings, '://', '://old' )