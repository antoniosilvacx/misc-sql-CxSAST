use cxdb;

select id, projectid, taskid, projectname, loc, createdon, EngineStartedOn, updatedon,  datediff( minute, sr.engineStartedOn, getdate() ) as minutes, sr.loc/ datediff( minute, sr.EngineStartedOn, getdate()) as LocPerMin from scanrequests sr
where
	sr.loc > 0 and
	datediff( minute, sr.engineStartedOn, getdate() ) > 15 and
	( sr.loc/ datediff( minute, sr.EngineStartedOn, getdate()) ) < 500 
