
-- Script to output the Threshold Range values for a reporting point.
-- @ReportingPoint is the reporting point location that is used.
-- The Upper and Lower threshold values are stored in the Calendar table.

DECLARE @ReportingPoint nvarchar(200)

--set @ReportingPoint = N'Enterprise.Site.Area.Quality'
--set @ReportingPoint = N'Enterprise.Site.Area.Production'
set @ReportingPoint = N'Enterprise.Site.Area.Production'

select ItemName, ActiveDateTime, ItemValue 
from Calendar
where ItemName like @ReportingPoint + '.Fields.%'
