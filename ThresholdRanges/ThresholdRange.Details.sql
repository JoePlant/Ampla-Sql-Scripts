/* 

Show the details of the ThresholdRange values stored in the calendar table

Threshold Ranges are stored in the Calendar Table using the following names
	Upper = {ReportingPoint}.Fields.{Field}.ThresholdRange.__UpperThreshold
	Lower = {ReportingPoint}.Fields.{Field}.ThresholdRange.__LowerThreshold
	
Debugging problems:
	- If the ThresholdRange column doesn't exist in the Project Configuration as an item fullname then then value will not be linked up correctly. 
*/

-- Using the Ampla Data Repository database
USE AmplaProjectData;

SELECT
	ItemName, 
	ActiveDateTime, 
	ItemValue,
	LEFT(ItemName, Charindex('.Fields.', ItemName)-1) as [ReportingPoint], 
	LEFT(ItemName, len(ItemName) - 17) /*LEN('__UpperThreshold')*/ as [ThresholdRange], 
	CASE WHEN ItemName LIKE '%.__UpperThreshold' 
		THEN 'Upper' 
		ELSE 'Lower' 
	END as [Direction],
	CASE WHEN ItemName LIKE '%.__UpperThreshold' 
		THEN '__UpperThreshold' 
		ELSE '__LowerThreshold' 
	END AS [ThresholdSuffix]
FROM 
	--[AmplaProjectData].[dbo].Calendar 
	Calendar
WHERE
	(ItemName like '%.__UpperThreshold') 
OR	(ItemName like '%.__LowerThreshold') 
