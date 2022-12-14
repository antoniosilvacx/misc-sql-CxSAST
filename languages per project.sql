/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) sl.[ScanId], ts.starttime, p.name,	  
	  qls.languagename
  FROM [CxDB].[CxEntities].[ScanLanguages] sl
left join
	QueryLanguageStates qls on qls.ID = sl.VersionId and qls.Language= sl.LanguageId
left join
	taskscans ts on ts.id = sl.scanid
left join
	projects p on p.id = ts.projectid
order by
	sl.scanid desc