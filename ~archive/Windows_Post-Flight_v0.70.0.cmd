:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Windows Post-Flight Tool
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		geeraerd@evergreen.edu
::
::	Copyleft License(s)
::
:: GNU GPL Version 3
:: https://www.gnu.org/licenses/gpl.html
::
::
:: 	Creative Commons: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)  
:: 	http://creativecommons.org/licenses/by-nc-sa/3.0/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	##	VERSIONING INFORMATION	##
::	##	Semantic Versioning used##
::		http://semver.org/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@Echo Off
SETLOCAL Enableextensions

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET SCRIPT_NAME=Windows_Post-Flight
SET SCRIPT_VERSION=0.70.0
Title %SCRIPT_NAME% Version: %SCRIPT_VERSION%
Prompt WPF$G
color 9E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::###########################################################################::
:: Declare Global variables
:: All User variables are set within here.
::###########################################################################::

:: Working Directory for Post-Flight
::	this is also the (local storage) seed location for Post-Flight
SET "POST_FLIGHT_DIR=%ProgramData%\TESC\Post-Flight"
SET "POST_FLIGHT_CMD_NAME=Windows_Post-Flight.cmd"

::	FLASH Drive
::		provide the label for the flash drive
::		flash drive should contain all of the necessary files, especially if not preseeded in the working directory
SET FLASH_DRIVE_VOLUME_LABEL=POSTFLIGHT

:: File that contains host 'database'
:: 	FLASH DRIVE acts as the backup & update location for HOST_FILE_DATABASE (& OTHER assets)
::	format
::	#Hostname #MAC 00-00-00-00-00-00
::	%HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE%
::		this is the location and file name where the commandlet expects it
::		commandlet will auto-update from [source] flash drive to destination
SET HOST_FILE_DATABASE_LOCATION=%POST_FLIGHT_DIR%
SET HOST_FILE_DATABASE=Scientific_Computing_MAC_List.txt

:: Default Host name from Unattend.xml file
SET DEFAULT_HOSTNAME=SC-RENAME 

:: Local Administrator Password
::	assumes it will be in the working directory
SET LOCAL_ADMIN_PW_FILE=Local_Administrator_Password.txt

:: Hard Drive Configuration
::	assumes it will be in the working directory
SET DISKPART_COMMAND_FILE=DiskPart_Hard_Drive_Config.txt


:: NETDOM CONFIGURATION
::	to skip this step, leave domain as NOT_SET
:: SET NETDOM_DOMAIN=NOT_SET
SET NETDOM_DOMAIN=evergreen.edu
SET NETDOM_USERD=david_su
::	To be prompted for password
::	SET NETDOM_PASSWORDD=*
SET NETDOM_PASSWORDD=
SET NETDOM_USERD_PW_FILE=Domain_Join_Password.txt
SET NETDOM_REBOOT=30
:: Future use
:: Not currently used	
:: SET NETDOM_USERO=
:: SET NETDOM_PASSWORDO=
:: SET NETDOM_OU=

:: Windows Network AD NETLOGON
SET AD_NETLOGON=\\Evergreen.edu\NETLOGON

:: Chocolatey
::	Universal as default
SET CHOCO_META_PACKAGE=Universal
::	location & name
SET CHOCO_PACKAGE_LIST_LOCATION=%POST_FLIGHT_DIR%
SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt
::	DEFAULT LOCATION FOR Chocolatey is %PROGRAMDATA%\chocolatey
SET CHOCO_LOCATION=%PROGRAMDATA%\chocolatey

:: Ultimate Commandlet configurations
::	%ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%
SET "ULTIMATE_FILE_LOCATION=%POST_FLIGHT_DIR%"
SET ULTIMATE_FILE_NAME=SC_Sorcerer's_Apprentice.cmd


:: Log Files Settings
::	Main script log file
:: %LOG_LOCATION%\%LOG_FILE%
SET LOG_LOCATION=%ProgramData%\TESC\Post-Flight\Logs
SET LOG_FILE=Windows_Post-Flight_%SCRIPT_VERSION%.Log

:: sub-file names for each process --configured to output in LOG_LOCATION
:: Process 1: Change the hostname
SET PROCESS_1_FILE_NAME=RUN_DiskPart_%SCRIPT_VERSION%.txt
:: Process 2: Local Administrator configuration
SET PROCESS_2_FILE_NAME=RUN_Hostname_Changed_%SCRIPT_VERSION%.txt
:: Process 3: Join a Windows Domain
SET PROCESS_3_FILE_NAME=RUN_Administrator_configured_%SCRIPT_VERSION%.txt
:: Process 4: Run Chocolatey
SET PROCESS_4_FILE_NAME=RUN_Domain_Joined_%SCRIPT_VERSION%.txt
:: Process 5: Run Ultimate script
SET PROCESS_5_FILE_NAME=RUN_Chocolatey_%SCRIPT_VERSION%.txt
:: Process 6: Process Disk condifuration
SET PROCESS_6_FILE_NAME=RUN_Ultimate_%SCRIPT_VERSION%.txt

:: Completed File name
SET PROCESS_COMPLETE_FILE=COMPLETED_%SCRIPT_NAME%_%SCRIPT_VERSION%.log


::*******************::
:: Advanced Settings ::
::*******************::
:: To cleanup or Not to cleanup, the seed location
::	0 = OFF (NO)
::	1= ON (YES)
SET SEED_LOCATION_CLEANUP=1

::	Chocolatey advanced
::		turn on advanced Chocolatey package assignment based on hostname criteria
::		each package list must be paired with criteria_Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt file 
::		i.e. criteria_Chocolatey_Universal_Packages.txt
::	0 = OFF (NO)
::	1= ON (YES)
SET CHOCOLATEY_ADVANCED=1
::	the list should be in a hierchical order
::		once a match is found  it will be applied
SET "CHOCO_META_PACKAGE_LIST=CAL Science Universal"

:: LOGGING LEVEL CONTROL
::	by default, ALL=0 & TRACE=0
SET LOG_LEVEL_ALL=1
SET LOG_LEVEL_INFO=1
SET LOG_LEVEL_WARN=1
SET LOG_LEVEL_ERROR=1
SET LOG_LEVEL_FATAL=1
SET LOG_LEVEL_DEBUG=0
SET LOG_LEVEL_TRACE=0

:: PROCESS CHECK
::	(possible future expansion)
::	check against this number of actions
::		default is 6
::	{(1)Disk Configuration; (2)Hostname change; (3)Local Administrator; (4)Join a domain; (5)run Chocolatey, (6)run Ultimate script}
SET PROCESS_CHECK_NUMBER=6


::###########################################################################::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::																			 ::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####			 ::
::																			 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF NOT EXIST %LOG_LOCATION% MD %LOG_LOCATION% || GoTo err000
IF %LOG_LEVEL_ALL% EQU 1 (ECHO [INFO]	START %DATE% %TIME%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 (ECHO [DEBUG]	ALL logging is turned on!) >> %LOG_LOCATION%\%LOG_FILE%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:flogl
:: FUNCTION: Check for ALL LOG LEVEL
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	entering function Check for ALL log level!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_INFO=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_WARN=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_ERROR=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_FATAL=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_DEBUG=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_TRACE=1
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	exiting function Check for ALL log level!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fsTime
:: FUNCTION: Start Time
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	entering function start time for lapse time!) >> %LOG_LOCATION%\%LOG_FILE%
:: Calculate lapse time by capturing start time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET S_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET S_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET S_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET S_ms=%%h
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	S_hh: %S_hh%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	S_mm: %S_mm%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	S_ss: %S_ss%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	S_mm: %S_mm%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	exiting function start time for lapse time!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:start
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	entering function Start!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	START %DATE% %TIME% >> %LOG_LOCATION%\%LOG_FILE%
ECHO START %DATE% %TIME%
ECHO %SCRIPT_NAME% %SCRIPT_VERSION%
ECHO Logs can be found here: %LOG_LOCATION%
ECHO Log file for WPF: %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	SCRIPT_VERSION: %SCRIPT_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
whoami > %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_whoami.txt
SET /P var_WHOAMI= < %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_whoami.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_WHOAMI% >> %LOG_LOCATION%\%LOG_FILE%
::	fancy parsing for proper output of info
FOR /F "tokens=3-6" %%G IN ('systeminfo ^| FIND /I "OS NAME"') DO ECHO OS Name: %%G %%H %%I %%J > %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_systeminfo.txt
SET /P var_SYSTEMINFO= < %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_systeminfo.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_SYSTEMINFO% >> %LOG_LOCATION%\%LOG_FILE%
ver > %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_ver.txt
FOR /F "skip=1 tokens=1 delims=" %%V IN (%LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_ver.txt) DO SET var_VER=%%V
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_VER% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Log level ALL is [%LOG_LEVEL_ALL%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEGUG]	Log level INFO is [%LOG_LEVEL_INFO%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	Log level WARN is [%LOG_LEVEL_WARN%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	Log level ERROR is [%LOG_LEVEL_ERROR%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	Log level FATAL is [%LOG_LEVEL_FATAL%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	Log level DEBUG is [%LOG_LEVEL_DEBUG%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	Log level TRACE is [%LOG_LEVEL_TRACE%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO [TRACE]	exiting function Start!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: META DEPENDENCY CHECKS
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	entering META Dependency Check! >> %LOG_LOCATION%\%LOG_FILE%

::	(1) Is everyting already done?
Echo Checking to see if everything is already done...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	entering Dependency Check: for Everything Already Done? >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% GoTo err10
ECHO First run or a follow up run!

::	(2) Get the Flash Drive Volume
Echo Looking for a flashdrive with volume label [%FLASH_DRIVE_VOLUME_LABEL%]
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: Looking for a flash drive... >> %LOG_LOCATION%\%LOG_FILE%
ECHO LIST VOLUME > %LOG_LOCATION%\DiskPart_Commands.txt
DISKPART /s %LOG_LOCATION%\DiskPart_Commands.txt > %LOG_LOCATION%\DiskPart_Volume_LIST.txt
FIND "%FLASH_DRIVE_VOLUME_LABEL%" %LOG_LOCATION%\DiskPart_Volume_LIST.txt > %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt
FOR /F "usebackq skip=2 tokens=3" %%G IN ("%LOG_LOCATION%\FOUND_FLASH_DRIVE.txt") DO SET FLASH_DRIVE_VOLUME=%%G:
IF EXIST %FLASH_DRIVE_VOLUME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Flash Drive Found: %FLASH_DRIVE_VOLUME%) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %FLASH_DRIVE_VOLUME% ECHO Flash Drive Found: %FLASH_DRIVE_VOLUME%
IF NOT EXIST %FLASH_DRIVE_VOLUME% (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	No Flash Drive found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %FLASH_DRIVE_VOLUME% ECHO No Flash Drive found!
IF EXIST %LOG_LOCATION%\DiskPart_Commands.txt del /F /Q %LOG_LOCATION%\DiskPart_Commands.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%LOG_LOCATION%\DiskPart_Commands.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\DiskPart_Volume_LIST.txt del /F /Q %LOG_LOCATION%\DiskPart_Volume_LIST.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG] %LOG_LOCATION%\DiskPart_Volume_LIST.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt del /F /Q %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG] %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%

::	(3)	Update seed location from FLASH Drive
::		this must include the host file database
ECHO Seed location: %POST_FLIGHT_DIR%
IF EXIST %FLASH_DRIVE_VOLUME% ECHO Updating seed location with flash drive...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: update seed location if flash drive found >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% GoTo jump3
IF EXIST %FLASH_DRIVE_VOLUME% ROBOCOPY %FLASH_DRIVE_VOLUME%\ %POST_FLIGHT_DIR%\ *.* /NP /R:1 /W:2 /XF *.lnk /LOG:%LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
SET ROBO_SEED_CODE=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Robocopy exit code for seed location: EXIT CODE:%ROBO_SEED_CODE%) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Seed location [%POST_FLIGHT_DIR%] just got updated from Flash drive [%FLASH_DRIVE_VOLUME%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% EQU 3 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Seed location [%POST_FLIGHT_DIR%] just got updated from Flash drive [%FLASH_DRIVE_VOLUME%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% LEQ 3 ECHO Seed location [%POST_FLIGHT_DIR%] just got updated from Flash drive [%FLASH_DRIVE_VOLUME%]!
IF %ROBO_SEED_CODE% GTR 7 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Seed location [%POST_FLIGHT_DIR%] failed to update!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% GTR 7 ECHO Seed location [%POST_FLIGHT_DIR%] failed to update!
:jump3

::	(4) NETDOM
::	not present until proven otherwise
Echo Checking for NETDOM presence...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: checking if NETDOM is present. >> %LOG_LOCATION%\%LOG_FILE%
SET NETDOM_PRESENCE=0
IF %LOG_LEVEL_INFO% EQU 1 (ECHO [INFO]	Checking for NETDOM presence...) >> %LOG_LOCATION%\%LOG_FILE%
dir %SYSTEMROOT%\System32 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
dir %SYSTEMROOT%\SysWOW64 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
IF EXIST %SYSTEMROOT%\SysWOW64\netdom.exe PATH=%PATH%;%SYSTEMROOT%\SysWOW64
IF %NETDOM_PRESENCE% EQU 0 (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	NETDOM is NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	NETDOM is present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 0 ECHO NETDOM is NOT present!
IF %NETDOM_PRESENCE% EQU 1 ECHO NETDOM is present!

::	(5) Password Files
Echo Checking for password files...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: looking for password files. >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] found!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% ECHO Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] found!
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% SET /P ADMIN_PASSWORD= < %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] not found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% ECHO Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] not found!
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Domain Join User Password file [%NETDOM_USERD_PW_FILE%] found!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% ECHO Domain Join User Password file [%NETDOM_USERD_PW_FILE%] found!
IF "%NETDOM_PASSWORDD%"=="*" (IF %LOG_LEVEL_WARN% EQU 1 ECHO [DEBUG]	User requested to be prompted with domain join password! >> %LOG_LOCATION%\%LOG_FILE%) ELSE (
	IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% SET /P NETDOM_PASSWORDD= < %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE%)
IF NOT EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Domain Join User Password file [%NETDOM_USERD_PW_FILE%] not found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% ECHO Domain join user password file [%NETDOM_USERD_PW_FILE%] not found!

::	(6) Chocolatey
Echo Checking for Chocolatey...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: checking if Chocolatey is present? >> %LOG_LOCATION%\%LOG_FILE%
::	not present until proven otherwise
SET CHOCO_PRESENCE=0
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Checking for Chocolatey presence... >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %CHOCO_LOCATION%\choco.exe SET CHOCO_PRESENCE=1
:: Just in case PATH doesn't contain choco
IF EXIST %CHOCO_LOCATION%\choco.exe SET "PATH=%PATH%;%CHOCO_LOCATION%\"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG] PATH just got set to: %PATH% >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %CHOCO_LOCATION%\choco.exe (Choco | FIND "Chocolatey") > %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF EXIST %CHOCO_LOCATION%\choco.exe SET /P var_CHOCOLATEY= < %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_CHOCOLATEY% is present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Chocolatey is NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 1 ECHO %var_CHOCOLATEY% is present!
IF %CHOCO_PRESENCE% EQU 0 ECHO Chocolatey is NOT present!

::	Chocolatey First time install
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Attempting first time Chocolatey install...) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 ECHO Attempting first time Chocolatey install...
::		attempt to install from Sub-Routine
IF %CHOCO_PRESENCE% EQU 0 GoTo subr1
:jump1
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEGUG]	CHOCOLATEY attempted to install for the first time, but may have FAILED!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %CHOCO_LOCATION%\choco.exe SET CHOCO_PRESENCE=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG] CHOCO_PRESENCE is set to: %CHOCO_PRESENCE% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exiting Dependency Check for Chocolatey. >> %LOG_LOCATION%\%LOG_FILE%

::	(7) HOST DATABASE
Echo Checking for host database...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: Looking for host database. >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% ECHO Host database found!
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% ECHO Host database not found!
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% GoTo err1
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exiting Dependency Check for looking for host database. >> %LOG_LOCATION%\%LOG_FILE%

::	(8) Try and fix NETDOM DEPENDENCY
::	will try and insatll Remote Server Administration Tools (NETDOM) from Flash drive
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Dependency Check: Trying to install Remote Server Administrative Tools [NETDOM] if not present... >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 GoTo Start
ECHO Attempting to install RSAT NETDOM...
IF EXIST %POST_FLIGHT_DIR% (dir /B %POST_FLIGHT_DIR% | FIND /I "msu" > %LOG_LOCATION%\var_NETDOM_INSTALL.txt) ELSE (
	IF EXIST %FLASH_DRIVE_VOLUME% dir /B /A %FLASH_DRIVE_VOLUME% | FIND /I "msu" > %LOG_LOCATION%\var_NETDOM_INSTALL.txt)
IF EXIST %LOG_LOCATION%\var_NETDOM_INSTALL.txt SET /P NETDOM_INSTALL= < %LOG_LOCATION%\var_NETDOM_INSTALL.txt
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Package [%NETDOM_INSTALL%] was found and will be used to install RSAT-Remote Server Administrative Tools [NETDOM]. >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var_NETDOM_INSTALL.txt (IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	An error occured looking for RSAT-Remote Server Administrative Tools [NETDOM] installer!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var_NETDOM_INSTALL.txt GoTo start
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Trying to install:[%NETDOM_INSTALL%]... >> %LOG_LOCATION%\%LOG_FILE%
ECHO Installing NETDOM with this installer [%NETDOM_INSTALL%]...
"%POST_FLIGHT_DIR%\%NETDOM_INSTALL%" /quiet || IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	RSAT [%NETDOM_INSTALL%] installation failed! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	RSAT installer return code: %ERRORLEVEL% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	RSAT-Remote Server Administration Tools [%NETDOM_INSTALL%] [NETDOM] attempted to install! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]]	Checking for NETDOM presence... >> %LOG_LOCATION%\%LOG_FILE%
dir %SYSTEMROOT%\System32 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
IF %NETDOM_PRESENCE% EQU 0 DIR %SYSTEMROOT%\SysWOW64 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
IF EXIST %SYSTEMROOT%\SysWOW64\netdom.exe SET "PATH=%PATH%;%SYSTEMROOT%\SysWOW64"
IF %NETDOM_PRESENCE% EQU 0 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR] NETDOM is still NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	NETDOM is now present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit Dependency Check: for Remote Server Administrative Tools [NETDOM] >> %LOG_LOCATION%\%LOG_FILE%
GoTo start
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::*****************************************************************************
:start
:: start processing
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Start Processing entered! >> %LOG_LOCATION%\%LOG_FILE%

:://///////////////////////////////////////////////////////////////////////////
:step1
:: Process DiskPart to configure hard drive
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step1 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap1
:: TRAP 1 to catch if diskpart has already run
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Trap1 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% GoTo skip1

:fdisk
:: FUNCTION Run DISKPART utility
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION Diskpart entered! >> %LOG_LOCATION%\%LOG_FILE%
ECHO DISKPART is running...
ECHO %DATE% %TIME% DISKPART is running... >> %LOG_LOCATION%\%PROCESS_1_FILE_NAME%
DISKPART /s %POST_FLIGHT_DIR%\%DISKPART_COMMAND_FILE% >> %LOG_LOCATION%\%PROCESS_1_FILE_NAME%
IF %ERRORLEVEL% EQU 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Diskpart completed!) ELSE (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Diskpart threw an error [%ERRORLEVEL%]! Check disk configuration!) >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME% DISKPART finnished! >> %LOG_LOCATION%\%PROCESS_1_FILE_NAME%
ECHO DISKPART finnished!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION Diskpart exiting! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step2

:skip1
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip1 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% ECHO DiskPart has already run! >> %LOG_LOCATION%\%PROCESS_1_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	DiskPart has already run! >> %LOG_LOCATION%\%LOG_FILE%
ECHO DiskPart has already run!
GoTo step2
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step2
:: Aquire the local MAC address and lookup host database file inorder to set the new hostname.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step2 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap2
:: TRAP 2 to catch if the hostname is not the default, which means it's likey changed
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap2 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% GoTo skip2
IF /I "%COMPUTERNAME%"=="%DEFAULT_HOSTNAME%" (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Hostname:[%COMPUTERNAME%] needs to be changed!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%COMPUTERNAME%"=="%DEFAULT_HOSTNAME%" ECHO Hostname:[%COMPUTERNAME%] needs to be changed!
GoTo fmac

:fmac
:: FUNCTION	GET MAC Address
:: Getting the Host MAC Address
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION GETMAC entered! >> %LOG_LOCATION%\%LOG_FILE%
GETMAC > %LOG_LOCATION%\Host_MAC.txt
::	search the getmac file & set mac based on mac database
FOR /F "skip=3 tokens=1" %%G IN (%LOG_LOCATION%\Host_MAC.txt) DO FIND "%%G" %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% && SET HOST_MAC=%%G
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	HOST_MAC: %HOST_MAC% >> %LOG_LOCATION%\%LOG_FILE%
ECHO Computer MAC: %HOST_MAC%
GoTo trap21

:trap21
:: Trap to catch if NETDOM is present or not
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap2.1 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 0 GoTo err3
GoTo fhost

:fhost
:: FUNCTION SET THE HOSTNAME
::	based on MAC address
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION Set the hostname entered! >> %LOG_LOCATION%\%LOG_FILE%
FIND "%HOST_MAC%" %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% > %LOG_LOCATION%\MAC-2-HOST.txt
:: Strip the MAC address from the file and set the hostname
FOR /F "usebackq skip=2 tokens=1" %%G IN ("%LOG_LOCATION%\MAC-2-HOST.txt") DO SET HOST_STRING=%%G
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	HOST_STRING: %HOST_STRING% >> %LOG_LOCATION%\%LOG_FILE%
IF NOT "HOST_STRING"=="" (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Hostname [%HOST_STRING%] found in HOST_FILE_DATABASE [%HOST_FILE_DATABASE%]) >>	%LOG_LOCATION%\%LOG_FILE%
IF /I %COMPUTERNAME%==%HOST_STRING% GoTo Skip2
NETDOM RENAMECOMPUTER %computername% /NewName:%HOST_STRING% /FORCE /REBoot:%NETDOM_REBOOT% || GoTo err3
IF %ERRORLEVEL% EQU 0 Echo %DATE% %TIME% Hostname [%COMPUTERNAME%] is being changed to [%HOST_STRING%]! > %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Hostname [%COMPUTERNAME%] has been renamed to: %HOST_STRING%) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO Hostname [%COMPUTERNAME%] has been renamed to: %HOST_STRING%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO %DATE% %TIME% Hostname [%HOST_STRING%] found in HOST_FILE_DATABASE [%HOST_FILE_DATABASE%] >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds! >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds!
:: Goes to FUNCTION END TIME since the computer is rebooting
GoTo feTime

:skip2
:: Skip 2 means the hostname has already been set.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip 2 entered! >> %LOG_LOCATION%\%LOG_FILE%
SET HOST_STRING=%COMPUTERNAME%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO %DATE% %TIME% Hostname already set to [%COMPUTERNAME%] matching [%HOST_STRING%] from host file:[%HOST_FILE_DATABASE%] >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Hostname already set [%COMPUTERNAME%]! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Hostname already set [%COMPUTERNAME%]!
IF EXIST %LOG_LOCATION%\Host_MAC.txt TYPE %LOG_LOCATION%\Host_MAC.txt >> %PROCESS_2_FILE_NAME% && del /F /Q %LOG_LOCATION%\Host_MAC.txt
IF EXIST %LOG_LOCATION%\MAC-2-HOST.txt TYPE %LOG_LOCATION%\MAC-2-HOST.txt >> %PROCESS_2_FILE_NAME% && del /F /Q %LOG_LOCATION%\MAC-2-HOST.txt
GoTo step3
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step3
:: Configures the local administrator account
::	Do this before joining the domain in order to ensure not getting locked out withouth admin priveleges
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step3 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap3
:: TRAP 3 to catch if the local administrator has already been configured
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap3 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% GoTo skip3

:fadmin
:: FUNCTION Configure local administrator account
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION [3] Configure local administrator entered! >> %LOG_LOCATION%\%LOG_FILE%
NET USER Administrator %ADMIN_PASSWORD% /ACTIVE:YES
IF %ERRORLEVEL% EQU 0 ECHO %DATE% %TIME% Local Administrator account configured/Re-configured! >> %LOG_LOCATION%\%PROCESS_3_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Local Administrator account configured/Re-configured!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO Local Administrator account configured/Re-configured!
GoTo step4

:skip3
:: Skip 3 means the local Administrator account has already been configured.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip3 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Local Administrator already configured! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Local Administrator already configured!
GoTo step4
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step4
:: Joins the computer to a Domain if choosen to do so
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step4 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap4
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap4 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% GoTo skip4
:: Check to make sure a domain is configured, otherwise not joining a domain
IF /I "%NETDOM_DOMAIN%"=="" (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Not joining a domain! No Domain provided in configuration!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%NETDOM_DOMAIN%"=="NOT_SET" (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Not joining a domain! Domain was not set in configuration!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%NETDOM_DOMAIN%"=="NOT_SET" GoTo trap41
IF /I "%NETDOM_DOMAIN%"=="" GoTo trap41

:trap41
:: TRAP4.1 to catch if the computer has already been joined to a domain
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap4.1 entered! >> %LOG_LOCATION%\%LOG_FILE%
::	multiple checks to really make sure...
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% GoTo skip4
IF /I "%NETDOM_DOMAIN%"=="%USERDOMAIN%" GoTo skip4
IF /I "%NETDOM_DOMAIN%"=="%USERDNSDOMAIN%" GoTo skip4
IF %NETDOM_PRESENCE% EQU 0 GoTo err3
::	wait to implement needs testing when run as script
:: NETDOM VERIFY %COMPUTERNAME% /DOMAIN:%NETDOM_DOMAIN% || GoTo skip4
GoTo fdomain

:fdomain
:: FUNCTION Join the DOMAIN
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION Joining domain entered! >> %LOG_LOCATION%\%LOG_FILE%
cls
ECHO Supply the domain account [%NETDOM_DOMAIN%\%NETDOM_USERD%] password to join [%NETDOM_DOMAIN%] domain:
NETDOM JOIN %COMPUTERNAME% /DOMAIN:%NETDOM_DOMAIN% /USERD:%NETDOM_USERD% /PASSWORDD:%NETDOM_PASSWORDD% /REBoot:%NETDOM_REBOOT% || GoTo err31
IF %ERRORLEVEL% EQU 0 ECHO %DATE% %TIME% Joined [%NETDOM_DOMAIN%] domain >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Joined [%NETDOM_DOMAIN%] domain!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds! >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
:: Going to function end time to prepare for a reboot
GoTo feTime

:skip4
:: Skip 4 means the computer has already been joined to the domain
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip4 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% ECHO %DATE% %TIME% %COMPUTERNAME% has already been joined to the domain [%USERDOMAIN%]! >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%COMPUTERNAME% has already been joined to the domain [%USERDOMAIN%]! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step5
:: Will process a chocolatey script. Recommend running 'upgrade'
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step5 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap5
:: TRAP 5 to catch if Chocolatey has already run
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap5 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% GoTo skip5
IF %CHOCO_PRESENCE% EQU 0 GoTo err5
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap5 exit! >> %LOG_LOCATION%\%LOG_FILE%
GoTo trap51

:trap51
:: TRAP 5.1 to see if Advanced CHOCOLATEY is turned on
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap5.1 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCOLATEY_ADVANCED% EQU 1 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CHOCOLATEY ADVANCED is turned on [%CHOCOLATEY_ADVANCED%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCOLATEY_ADVANCED% EQU 0 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CHOCOLATEY ADVANCED is turned off [%CHOCOLATEY_ADVANCED%]!) >> %LOG_LOCATION%\%LOG_FILE%
:: If Advanced CHOCOLATEY is turned on go to the sub-routine
IF %CHOCOLATEY_ADVANCED% EQU 1 GoTo subr3
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap5.1 exit! >> %LOG_LOCATION%\%LOG_FILE%

:fchoco
:: Check if available first
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION Chocolatey entered! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %CHOCO_LOCATION%\choco.exe GoTo err5

::	variable combine
SET /P CHOCO_PACKAGE_RUN= < %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%

:: FUNCTION RUN Chocolatey
ECHO %DATE% %TIME% %var_CHOCOLATEY% is running... >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
Choco upgrade %CHOCO_PACKAGE_RUN% /Y
ECHO %DATE% %TIME%: %var_CHOCOLATEY% ran this package list [%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%]! >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
Choco LIST --Local-Only >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_CHOCOLATEY% ran this package list [%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%]! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6

:skip5
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip5 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% Choco LIST --local-only >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_CHOCOLATEY% has already been run! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step6
:: Process Ultimate script file {cleaning, configurations, etc}
::	Author uses Sorcerer's Apprentice as ultimate script file
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	step6 entered! >> %LOG_LOCATION%\%LOG_FILE%

:trap6
:: TRAP6 is to catch if the Ultimat file has been processed
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap6 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% GoTo skip6
IF NOT EXIST %ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME% GoTo err6
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap6 exit! >> %LOG_LOCATION%\%LOG_FILE%

:trap61
:: TRAP 6.1 Self-Preservation against Ultimate commandlet not properly set for Exit /B
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap6.1 entered! >> %LOG_LOCATION%\%LOG_FILE%
FINDSTR /BLC:"EXIT /B" "%ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%" || GoTo err61
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	The Ultimate commandlet meets the Exit /B requirement! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	trap6.1 exit! >> %LOG_LOCATION%\%LOG_FILE%

:fulti
:: FUNCTION Run the Ultimate Commandlet
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION [6] Ultimate commandlet entered! >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME%: Ultimate file [%ULTIMATE_FILE_NAME%] is attempting to run... >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
IF EXIST %ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME% CALL :subr2
:jump2
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Jump2 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 Echo [INFO]	Ultimate file [%ULTIMATE_FILE_NAME%] ran!) >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:skip6
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	skip6 entered! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% ECHO %DATE% %TIME% Ultimate file [%ULTIMATE_FILE_NAME%] has already run! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Ultimate file [%ULTIMATE_FILE_NAME%] has already run! >> %LOG_LOCATION%\%LOG_FILE%
GoTo end


:://///////////////////////////////////////////////////////////////////////////
::	Sub-Routines

:subr1
::	Sub-Routine Chocolatey
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [subr1] Chocolatey installation entered! >> %LOG_LOCATION%\%LOG_FILE%
::	tagged for removal
:: SETLOCAL ENABLEDELAYEDEXPANSION
::	Check for updates on Chocolatey webiste for installation:
::		https://chocolatey.org/install#install-with-cmdexe
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [subr1] just installed Chocolatey with exit code: %ERRORLEVEL% >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %CHOCO_LOCATION%\choco.exe SET CHOCO_PRESENCE=1
IF EXIST %CHOCO_LOCATION%\choco.exe (Choco | FIND "Chocolatey") > %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF EXIST %CHOCO_LOCATION%\choco.exe SET /P var_CHOCOLATEY= < %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	%var_CHOCOLATEY% installed for the first time successfully!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Chocolatey failed to install for the first time!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 1 ECHO %var_CHOCOLATEY% installed for the first time successfully!
IF %CHOCO_PRESENCE% EQU 0 ECHO Chocolatey failed to install for the first time!
::	tagged for removal
:: SETLOCAL DISABLEDELAYEDEXPANSION
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Sub-Routine [subr1] returned CHOCO_PRESENCE:%CHOCO_PRESENCE% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [subr1] exiting! >> %LOG_LOCATION%\%LOG_FILE%
GoTo jump1


:subr2
::	Sub-Routine Ultimate Commandlet
SETLOCAL ENABLEDELAYEDEXPANSION
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Ultimate Commandlet [%ULTIMATE_FILE_NAME%] entered. >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME%: Ultimate commandlet [%ULTIMATE_FILE_NAME%] is running! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
CALL "%ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%"
IF %ERRORLEVEL% EQU 0 (ECHO %DATE% %TIME%: Ultimate file [%ULTIMATE_FILE_NAME%] ran successfully! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%) ELSE (
	ECHO %DATE% %TIME% Ultimate file [%ULTIMATE_FILE_NAME%] did not run successfully! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%)
SETLOCAL DISABLEDELAYEDEXPANSION
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [subr2] exiting! >> %LOG_LOCATION%\%LOG_FILE%
color 9E
GoTo jump2


:subr3
::	Sub-Routine for Advanced CHOCOLATEY
ECHO Processing advanced chocolatey...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [3] Advanced Chocolatey entered. >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	CHOCOLATEY_ADVANCED is set to: [%CHOCOLATEY_ADVANCED%] >> %LOG_LOCATION%\%LOG_FILE%
DIR /B %POST_FLIGHT_DIR% | FIND /I "criteria" || GoTo err51
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO	[DEBUG]	CHOCOLATEY advanced META package list is set to: %CHOCO_META_PACKAGE_LIST% >> %LOG_LOCATION%\%LOG_FILE%
SET ADVANCED_CHOCOLATEY_META_PACKAGE=
:: Advanced Chocolatey List Counter
SET ACL_COUNTER=1
:: Advanced Chocolatey Search Counter
SET ACS_COUNTER=1

:sploop
:: Start the primary loop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Primary Loop started! >> %LOG_LOCATION%\%LOG_FILE%
::	ACMPLS (Advanced Chocolatey Meta Package List Search)
SET ACMPLS=
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACL Advanced Chocolatey List Counter is set to [%ACL_COUNTER%]! >> %LOG_LOCATION%\%LOG_FILE%
::	Using the META package list, find the criteria file
FOR /F "tokens=%ACL_COUNTER%" %%L IN ("%CHOCO_META_PACKAGE_LIST%") DO SET ACMPLS=%%L
IF NOT DEFINED ACMPLS (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACMPLS Advanced Chocolatey Meta Package List Search set to [%ACMPLS%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ACMPLS (IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	ACMPLS Advanced Chocolatey Meta Package List Search nothing was found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ACMPLS GoTo eploop
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACMPLS Advanced Chocolatey Meta Package List Search set to [%ACMPLS%]! >> %LOG_LOCATION%\%LOG_FILE%
FOR /F "tokens=%ACL_COUNTER%" %%L IN ("%CHOCO_META_PACKAGE_LIST%") DO (
	IF EXIST "%CHOCO_PACKAGE_LIST_LOCATION%\criteria_Chocolatey_%%L_Packages.txt" SET ADVANCED_CHOCOTALEY_CRITERIA_FILE=criteria_Chocolatey_%%L_Packages.txt)
IF DEFINED ADVANCED_CHOCOTALEY_CRITERIA_FILE (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ADVANCED_CHOCOTALEY_CRITERIA_FILE just got set to [%ADVANCED_CHOCOTALEY_CRITERIA_FILE%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST "%CHOCO_PACKAGE_LIST_LOCATION%\%ADVANCED_CHOCOTALEY_CRITERIA_FILE%" SET /P ACSC= < "%CHOCO_PACKAGE_LIST_LOCATION%\%ADVANCED_CHOCOTALEY_CRITERIA_FILE%"
IF DEFINED ACSC (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACSC Advanced Chocolatey Search Criteria just got set to [%ACSC%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS SET /A "ACL_COUNTER=ACL_COUNTER+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACL Advanced Chocolatey List Counter is set to [%ACL_COUNTER%]! >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS SET ACS_COUNTER=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ACS Advanced Chocolatey Search Counter is set to [%ACS_COUNTER%]! >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS (GoTo ssloop) ELSE (GoTo esloop)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Primary Loop exit! >> %LOG_LOCATION%\%LOG_FILE%


:ssloop
:: start the secondary loop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Secondary loop started! >> %LOG_LOCATION%\%LOG_FILE%
SET CSW=
FOR /F "tokens=%ACS_COUNTER%" %%W IN ("%ACSC%") DO SET CSW=%%W
IF DEFINED CSW (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CSW Chocolatey Search Word set to [%CSW%]!) >> %LOG_LOCATION%\%LOG_FILE%
:: If criteria search word is not defined there were no more search terms
IF NOT DEFINED CSW (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CSW Chocolatey Search Word no search term found!) >> %LOG_LOCATION%\%LOG_FILE%
:: If CSW is not set, that means there are no more search terms
IF NOT DEFINED CSW GoTo sploop
FOR /F "tokens=%ACS_COUNTER%" %%S IN ("%ACSC%") DO ((ECHO %COMPUTERNAME%) | FIND /I "%%S")
IF %ERRORLEVEL% EQU 0 SET ADVANCED_CHOCOLATEY_META_PACKAGE=%ACMPLS%
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	ADVANCED_CHOCOLATEY_META_PACKAGE is set to [%ADVANCED_CHOCOLATEY_META_PACKAGE%]!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE SET /A "ACS_COUNTER=ACS_COUNTER+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG] ACS_COUNTER is now set to [%ACS_COUNTER%] >> %LOG_LOCATION%\%LOG_FILE%
:: fail safe?
IF %ACS_COUNTER% GTR 20 GoTo sploop
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE GoTo eploop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Secondary loop exit! >> %LOG_LOCATION%\%LOG_FILE%
GoTo ssloop
:: end the secondary loop
:esloop

:: end the primary loop
:eploop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine Primary ^& Secondary loops exited! >> %LOG_LOCATION%\%LOG_FILE%
:: Always defaults to the Universal CHOCO_PACKAGE
:: SET CHOCO_META_PACKAGE=Universal
:: SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE SET CHOCO_META_PACKAGE=%ADVANCED_CHOCOLATEY_META_PACKAGE%
IF DEFINED CHOCO_META_PACKAGE SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CHOCO_META_PACKAGE is now set to [%CHOCO_META_PACKAGE%]! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	CHOCO_PACKAGE_LIST_FILE is now set to [%CHOCO_PACKAGE_LIST_FILE%]! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE% SET CHOCOLATEY_ADVANCED=0
IF EXIST %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Package list file is set to [%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%]!) >> %LOG_LOCATION%\%LOG_FILE%
ECHO The following Choco list will be used: %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Sub-Routine [3] Advanced Chocolatey exiting. >> %LOG_LOCATION%\%LOG_FILE%
GoTo fchoco

:://///////////////////////////////////////////////////////////////////////////

::*****************************************************************************

:end
:: Processing end
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	end entered! >> %LOG_LOCATION%\%LOG_FILE%
::	Check to see if everything has actually run
::		current actions is a total of %PROCESS_CHECK_NUMBER%
SET PROCESS_COUNT=0
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	PROCESS_COUNT reset to: %PROCESS_COUNT% >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% SET /A PROCESS_COUNT+=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Current Process Count: %PROCESS_COUNT% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Process Check Number: %PROCESS_CHECK_NUMBER% >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_1_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_1_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_1_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_2_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_2_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_2_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_3_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_3_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_3_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_4_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_4_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_4_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_5_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_5_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_5_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_6_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_6_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_6_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
:: Logging output for COMPLETE OR INCOMPLETE
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	%PROCESS_COMPLETE_FILE% just got created!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Post-Flight completed %PROCESS_COUNT% tasks!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% ECHO %DATE% %TIME% POST-FLIGH is INCOMPLETE! Check main log [%LOG_FILE%] for details! >> %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log
IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	[INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log] just got created!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	POST-FLIGH is INCOMPLETE!) >> %LOG_LOCATION%\%LOG_FILE%

:: Text file cleanup when everything is complete
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log DEL /F /Q %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log)
IF EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log (TYPE %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%) && DEL /F /Q %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
:endc
:: ending when complete (this is a jump spot for err10 --when everything is already done).
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Ending for complete entered! >> %LOG_LOCATION%\%LOG_FILE%
:: 	the following var_files get created each time the commandlet runs 
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt DEL /F /Q %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt)
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_whoami.txt DEL /F /Q %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_whoami.txt)
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_systeminfo.txt DEL /F /Q %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_systeminfo.txt)
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_ver.txt DEL /F /Q %LOG_LOCATION%\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_ver.txt)
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\var_NETDOM_INSTALL.txt DEL /F /Q %LOG_LOCATION%\var_NETDOM_INSTALL.txt)
IF EXIST %POST_FLIGHT_DIR% DEL /F /Q /A:H %POST_FLIGHT_DIR%\*.*
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% DEL /F /Q /A:H %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE%
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% DEL /F /Q /A:H %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE%
IF EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log DEL /F /Q %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
::	Seed location cleanup
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	SEED cleanup entered! >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Leaving SEED LOCATION contents!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	SEED_LOCATION_CLEANUP is set to: %SEED_LOCATION_CLEANUP% >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Cleaning up SEED LOCATION [%POST_FLIGHT_DIR%], but leaving logs) >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 1 (ROBOCOPY %POST_FLIGHT_DIR% %POST_FLIGHT_DIR%\TOBEDELETED *.* /S /E /MOVE /R:1 /W:2 /XF %SCRIPT_NAME%.cmd /XD Logs TOBEDELETED)
IF EXIST %POST_FLIGHT_DIR%\TOBEDELETED RD /S /Q %POST_FLIGHT_DIR%\TOBEDELETED
IF %SEED_LOCATION_CLEANUP% EQU 1 (IF NOT EXIST %POST_FLIGHT_DIR%\TOBEDELETED (IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	SEED LOCATION [%POST_FLIGHT_DIR%] has been cleaned up!)) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	SEED cleanup end! >> %LOG_LOCATION%\%LOG_FILE%

::	Avoid ERROR Section
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	end exiting! >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: START ERROR SECTION

:err000
:: ERROR 000 FATAL ERROR for folder cannot be created
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error000 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO [FATAL]	Folder [%LOG_LOCATION%] could not be created! Aborting! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error000 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err0
:: ERROR 0 (NETDOM)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error0 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	NETDOM is not installed! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Aborting %SCRIPT_NAME%! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error0 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err1
:: ERROR 1 (No Host Database Found)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error1 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	The Host File database was not found! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO [DEBUG]	Looking for: %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO [FATAL]	Aborting %SCRIPT_NAME% due to host file database [%HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE%] NOT FOUND! >> %LOG_LOCATION%\%LOG_FILE%
ECHO FATAL ERROR: NO HOST DATABASE FOUND! ABORTING!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error1 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err3
::	ERROR 3 (Failed to rename computer & Failed to join a domain)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error3 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	DEPENDENCY FAILURE: Can't Rename computer! NETDOM is not present! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	DEPENDENCY FAILURE: Can't join a Windows Domain! NETDOM is not present! >> %LOG_LOCATION%\%LOG_FILE%
:: SET /A "PROCESS_CHECK_NUMBER-=2"
:: ECHO [INFO]	PROCESS_CHECK_NUMBER has been reset to: %PROCESS_CHECK_NUMBER% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error3 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err31
::	ERROR 3.1 (Computer failed to join)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error31 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	NETDOM failed to join the computer [%COMPUTERNAME%]to domain [%NETDOM_DOMAIN%]! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Aborting joining the domain! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error31 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err2
:: ERROR 2 (Failed to join Domain)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error2 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Failed to join domain! [%NETDOM_DOMAIN%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO [WARN]	Aborting Domain join! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error2 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err5
:: ERROR 5 (Chocolatey is not present)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error6 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Chocolatey is not present! Aborting Chocolatey step! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Expecting Chocolatey to be here: %CHOCO_LOCATION%\choco.exe >> %LOG_LOCATION%\%LOG_FILE%
:: SET /A "PROCESS_CHECK_NUMBER-=1"
:: ECHO [INFO]	PROCESS_CHECK_NUMBER has been reset to: %PROCESS_CHECK_NUMBER% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error5 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6

:err51
:: ERROR 5.1 (Advanced Chocolatey error catching for NO criteria files)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error5.1 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO	[ERROR]	No chocolatey criteria files found! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO	[ERROR]	Aborting advanced chocolatey! >> %LOG_LOCATION%\%LOG_FILE%
SET CHOCOLATEY_ADVANCED=0
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error5.1 >> %LOG_LOCATION%\%LOG_FILE%
:: return to normal chocolatey package install
GoTo step5

:err6
:: ERROR 6 (Ulimate file cannot be found or is off-line)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error6 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	FAILED to load Ultimate FILE [%ULTIMATE_FILE_NAME%] from %ULTIMATE_FILE_LOCATION% >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %ULTIMATE_FILE_LOCATION% ECHO [ERROR]	Ultimate file location [%ULTIMATE_FILE_LOCATION%] is OFF-LINE! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO [ERROR]	Aborting running [%ULTIMATE_FILE_NAME%]!
:: SET /A "PROCESS_CHECK_NUMBER-=1"
:: ECHO PROCESS_CHECK_NUMBER has been reset to: %PROCESS_CHECK_NUMBER% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error6 >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:err61
:: ERROR 6.1 (Ulimate file doesn't meet the exit requirements) commandlet self-presevation
IF %LOG_LEVEL_TRACE% EQU 1 ECHO	[TRACE]	Entered error6.1 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO	[ERROR]	The Ultimate commandlet [%ULTIMATE_FILE_NAME%] doesn't meet the "EXIT /B" requirement! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO	[WARN]	Aborting running the Ultimate commandlet [%ULTIMATE_FILE_NAME%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO	[TRACE]	Exit error6.1 >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:err10
:: ERROR (Everything already ran)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Entered error10 >> %LOG_LOCATION%\%LOG_FILE%
ECHO [INFO]	EVERYTHING IS ALREADY DONE? >> %LOG_LOCATION%\%LOG_FILE%
ECHO [INFO]	%PROCESS_COMPLETE_FILE% Exists! >> %LOG_LOCATION%\%LOG_FILE%
ECHO [INFO]	Aborting %SCRIPT_NAME%! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% ECHO %DATE% %TIME% %SCRIPT_NAME%_%SCRIPT_VERSION% ATTEMPTED BUT ABORTED! >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	Exit error10 >> %LOG_LOCATION%\%LOG_FILE%
GoTo endc

:: END ERROR SECTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:feTime
:: FUNCTION: End Time
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION end time entered! >> %LOG_LOCATION%\%LOG_FILE%

:: Calculate lapse time by capturing end time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET E_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET E_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET E_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET E_ms=%%h
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	E_hh: %E_hh%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	E_mm: %E_mm%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	E_ss: %E_ss%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO [DEBUG]	E_mm: %E_mm%) >> %LOG_LOCATION%\%LOG_FILE%

:: Calculate the actual lapse time
IF %E_hh% GEQ %S_hh% (SET /A "L_hh=%E_hh%-%S_hh%") ELSE (SET /A "L_hh=%S_hh%-%E_hh%")
IF %E_mm% GEQ %S_mm% (SET /A "L_mm=%E_mm%-%S_mm%") ELSE (SET /A "L_mm=%S_mm%-%E_mm%")
IF %E_ss% GEQ %S_ss% (SET /A "L_ss=%E_ss%-%S_ss%") ELSE (SET /A "L_ss=%S_ss%-%E_ss%")
IF %E_ms% GEQ %S_ms% (SET /A "L_ms=%E_ms%-%S_ms%") ELSE (SET /A "L_ms=%S_ms%-%E_ms%")
:: turn hours into minutes and add to total minutes
IF %L_hh% GTR 0 SET /A "L_hhh=%L_hh%*60"
IF %L_hh% EQU 0 SET L_hhh=0
IF %L_hhh% GTR 0 SET /A "L_tm=%L_hhh%+%L_mm%"
IF %L_hhh% EQU 0 SET L_tm=%L_mm%
:: Lapse Time
IF %LOG_LEVEL_INFO% EQU 1 ECHO [INFO]	Time Lapsed (mm:ss.ms): %L_tm%:%L_ss%.%L_ms% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	FUNCTION end time is exiting! >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:EOF
:: END OF FILE
IF %LOG_LEVEL_TRACE% EQU 1 ECHO [TRACE]	end of file entered! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 Echo [INFO]	END %DATE% %TIME% >> %LOG_LOCATION%\%LOG_FILE%
ECHO END %DATE% %TIME%
Echo. >> %LOG_LOCATION%\%LOG_FILE%
TIMEOUT 30
ENDLOCAL
EXIT