/* 
	Database.RecoveryMode.Simple
	A lot of Ampla database are set up with FULL recovery mode that is not required
	
	The [SQL] column contains a generated script to set them to 'SIMPLE'
*/

SELECT 
	name, 
	recovery_model_desc,
	'ALTER DATABASE [' + name + '] SET RECOVERY SIMPLE WITH NO_WAIT ' as [SQL]
FROM 
	sys.databases
WHERE recovery_model_desc = 'FULL'
	and name not in 
	('master', 'temp_db', 'model', 'msdb', 
	'ReportServer')
ORDER BY 
	name