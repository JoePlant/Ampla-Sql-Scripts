Database Scripts
===

A set of useful database scripts for managing Ampla databases.

----------

###Database.BackupScript.sql###

Source: [SQL](Database.BackupScript.sql)

Generates a backup script for the Ampla databases that are suitable for once a day.

Output:

![SQL Output](../../images/database/Database.BackupScript.png)

----------

###Database.FileSizes.sql###

Source: [SQL](Database.FileSizes.sql)

Outputs the size of all the files used databases on the SQL Server.

Output:

![SQL Output](../../images/database/Database.FileSizes.png)

----------

###Database.Information.sql###

Source: [SQL](Database.Information.sql)

Outputs information about the Database configuration for all the databases on the SQL server.

Output:

![SQL Output](../../images/database/Database.Information.png)

----------

###Database.PerformanceCounters.sql###

Source: [SQL](Database.PerformanceCounters.sql)

Outputs performance counters values into a table with some guidance about how to interpret the results.

Output:  


![SQL Output](../../images/database/Database.PerformanceCounters.png)

----------

###Database.RecoveryMode.Simple.sql###

Source: [SQL](Database.RecoveryMode.Simple.sql)

Generates a script for all databases that are set to FULL recovery mode.
In most circumstances, SIMPLE Recovery mode will be sufficient for Ampla databases.

Please check the name of the database before executing the generated script

Output:

![SQL Output](../../images/database/Database.Information.png)

----------

###Database.TableSizes.sql###

Source: [SQL](Database.TableSizes.sql)

Outputs the size of all the tables in a database.

Output:

![SQL Output](../../images/database/Database.TableSizes.png)

