Runtime Stream Scripts
===

A set of scripts to understand the number and types of values stored in the Stream tables of the Ampla State database.

----------

###Streams.Age.sql###

Source: [SQL](Streams.Age.sql)

Outputs the age of the streams in the state database to help identify streams that are not being updated.

Output:

![SQL Output](../../images/streams/Streams.Age.png)

----------

###Streams.Orphaned.sql###

Source: [SQL](Streams.Orphaned.sql)

Checks to see if there is any orphaned Streams in the State database and outputs SQL script to delete them

Output:

![SQL Output](../../images/streams/Streams.Orphaned.png)

```sql
	DELETE FROM AmplaProjectState.dbo.SampleStoreSampleStream WHERE StreamId=819
	DELETE FROM AmplaProjectState.dbo.SampleStoreSampleStream WHERE StreamId=820
```

----------

###Streams.SampleCount.sql###

Source: [SQL](Streams.SampleCount.sql)

Outputs each of the streams in the state database showing their start and end time as well as the number of samples stored.

Output:

![SQL Output](../../images/streams/Streams.SampleCount.png)

----------