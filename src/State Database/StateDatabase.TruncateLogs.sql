declare @utcNow datetime
declare @weeksOld int
declare @countLogs int

set @utcNow = GETUTCDATE()

select @weeksOld = DATEDIFF(WK, logSummary.oldest, @utcNow), @countLogs = logSummary.records
from 
	(
		select min(Timestamp) as oldest, COUNT(1) as records
		from dbo.Log
	) logSummary




if (@weeksOld > 4)
begin
	print 'Log table has ' + cast(@countLogs as varchar(10)) + ' rows'
	print 'Oldest log record is ' + cast(@weeksOld as varchar(10)) + ' weeks old'
	
	declare @expiresAt datetime
	set @expiresAt = DATEADD(WK, -1 * (@weeksOld - 1), @utcNow) 
	print 'Deleting log entries - Expiry date (UTC): ' + cast(@expiresAt as varchar(20))


	print '-- Deleting records from CategoryLog'
	DELETE dbo.CategoryLog
	--select CategoryLogId
	from dbo.CategoryLog
	INNER JOIN dbo.Log
		ON Log.LogId = CategoryLog.LogId	
	WHERE Log.Timestamp < @expiresAt

	print '-- Deleting records from Scenario'
	DELETE dbo.Scenario
	--select *
	from dbo.Scenario
	INNER JOIN dbo.Log
		ON Log.InstanceId = Scenario.InstanceId	
	WHERE Log.Timestamp < @expiresAt

	print '-- Deleting records from Log'
	DELETE dbo.Log
	--select *
	from dbo.Log
	WHERE Log.Timestamp < @expiresAt 
end 
else
begin
	print 'Log table has ' + cast(@countLogs as varchar(10)) + ' rows - no rows are deleted.'
	print 'Oldest record is ' + cast(@weeksOld as varchar(10)) + ' weeks old'
end