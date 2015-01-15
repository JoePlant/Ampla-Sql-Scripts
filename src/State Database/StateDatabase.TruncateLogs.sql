/*

	Ampla State Database Script to manage the size of the Log and Category Log tables.

*/

declare @utcNow datetime
declare @weeksOld int
declare @countLogs int

set @utcNow = GETUTCDATE()

-- get an indication of the oldest record and size of the Log table.
select @weeksOld = DATEDIFF(WK, logSummary.oldest, @utcNow), @countLogs = logSummary.records
from 
	(
		select min(Timestamp) as oldest, COUNT(1) as records
		from dbo.Log
	) logSummary

if (@weeksOld > 4)
begin

	declare @categoryLogDeleted int
	declare @scenarioDeleted int
	declare @logDeleted int
	
	print 'Log table has ' + cast(@countLogs as varchar(10)) + ' rows'
	print 'Oldest log record is ' + cast(@weeksOld as varchar(10)) + ' weeks old'
	
	declare @expiresAt datetime
	set @expiresAt = DATEADD(WK, -1 * (@weeksOld - 1), @utcNow) 
	print 'Deleting log entries - Expiry date (UTC): ' + cast(@expiresAt as varchar(20))

	print '-- Deleting records from CategoryLog'
	DELETE dbo.CategoryLog
	from dbo.CategoryLog
	INNER JOIN dbo.Log
		ON Log.LogId = CategoryLog.LogId	
	WHERE Log.Timestamp < @expiresAt
	-- get the number of records deleted
	set @categoryLogDeleted = @@ROWCOUNT

	print '-- Deleting records from Scenario'
	DELETE dbo.Scenario
	from dbo.Scenario
	INNER JOIN dbo.Log
		ON Log.InstanceId = Scenario.InstanceId	
	WHERE Log.Timestamp < @expiresAt
	-- get the number of records deleted
	set @scenarioDeleted = @@ROWCOUNT

	print '-- Deleting records from Log'
	DELETE dbo.Log
	from dbo.Log
	WHERE Log.Timestamp < @expiresAt 
	-- get the number of records deleted
	set @logDeleted = @@ROWCOUNT

	print '*** [Summary] ***'
	print '***  Deleted ' + cast(@logDeleted as varchar(10)) + ' rows from the Log table'
	print '***  Deleted ' + cast(@categoryLogDeleted as varchar(10)) + ' rows from the CategoryLog table'
	print '***  Deleted ' + cast(@scenarioDeleted as varchar(10)) + ' rows from the Scenario table'

end 
else
begin
	print '*** [Summary] ***'
	print '--- No records have been deleted'
	print '--- Log table has ' + cast(@countLogs as varchar(10)) + ' rows '
	print '--- Oldest record is ' + cast(@weeksOld as varchar(10)) + ' weeks old'
end