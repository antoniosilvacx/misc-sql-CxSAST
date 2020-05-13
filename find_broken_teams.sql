IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[splitstring]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[splitstring]
GO

CREATE FUNCTION dbo.splitstring ( @stringToSplit VARCHAR(MAX) )
RETURNS
 @returnList TABLE ([parent] [nvarchar] (500), child [nvarchar] (500))
AS
BEGIN

 DECLARE @parent NVARCHAR(255), @child NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX('\', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX('\', @stringToSplit)  
  SELECT @child = SUBSTRING(@stringToSplit, 1, @pos-1)
  
  IF @parent = '' SET @parent = @child

  INSERT INTO @returnList 
  SELECT @parent, @child
  WHERE @child != ''

  SET @parent = @child

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 RETURN
END
GO

SELECT  child,COUNT(DISTINCT parent) 
FROM teams
CROSS APPLY dbo.splitstring(teampath)
GROUP BY child
HAVING COUNT(DISTINCT parent) > 1
