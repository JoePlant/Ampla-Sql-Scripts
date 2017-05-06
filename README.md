Ampla-Sql-Scripts
===

A set of SQL Scripts that are useful with Ampla projects

- Ampla Scripts
	- [Reporting Point Scripts](src/Reporting%20Points)
	- [Ampla Project Scripts](src/Ampla%20Project) 
	- [Stream Scripts](src/Streams) 
	- [Threshold Ranges Information](src/ThresholdRanges)

- Database Scripts
	- [Database Scripts](src/Database)

- Data Repository Scripts
	- [Integrity Checks](src/Checks)

### [Reporting Point Scripts](src/Reporting%20Points) ###
A set of scripts to count the number of records by reporting point type

- Module.RecordCounts.sql
- Module.FieldCounts.sql

### [Ampla Project Scripts](src/Ampla%20Project) ###
A set of scripts for understanding the Ampla Project configuration database

-  Item.FullName.sql
-  Item.FullName.Sorted.sql
-  Item.FullName.Type.sql

### [Stream Scripts](src/Streams) ###
A set of scripts for understanding the streams in the Ampla state database

-  Streams.Age.sql
-  Streams.LastSamples.sql
-  Streams.Orphaned.sql
-  Streams.SampleCount.sql

### [Database Scripts](src/Database) ###
A set of scripts to output general information about the SQL Server Databases

- Database.Assembly.Version.sql
- Database.BackupScript.sql
- Database.FileSizes.sql
- Database.CodeSizes.sql
- Database.Information.sql
- Database.PerformanceCounters.sql
- Database.RecoveryMode.Simple.sql
- Database.Trustworthy.sql
- Database.TableSizes.sql
- Database.ShrinkFiles.sql

### [Data Integrity Checks](src/Checks) ###
A set of scripts to check the data integrity of the Ampla Data Repository.

- DataRepository.Field.Duplicate.sql
- DataRepository.Field.Deleted.sql
- DataRepository.Field.InfinityNaN.sql
- Database.Trustworthy.sql
