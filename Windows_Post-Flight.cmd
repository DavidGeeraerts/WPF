:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		Windows Post-Flight Tool
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Git Information
::  GitHub [https://github.com]
::  GitHub Repository Name: WPF
::  HTTPS URI (for cloning)
::   (https://github.com/DavidGeeraerts/WPF.git)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
SETLOCAL Enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET SCRIPT_NAME=Windows_Post-Flight
SET SCRIPT_VERSION=2.1.0
Title %SCRIPT_NAME% Version: %SCRIPT_VERSION%
mode con:cols=80
mode con:lines=50
Prompt WPF$G
color 9E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::###########################################################################::
:: Declare Global variables as Defaults
::  configuration file will override all default settings
:: All User variables are set within here.
::###########################################################################::


::###########################################################################::
:: Configuration File Settings
::   and dependency check for configuration file!
::###########################################################################::
REM This has to be first to check that a configuration file actually exists

:://///////////////////////////////////////////////////////////////////////////
SET CONFIG_FILE_NAME=%SCRIPT_NAME%.config
SET WPF_CONFIG_SCHEMA_VERSION_MIN=2.0.0
IF NOT EXIST %~dp0\%CONFIG_FILE_NAME% GoTo errCONF
:://///////////////////////////////////////////////////////////////////////////


:: Working Directory for Post-Flight
::  this is also the (local storage) seed location for Post-Flight
SET "POST_FLIGHT_DIR=%ProgramData%\%SCRIPT_NAME%"
SET "POST_FLIGHT_CMD_NAME=Windows_Post-Flight.cmd"

:: Log Files Settings
::  Main script log file
:: %LOG_LOCATION%\%LOG_FILE%
SET "LOG_LOCATION=%ProgramData%\%SCRIPT_NAME%\Logs"
SET LOG_FILE=Windows_Post-Flight_%SCRIPT_VERSION%.Log

:: FLASH Drive
::  provide the label for the flash drive
::  flash drive should contain all of the necessary files, especially if not preseeded in the working directory
SET FLASH_DRIVE_VOLUME_LABEL=POSTFLIGHT

:: File that contains host 'database'
::  FLASH DRIVE acts as the backup & update location for HOST_FILE_DATABASE (& OTHER assets)
::   format
::    #Hostname #MAC 00-00-00-00-00-00
::    %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE%
::    this is the location and file name where the commandlet expects it
::    commandlet will auto-update from [source] flash drive to destination
SET "HOST_FILE_DATABASE_LOCATION=%POST_FLIGHT_DIR%"
SET HOST_FILE_DATABASE=Host_MAC_List.txt

:: Default Host name from Unattend.xml file
SET DEFAULT_HOSTNAME=RENAME
:: Default User from Unattend.xml file
SET DEFAULT_USER=WindowsPostFlightUser

:: Local Administrator Password
::  assumes it will be in the working directory
SET LOCAL_ADMIN_PW_FILE=Local_Administrator_Password.txt

:: Hard Drive Configuration
::  assumes it will be in the working directory
SET DISKPART_COMMAND_FILE=DiskPart_Hard_Drive_Config.txt


:: Chocolatey
::  Universal as default
SET CHOCO_META_PACKAGE=Universal
::  location & name
SET CHOCO_PACKAGE_LIST_LOCATION=%POST_FLIGHT_DIR%
SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt

:: Ultimate Commandlet configurations
::  %ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%
SET "ULTIMATE_FILE_LOCATION=%POST_FLIGHT_DIR%"
SET ULTIMATE_FILE_NAME=


::###########################################################################::
::            *******************
::            Advanced Settings 
::            *******************
::###########################################################################::
:: sub-file names for each process --configured to output in LOG_LOCATION
:: Process 1: Local Administrator configuration
SET PROCESS_1_FILE_NAME=RAN_Administrator_configured_%SCRIPT_VERSION%.txt
:: Process 2: Process Disk condifuration
SET PROCESS_2_FILE_NAME=RAN_DiskPart_%SCRIPT_VERSION%.txt
:: Process 3: Change the hostname
SET PROCESS_3_FILE_NAME=RAN_Hostname_Changed_%SCRIPT_VERSION%.txt
:: Process 4: Join a Windows Domain
SET PROCESS_4_FILE_NAME=RAN_Domain_Joined_%SCRIPT_VERSION%.txt
:: Process 5: Run Chocolatey
SET PROCESS_5_FILE_NAME=RAN_Chocolatey_%SCRIPT_VERSION%.txt
:: Process 6: Run Ultimate script
SET PROCESS_6_FILE_NAME=RAN_Ultimate_%SCRIPT_VERSION%.txt

:: Completed File name
SET PROCESS_COMPLETE_FILE=COMPLETED_%SCRIPT_NAME%_%SCRIPT_VERSION%.log


:: To cleanup or Not to cleanup, the seed location
::  0 = OFF (NO)
::  1 = ON (YES)
SET SEED_LOCATION_CLEANUP=1

:: Chocolatey advanced
::  turn on advanced Chocolatey package assignment based on hostname criteria
::  each package list must be paired with criteria_Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt file 
::   i.e. criteria_Chocolatey_Universal_Packages.txt
::   0 = OFF (NO)
::   1= ON (YES)
SET CHOCOLATEY_ADVANCED=1
::  the list should be in a hierchical order
::  once a match is found  it will be applied
SET "CHOCO_META_PACKAGE_LIST=Universal"

:: LOGGING LEVEL CONTROL
::  by default, ALL=0 & TRACE=0
SET LOG_LEVEL_ALL=0
SET LOG_LEVEL_INFO=1
SET LOG_LEVEL_WARN=1
SET LOG_LEVEL_ERROR=1
SET LOG_LEVEL_FATAL=1
SET LOG_LEVEL_DEBUG=0
SET LOG_LEVEL_TRACE=0

:: PROCESS CHECK
::  (possible future expansion)
::  check against this number of actions
::   default is 6
::   {(1)Disk Configuration; (2)Hostname change; (3)Local Administrator; (4)Join a domain; (5)run Chocolatey, (6)run Ultimate script}
SET PROCESS_CHECK_NUMBER=6


:: Miscellaneous


::###########################################################################::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::																			 ::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####			 ::
::																			 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fsTime
:: FUNCTION: Start Time
:: Calculate lapse time by capturing start time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET S_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET S_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET S_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET S_ms=%%h
::	variables are debugged in the DEBUGER section
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:fmanualISO
:: Manually create the ISO 8601 date format
::	this assumes the format of mm/dd/yyyy
IF DEFINED ISO_DATE GoTo skipfmiso
FOR /F "tokens=2 delims=/ " %%T IN ("%DATE%") DO SET ISO_MONTH=%%T
FOR /F "tokens=3 delims=/ " %%T IN ("%DATE%") DO SET ISO_DAY=%%T
FOR /F "tokens=4 delims=/ " %%T IN ("%DATE%") DO SET ISO_YEAR=%%T
SET ISO_DATE=%ISO_YEAR%-%ISO_MONTH%-%ISO_DAY%

:skipfmiso
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: USER
::	user should be a domain user for everything to run properly
WHOAMI /FQDN && SET DOMAIN_USER_STATUS=1
IF DEFINED DOMAIN_USER_STATUS GoTo skipD1
WHOAMI /FQDN || SET DOMAIN_USER_STATUS=0
:skipD1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Console Output
ECHO %ISO_DATE% %TIME%	START...
ECHO %SCRIPT_NAME% %SCRIPT_VERSION%
ECHO.
ECHO Processing the configuration file {%SCRIPT_NAME%.config}...
ECHO.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: CONFIGURATION FILE OVERRIDE
::###########################################################################::
:: START CONFIGURATION FILE LOAD

ECHO Processing configuration file...
ECHO {%CONFIG_FILE_NAME%}...

REM Any configuration variable being pulled from the configuration file that is using another variable
REM  needs to be reset so as not to take the string from the configuration file literally.
REM  This solves the problem when build in variables are used such as %PROGRAMDATA%
REM EXAMPLE: FOR /F %%R IN ('ECHO %VARIABLE%') DO SET VARIABLE=%%R
::  FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"variable" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "variable=%%V"
::   WPF_CONFIG_SCHEMA_VERSION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WPF_CONFIG_SCHEMA_VERSION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WPF_CONFIG_SCHEMA_VERSION=%%V"
:: CHECK the Config file Schema version meets the minimum requirement
SET WPF_CONFIG_FILE_SCHEMA_CHECK=0
::  Parse schema version from configuration file
FOR /F "tokens=1 delims=." %%V IN ("%WPF_CONFIG_SCHEMA_VERSION%") DO SET WPF_CONFIG_SCHEMA_VERSION_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%WPF_CONFIG_SCHEMA_VERSION%") DO SET WPF_CONFIG_SCHEMA_VERSION_MINOR=%%V
::  Parse schema version from minimum
FOR /F "tokens=1 delims=." %%V IN ("%WPF_CONFIG_SCHEMA_VERSION_MIN%") DO SET WPF_CONFIG_SCHEMA_VERSION_MIN_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%WPF_CONFIG_SCHEMA_VERSION_MIN%") DO SET WPF_CONFIG_SCHEMA_VERSION_MIN_MINOR=%%V
::  actual check
IF %WPF_CONFIG_SCHEMA_VERSION_MAJOR% GEQ %WPF_CONFIG_SCHEMA_VERSION_MIN_MAJOR% (SET WPF_CONFIG_FILE_SCHEMA_CHECK=1) ELSE (GoTo err03)
IF %WPF_CONFIG_FILE_SCHEMA_CHECK% EQU 1 GoTo skipSC
IF %WPF_CONFIG_SCHEMA_VERSION_MINOR% GEQ %WPF_CONFIG_SCHEMA_VERSION_MIN_MINOR% (SET WPF_CONFIG_FILE_SCHEMA_CHECK=1) ELSE (
     ECHO The configuration file [%CONFIG_FILE_NAME%] is using an older schema, and doesn't meet the minimum requirement!)
IF %WPF_CONFIG_FILE_SCHEMA_CHECK% EQU 0 ECHO Minimum MINOR schema version not met. Will proceed anyway!
:skipSC
::   POST_FLIGHT_DIR
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"POST_FLIGHT_DIR" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "POST_FLIGHT_DIR=%%V"
FOR /F %%R IN ('ECHO %POST_FLIGHT_DIR%') DO SET POST_FLIGHT_DIR=%%R
::   POST_FLIGHT_CMD_NAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"POST_FLIGHT_CMD_NAME" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "POST_FLIGHT_CMD_NAME=%%V"
::   FLASH_DRIVE_VOLUME_LABEL
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"FLASH_DRIVE_VOLUME_LABEL" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "FLASH_DRIVE_VOLUME_LABEL=%%V"
::   HOST_FILE_DATABASE_LOCATION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"HOST_FILE_DATABASE_LOCATION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "HOST_FILE_DATABASE_LOCATION=%%V"
FOR /F %%R IN ('ECHO %HOST_FILE_DATABASE_LOCATION%') DO SET HOST_FILE_DATABASE_LOCATION=%%R
::   HOST_FILE_DATABASE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"HOST_FILE_DATABASE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "HOST_FILE_DATABASE=%%V"
::   DEFAULT_HOSTNAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"DEFAULT_HOSTNAME" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "DEFAULT_HOSTNAME=%%V"
::   DEFAULT_USER
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"DEFAULT_USER" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "DEFAULT_USER=%%V"
::   LOCAL_ADMIN_PW_FILE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOCAL_ADMIN_PW_FILE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOCAL_ADMIN_PW_FILE=%%V"
::   DISKPART_COMMAND_FILE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"DISKPART_COMMAND_FILE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "DISKPART_COMMAND_FILE=%%V"
::   NETDOM_DOMAIN
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"NETDOM_DOMAIN" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "NETDOM_DOMAIN=%%V"
::   NETDOM_USERD
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"NETDOM_USERD=" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "NETDOM_USERD=%%V"
::   NETDOM_PASSWORDD
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"NETDOM_PASSWORDD" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "NETDOM_PASSWORDD=%%V"
::   NETDOM_USERD_PW_FILE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"NETDOM_USERD_PW_FILE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "NETDOM_USERD_PW_FILE=%%V"
::   NETDOM_REBOOT
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"NETDOM_REBOOT" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "NETDOM_REBOOT=%%V"
::   AD_NETLOGON
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"AD_NETLOGON" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "AD_NETLOGON=%%V"
::   CHOCO_META_PACKAGE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"CHOCO_META_PACKAGE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "CHOCO_META_PACKAGE=%%V"
::   CHOCO_PACKAGE_LIST_LOCATION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"CHOCO_PACKAGE_LIST_LOCATION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "CHOCO_PACKAGE_LIST_LOCATION=%%V"
FOR /F %%R IN ('ECHO %CHOCO_PACKAGE_LIST_LOCATION%') DO SET CHOCO_PACKAGE_LIST_LOCATION=%%R
::   CHOCO_PACKAGE_LIST_FILE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"CHOCO_PACKAGE_LIST_FILE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "CHOCO_PACKAGE_LIST_FILE=%%V"
FOR /F %%R IN ('ECHO %CHOCO_PACKAGE_LIST_FILE%') DO SET CHOCO_PACKAGE_LIST_FILE=%%R
::   ULTIMATE_FILE_LOCATION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ULTIMATE_FILE_LOCATION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "ULTIMATE_FILE_LOCATION=%%V"
FOR /F %%R IN ('ECHO %ULTIMATE_FILE_LOCATION%') DO SET ULTIMATE_FILE_LOCATION=%%R
::   ULTIMATE_FILE_NAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"ULTIMATE_FILE_NAME" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "ULTIMATE_FILE_NAME=%%V"
::   LOG_LOCATION
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LOCATION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LOCATION=%%V"
FOR /F %%R IN ('ECHO %LOG_LOCATION%') DO SET LOG_LOCATION=%%R
::   LOG_FILE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_FILE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_FILE=%%V"
FOR /F %%R IN ('ECHO %LOG_FILE%') DO SET LOG_FILE=%%R
::  Log shipping
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_SHIPPING_LOCATION" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_SHIPPING_LOCATION=%%V"
FOR /F %%R IN ('ECHO %LOG_SHIPPING_LOCATION%') DO SET LOG_SHIPPING_LOCATION=%%R


:: Advanced Settings
::   SEED_LOCATION_CLEANUP
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"SEED_LOCATION_CLEANUP" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "SEED_LOCATION_CLEANUP=%%V"
::   CHOCOLATEY_ADVANCED
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"CHOCOLATEY_ADVANCED" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "CHOCOLATEY_ADVANCED=%%V"
::   CHOCO_META_PACKAGE_LIST
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"CHOCO_META_PACKAGE_LIST" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "CHOCO_META_PACKAGE_LIST=%%V"
::   LOG_LEVEL_ALL
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_ALL" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_ALL=%%V"
::   LOG_LEVEL_INFO
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_INFO" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_INFO=%%V"
::   LOG_LEVEL_WARN
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_WARN" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_WARN=%%V"
::   LOG_LEVEL_ERROR
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_ERROR" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_ERROR=%%V"
::   LOG_LEVEL_FATAL
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_FATAL" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_FATAL=%%V"
::   LOG_LEVEL_DEBUG
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_DEBUG" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_DEBUG=%%V"
::   LOG_LEVEL_TRACE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"LOG_LEVEL_TRACE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "LOG_LEVEL_TRACE=%%V"
:: DEBUGGER
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"DEBUGGER" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "DEBUGGER=%%V"
::   RSAT_PACKAGE_W10x64
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"RSAT_PACKAGE_W10x64" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "RSAT_PACKAGE_W10x64=%%V"
::   WIRELESS_SETUP
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WIRELESS_SETUP" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WIRELESS_SETUP=%%V"
::   WIRELESS_CONFIG_NAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WIRELESS_CONFIG_NAME" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WIRELESS_CONFIG_NAME=%%V"
::   WIRELESS_CONFIG_SSID
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WIRELESS_CONFIG_SSID" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WIRELESS_CONFIG_SSID=%%V"
::   WIRELESS_CONFIG_INTERFACE
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WIRELESS_CONFIG_INTERFACE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WIRELESS_CONFIG_INTERFACE=%%V"
::   WIRELESS_PROFILE_FILENAME
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"WIRELESS_PROFILE_FILENAME" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "WIRELESS_PROFILE_FILENAME=%%V"

ECHO Processing configuration file complete!

:: END CONFIGURATION FILE LOAD
::###########################################################################::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: CHECK TO MAKE SURE LOG LOCATION WORKS!
IF NOT EXIST %LOG_LOCATION% MD %LOG_LOCATION% || GoTo err00
IF NOT EXIST "%LOG_LOCATION%\var" MD "%LOG_LOCATION%\var" || GoTo err00
IF NOT EXIST "%LOG_LOCATION%\%LOG_FILE%" ECHO First Time Run: %ISO_DATE% %TIME% > %LOG_LOCATION%\FirstTimeRun.txt
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [INFO]	START...) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	ALL logging is turned on from config file!) >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED POST_FLIGHT_DIR CD /D %POST_FLIGHT_DIR%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	DEBUGGER
:: Computer used for debugging so that automatic ALL logging is on
HOSTNAME | FIND /I "%DEBUGGER%" && SET LOG_LEVEL_ALL=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:flogl
:: FUNCTION: Check and configure for ALL LOG LEVEL
IF %LOG_LEVEL_ALL% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	START... >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: function Check for ALL log level!) ELSE (
	IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: function Check for ALL log level!) 
	) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_INFO=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_WARN=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_ERROR=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_FATAL=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_DEBUG=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_TRACE=1
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: function Check for ALL log level!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:start
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: function Start!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	START... >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FirstTimeRun.txt (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {FirstTimeRun.txt} was created!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FirstTimeRun.txt (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	WPF first time run!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST "%LOG_LOCATION%\var\var_systeminfo_TimeZone.txt" (
	FOR /F "tokens=2-3 delims=(" %%S IN ('systeminfo ^| FIND /I "Time Zone"') Do ECHO Time Zone: ^(%%S^(%%T > "%LOG_LOCATION%\var\var_systeminfo_TimeZone.txt"
	) && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_systeminfo_TimeZone.txt} just got created! >> %LOG_LOCATION%\%LOG_FILE%
SET /P var_TimeZone= < "%LOG_LOCATION%\var\var_systeminfo_TimeZone.txt"
::	var_TimeZone has to be quoted for output due to "&" special character
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_TimeZone% >> %LOG_LOCATION%\%LOG_FILE%
ECHO Logs can be found here: %LOG_LOCATION%
ECHO Log file for WPF: %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	SCRIPT_VERSION: {%SCRIPT_VERSION%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Minimum config file {%CONFIG_FILE_NAME%} version {%WPF_CONFIG_SCHEMA_VERSION_MIN%} >> %LOG_LOCATION%\%LOG_FILE%
whoami > "%LOG_LOCATION%\var\var_whoami.txt"
IF EXIST "%LOG_LOCATION%\var\var_whoami.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_whoami.txt} just got created or updated! >> %LOG_LOCATION%\%LOG_FILE%
SET /P var_WHOAMI= < %LOG_LOCATION%\var\var_whoami.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_WHOAMI% >> %LOG_LOCATION%\%LOG_FILE%
IF %DOMAIN_USER_STATUS% EQU 1 whoami /FQDN > %LOG_LOCATION%\var\var_whoami_fqdn.txt
IF %DOMAIN_USER_STATUS% EQU 1 IF EXIST "%LOG_LOCATION%\var\var_whoami_fqdn.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_whoami_fqdn.txt} just got created or updated! >> %LOG_LOCATION%\%LOG_FILE%
SET /P var_WHOAMI_FQDN= < %LOG_LOCATION%\var\var_whoami_fqdn.txt
IF EXIST %LOG_LOCATION%\var\var_whoami_fqdn.txt IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	FQDN: %var_WHOAMI_FQDN% >> %LOG_LOCATION%\%LOG_FILE%
:: fancy parsing for proper output of info
IF NOT EXIST "%LOG_LOCATION%\var\var_systeminfo.txt" (systeminfo > %LOG_LOCATION%\var\var_systeminfo.txt) && (
	IF EXIST "%LOG_LOCATION%\var\var_systeminfo.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_systeminfo.txt} just got created! >> %LOG_LOCATION%\%LOG_FILE%
	)

IF NOT EXIST %LOG_LOCATION%\var\var_systeminfo_OsName.txt (
     FOR /F "tokens=3-6" %%G IN ('systeminfo ^| FIND /I "OS NAME"') DO ECHO OS Name: %%G %%H %%I %%J > %LOG_LOCATION%\var\var_systeminfo_OsName.txt
	 ) && (IF EXIST "%LOG_LOCATION%\var\var_systeminfo_OsName.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_systeminfo_OsName.txt} just got created! >> %LOG_LOCATION%\%LOG_FILE%
		)
SET /P var_SYSTEMINFO= < %LOG_LOCATION%\var\var_systeminfo.txt
SET /P var_SYSTEMINFO_OSNAME= < %LOG_LOCATION%\var\var_systeminfo_OsName.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_SYSTEMINFO_OSNAME% >> %LOG_LOCATION%\%LOG_FILE%
:: Get Windows version (Based on release ID --more relevant for Windows 10)
IF NOT EXIST "%LOG_LOCATION%\var\var_Windows_Version.txt" (
	FOR /F "tokens=3 delims= " %%R IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ReleaseId') DO ECHO %%R> %LOG_LOCATION%\var\var_Windows_Version.txt
	) && IF EXIST "%LOG_LOCATION%\var\var_Windows_Version.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {%LOG_LOCATION%\var\var_Windows_Version.txt} just got created! >> %LOG_LOCATION%\%LOG_FILE%
SET /P var_WINDOWS_VERSION= < %LOG_LOCATION%\var\var_Windows_Version.txt
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_WINDOWS_VERSION: {%var_WINDOWS_VERSION%} >> %LOG_LOCATION%\%LOG_FILE%
VER | FIND /I "Version 10." && (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Windows 10 version: %var_WINDOWS_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
	)
ver > %LOG_LOCATION%\var\var_ver.txt
FOR /F "skip=1 tokens=1 delims=" %%V IN (%LOG_LOCATION%\var\var_ver.txt) DO SET var_VER=%%V
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_VER% >> %LOG_LOCATION%\%LOG_FILE%
FOR /F "tokens=3 delims=:- " %%A IN ('FIND /I "System Type" %LOG_LOCATION%\var\var_systeminfo.txt') DO SET COMPUTER_ARCHITECTURE=%%A
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	COMPUTER_ARCHITECTURE just got set to {%COMPUTER_ARCHITECTURE%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	COMPUTER_ARCHITECTURE: %COMPUTER_ARCHITECTURE% >> %LOG_LOCATION%\%LOG_FILE%
IF "%COMPUTER_ARCHITECTURE%"=="x64" (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Computer meets the x64 computer architecture!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT "%COMPUTER_ARCHITECTURE%"=="x64" GoTo err04
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: DEBUG OUTPUT FOR LOG SETTINGS
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level ALL is {%LOG_LEVEL_ALL%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEGUG]	Log level INFO is {%LOG_LEVEL_INFO%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level WARN is {%LOG_LEVEL_WARN%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level ERROR is {%LOG_LEVEL_ERROR%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level FATAL is {%LOG_LEVEL_FATAL%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level DEBUG is {%LOG_LEVEL_DEBUG%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Log level TRACE is {%LOG_LEVEL_TRACE%} >> %LOG_LOCATION%\%LOG_FILE%

:: Misc. Variables ::
:: RSAT Attempts
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: RSAT Attempts... >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var\var_RSAT_attempt.txt SET RSAT_ATTEMPT=0
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: RSAT_ATTEMPT: {%RSAT_ATTEMPT%} >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_RSAT_attempt.txt SET /P RSAT_ATTEMPT= < %LOG_LOCATION%\var\var_RSAT_attempt.txt
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT:RSAT Attempts. >> %LOG_LOCATION%\%LOG_FILE%
:: SHA 256 Check
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: SHA 256 Check... >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST "%~dp0\%SCRIPT_NAME%_SHA256.txt" IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	 WPF SHA256 txt file not found! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST "%~dp0\%SCRIPT_NAME%_SHA256.txt" SET /P WPF_SHA256= < "%~dp0\%SCRIPT_NAME%_SHA256.txt"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_SHA256: {%WPF_SHA256%} >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST "%LOG_LOCATION%\WPF_SHA256_check.txt" FOR /F "skip=1 tokens=1" %%P IN ('certUtil -hashfile "%~dp0\%POST_FLIGHT_CMD_NAME%" SHA256') DO ECHO %%P>> %LOG_LOCATION%\var\var_WPF_SHA256_check.txt
IF EXIST "%LOG_LOCATION%\var\var_WPF_SHA256_check.txt" SET /P WPF_SHA256_CHECK= < "%LOG_LOCATION%\var\var_WPF_SHA256_check.txt"
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: SHA 256 Check. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:varS
:: Start of variable debug
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Variable debug!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 0 GoTo varE
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE DEBUG is alpha-numeric sorted. >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	Current Directory: {%CD%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_hh: {%S_hh%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_mm: {%S_mm%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_ss: {%S_ss%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_mm: {%S_mm%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: AD_NETLOGON: {%AD_NETLOGON%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CHOCOLATEY_ADVANCED: {%CHOCOLATEY_ADVANCED%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CHOCO_META_PACKAGE_LIST: {%CHOCO_META_PACKAGE_LIST%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CHOCO_META_PACKAGE: {%CHOCO_META_PACKAGE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CHOCO_PACKAGE_LIST_LOCATION: {%CHOCO_PACKAGE_LIST_LOCATION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CHOCO_PACKAGE_LIST_FILE: {%CHOCO_PACKAGE_LIST_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: COMPUTER_ARCHITECTURE: {%COMPUTER_ARCHITECTURE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: CONFIG_FILE_NAME: {%CONFIG_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DEBUGGER: {%DEBUGGER%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DEFAULT_HOSTNAME: {%DEFAULT_HOSTNAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DEFAULT_USER: {%DEFAULT_USER%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DISKPART_COMMAND_FILE: {%DISKPART_COMMAND_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DOMAIN_USER_STATUS: {%DOMAIN_USER_STATUS%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: FLASH_DRIVE_VOLUME_LABEL: {%FLASH_DRIVE_VOLUME_LABEL%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: HOST_FILE_DATABASE_LOCATION: {%HOST_FILE_DATABASE_LOCATION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: HOST_FILE_DATABASE: {%HOST_FILE_DATABASE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: ISO_DATE: {%ISO_DATE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOCAL_ADMIN_PW_FILE: {%LOCAL_ADMIN_PW_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LOCATION: {%LOG_LOCATION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_FILE: {%LOG_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_ALL: {%LOG_LEVEL_ALL%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_DEBUG: {%LOG_LEVEL_DEBUG%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_ERROR: {%LOG_LEVEL_ERROR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_FATAL: {%LOG_LEVEL_FATAL%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_INFO: {%LOG_LEVEL_INFO%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_TRACE: {%LOG_LEVEL_TRACE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_WARN: {%LOG_LEVEL_WARN%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOG_SHIPPING_LOCATION: {%LOG_SHIPPING_LOCATION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: NETDOM_DOMAIN: {%NETDOM_DOMAIN%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: NETDOM_USERD: {%NETDOM_USERD%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: NETDOM_USERD_PW_FILE: {%NETDOM_USERD_PW_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: NETDOM_REBOOT: {%NETDOM_REBOOT%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: POST_FLIGHT_DIR: {%POST_FLIGHT_DIR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: POST_FLIGHT_CMD_NAME: {%POST_FLIGHT_CMD_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_1_FILE_NAME: {%PROCESS_1_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_2_FILE_NAME: {%PROCESS_2_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_3_FILE_NAME: {%PROCESS_3_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_4_FILE_NAME: {%PROCESS_4_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_5_FILE_NAME: {%PROCESS_5_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_6_FILE_NAME: {%PROCESS_6_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_COMPLETE_FILE: {%PROCESS_COMPLETE_FILE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: PROCESS_CHECK_NUMBER: {%PROCESS_CHECK_NUMBER%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: RSAT_PACKAGE_W10x64: {%RSAT_PACKAGE_W10x64%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: RSAT_ATTEMPT: {%RSAT_ATTEMPT%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: SEED_LOCATION_CLEANUP: {%SEED_LOCATION_CLEANUP%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: SCRIPT_NAME: {%SCRIPT_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: SCRIPT_NAME: {%SCRIPT_VERSION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: ULTIMATE_FILE_LOCATION: {%ULTIMATE_FILE_LOCATION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: ULTIMATE_FILE_NAME: {%ULTIMATE_FILE_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_SYSTEMINFO_OSNAME: {%var_SYSTEMINFO_OSNAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_TimeZone: {%var_TimeZone%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_VER: {%var_VER%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_WHOAMI: {%var_WHOAMI%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_WHOAMI_FQDN: {%var_WHOAMI_FQDN%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: var_WINDOWS_VERSION: {%var_WINDOWS_VERSION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WIRELESS_SETUP: {%WIRELESS_SETUP%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WIRELESS_CONFIG_NAME: {%WIRELESS_CONFIG_NAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WIRELESS_CONFIG_SSID: {%WIRELESS_CONFIG_SSID%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WIRELESS_CONFIG_INTERFACE: {%WIRELESS_CONFIG_INTERFACE%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WIRELESS_PROFILE_FILENAME: {%WIRELESS_PROFILE_FILENAME%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_FILE_SCHEMA_CHECK: {%WPF_CONFIG_FILE_SCHEMA_CHECK%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION: {%WPF_CONFIG_SCHEMA_VERSION%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION_MAJOR: {%WPF_CONFIG_SCHEMA_VERSION_MAJOR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION_MIN: {%WPF_CONFIG_SCHEMA_VERSION_MIN%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION_MINOR: {%WPF_CONFIG_SCHEMA_VERSION_MINOR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION_MIN_MINOR: {%WPF_CONFIG_SCHEMA_VERSION_MIN_MINOR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_CONFIG_SCHEMA_VERSION_MIN_MAJOR: {%WPF_CONFIG_SCHEMA_VERSION_MIN_MAJOR%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_SHA256: {%WPF_SHA256%} >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: WPF_SHA256_CHECK: {%WPF_SHA256_CHECK%} >> %LOG_LOCATION%\%LOG_FILE%

:varE
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Variable debug!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SHA 256 Checker
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: WPF SHA256 Checker...) >> %LOG_LOCATION%\%LOG_FILE%
IF "%WPF_SHA256%"=="%WPF_SHA256_CHECK%" (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	WPF SHA256 match! >> %LOG_LOCATION%\%LOG_FILE%) ELSE (
	IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	WPF SHA256 DO NOT match! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: WPF SHA256 Checker...) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  get the console user
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Console user sub-routine!) >> %LOG_LOCATION%\%LOG_FILE%
QUERY SESSION > %LOG_LOCATION%\var\var_CONSOLE_USER.txt
FOR /F "tokens=2 delims= " %%U IN ('FIND /I "console" %LOG_LOCATION%\var\var_CONSOLE_USER.txt') DO SET CONSOLE_USER=%%U
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Console user ID is {%CONSOLE_USER%}! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_CONSOLE_USER.txt (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {var_CONSOLE_USER.txt} just got created!) >> %LOG_LOCATION%\%LOG_FILE% 
IF "%DEFAULT_USER%"=="%CONSOLE_USER%" (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Console user {%CONSOLE_USER%} is the same as DEFAULT_USER {%DEFAULT_USER%}, logoff will occur at the end!) >> %LOG_LOCATION%\%LOG_FILE%
IF "%DEFAULT_USER%"=="%CONSOLE_USER%" (ECHO %ISO_DATE% %TIME% Console user [%CONSOLE_USER%] is the same as DEFAULT_USER [%DEFAULT_USER%], logoff will occur at the end!)
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Console user sub-routine!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION Start!) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: META DEPENDENCY CHECKS
:metaDC
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: META Dependency Check! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Working on meta dependencies...
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Working on meta dependencies... >> %LOG_LOCATION%\%LOG_FILE%
ECHO.
::	(1) Is everyting already done?
Echo Checking to see if everything is already done...
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	{1} Checking to see if everything is already done? >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {1}: for Everything Already Done... >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Looks like everything is already done! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% GoTo err100
ECHO First run or a follow up run!
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Looks like a first run or a follow up run! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {1}: for Everything Already Done. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(2) Get the Flash Drive Volume
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {2}: Looking for a seed drive... >> %LOG_LOCATION%\%LOG_FILE%
Echo Looking for a flashdrive with volume label [%FLASH_DRIVE_VOLUME_LABEL%]
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Looking for a seed drive with volume label {%FLASH_DRIVE_VOLUME_LABEL%}... >> %LOG_LOCATION%\%LOG_FILE%
ECHO LIST VOLUME > %LOG_LOCATION%\DiskPart_Commands.txt
DISKPART /s %LOG_LOCATION%\DiskPart_Commands.txt > %LOG_LOCATION%\DiskPart_Volume_LIST.txt
FIND "%FLASH_DRIVE_VOLUME_LABEL%" %LOG_LOCATION%\DiskPart_Volume_LIST.txt > %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt
FOR /F "usebackq skip=2 tokens=3" %%G IN ("%LOG_LOCATION%\FOUND_FLASH_DRIVE.txt") DO SET FLASH_DRIVE_VOLUME=%%G:
IF EXIST %FLASH_DRIVE_VOLUME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Seed Drive Found: {%FLASH_DRIVE_VOLUME%}) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %FLASH_DRIVE_VOLUME% ECHO Flash Drive Found: %FLASH_DRIVE_VOLUME%
IF NOT EXIST %FLASH_DRIVE_VOLUME% (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	No Seed Drive found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %FLASH_DRIVE_VOLUME% ECHO No Flash Drive found!
IF EXIST %LOG_LOCATION%\DiskPart_Commands.txt del /F /Q %LOG_LOCATION%\DiskPart_Commands.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%LOG_LOCATION%\DiskPart_Commands.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\DiskPart_Volume_LIST.txt del /F /Q %LOG_LOCATION%\DiskPart_Volume_LIST.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%LOG_LOCATION%\DiskPart_Volume_LIST.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt del /F /Q %LOG_LOCATION%\FOUND_FLASH_DRIVE.txt && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%LOG_LOCATION%\FOUND_FLASH_DRIVE.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {2}: Looking for a seed drive. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(3)	Update seed location from FLASH Drive
::		this must include the host file database
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {3}: update seed location if seed drive found... >> %LOG_LOCATION%\%LOG_FILE%
ECHO Seed location: %POST_FLIGHT_DIR%
IF EXIST %FLASH_DRIVE_VOLUME% ECHO Updating seed location with flash drive...
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Updating seed location with seed drive {%FLASH_DRIVE_VOLUME%}... >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% GoTo jump3
IF EXIST %FLASH_DRIVE_VOLUME% ROBOCOPY %FLASH_DRIVE_VOLUME%\ %POST_FLIGHT_DIR%\ *.* /NP /R:1 /W:2 /XF *.lnk /LOG:%LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
SET ROBO_SEED_CODE=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Robocopy exit code for seed location: EXIT CODE: {%ROBO_SEED_CODE%}) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Seed location {%POST_FLIGHT_DIR%} just got updated from seed drive {%FLASH_DRIVE_VOLUME%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% EQU 3 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Seed location {%POST_FLIGHT_DIR%} just got updated from Flash drive {%FLASH_DRIVE_VOLUME%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% LEQ 3 ECHO Seed location [%POST_FLIGHT_DIR%] just got updated from Flash drive [%FLASH_DRIVE_VOLUME%]!
IF %ROBO_SEED_CODE% GTR 7 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Seed location {%POST_FLIGHT_DIR%} failed to update!) >> %LOG_LOCATION%\%LOG_FILE%
IF %ROBO_SEED_CODE% GTR 7 ECHO Seed location [%POST_FLIGHT_DIR%] failed to update!
:jump3
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {3}: update seed location if seed drive found. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(4) Wireless Network Connection
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {4}: Connect to a wireless network... >> %LOG_LOCATION%\%LOG_FILE%
IF %WIRELESS_SETUP% EQU 0 IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Not configured for wireless network! >> %LOG_LOCATION%\%LOG_FILE%
IF %WIRELESS_SETUP% EQU 0 GoTo jump4W
IF %WIRELESS_SETUP% EQU 1 (netsh wlan add profile filename=%POST_FLIGHT_DIR%\%WIRELESS_PROFILE_FILENAME% interface=%WIRELESS_CONFIG_INTERFACE% user=all)
SET WIRELESS_CONNECTION_ERROR=%ERRORLEVEL%
IF %WIRELESS_SETUP% EQU 1 (netsh wlan connect name=%WIRELESS_CONFIG_NAME% ssid=%WIRELESS_CONFIG_SSID% interface=%WIRELESS_CONFIG_INTERFACE%)
IF %WIRELESS_CONNECTION_ERROR% EQU 0 IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Connected to a wireless network {%WIRELESS_CONFIG_SSID%} >> %LOG_LOCATION%\%LOG_FILE%
IF %WIRELESS_CONNECTION_ERROR% GTR 0 IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Failed to connect to the wireless network {%WIRELESS_CONFIG_SSID%} >> %LOG_LOCATION%\%LOG_FILE%
:jump4W
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {4}: Connect to a wireless network... >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(5) NETDOM
::		Part of RSAT (Remote Server Administration Tools) --NETDOM utility included
::	not present until proven otherwise
Echo Checking for NETDOM presence...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {5}: checking if NETDOM is present... >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 (ECHO %ISO_DATE% %TIME% [INFO]	Checking for NETDOM presence...) >> %LOG_LOCATION%\%LOG_FILE%
SET NETDOM_PRESENCE=0
(NETDOM HELP) && (SET NETDOM_PRESENCE=1)
SET NETDOM_ERROR=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	NETDOM RETURNED ERROR: %NETDOM_ERROR% >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_ERROR% EQU 9009 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	RSAT (NETDOM) is not installed! >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	NETDOM is present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 0 ECHO NETDOM is NOT present!
IF %NETDOM_PRESENCE% EQU 1 ECHO NETDOM is present!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {5}: checking if NETDOM is present. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(6) Password Files
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {6}: looking for password files... >> %LOG_LOCATION%\%LOG_FILE%
Echo Checking for password files...
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Local Administrator Password file {%LOCAL_ADMIN_PW_FILE%} found!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% ECHO Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] found!
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% SET /P ADMIN_PASSWORD= < %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Local Administrator Password file {%LOCAL_ADMIN_PW_FILE%} not found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% ECHO Local Administrator Password file [%LOCAL_ADMIN_PW_FILE%] not found!
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Domain Join User Password file {%NETDOM_USERD_PW_FILE%} found!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% ECHO Domain Join User Password file [%NETDOM_USERD_PW_FILE%] found!
IF "%NETDOM_PASSWORDD%"=="*" (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	User requested to be prompted with domain join password! >> %LOG_LOCATION%\%LOG_FILE%) ELSE (
	IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% SET /P NETDOM_PASSWORDD= < %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE%)
IF NOT EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Domain Join User Password file {%NETDOM_USERD_PW_FILE%} not found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% ECHO Domain join user password file [%NETDOM_USERD_PW_FILE%] not found!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {6}: looking for password files... >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(7) HOST DATABASE
Echo Checking for host database...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {7}: Looking for host database. >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% ECHO Host database found!
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% ECHO Host database not found!
IF EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Host database found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Host database NOT found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% GoTo err02
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {7}: Looking for host database. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	(8) Chocolatey
Echo Checking for Chocolatey...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Meta Dependency Check {8}: checking if Chocolatey is present... >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Checking for Chocolatey presence... >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Chocolatey Meta check appears to have already run!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt GoTo jump8
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Meta Dependency Check {8}: checking if Chocolatey is present... >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	Chocolatey First time install
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Attempting first time Chocolatey install... >> %LOG_LOCATION%\%LOG_FILE%
ECHO Attempting first time Chocolatey install...
::		attempt to install from Sub-Routine
GoTo subr1


:jump8
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Jump8 >> %LOG_LOCATION%\%LOG_FILE%
:: jump to create a scheduled task
GoTo autoSU
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:installRSAT
::	(9) Try and fix NETDOM DEPENDENCY
::	will try and install Remote Server Administration Tools (NETDOM) from seed location or flash drive if present
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check {9}: Trying to install Remote Server Administrative Tools [NETDOM] if not present... >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 GoTo Start
IF %RSAT_ATTEMPT% EQU 2 GoTo err01

ECHO Attempting to install RSAT NETDOM...
IF EXIST %POST_FLIGHT_DIR% (dir /B %POST_FLIGHT_DIR% | FIND /I "%RSAT_PACKAGE_W10x64%" > %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt) ELSE (
	IF EXIST %FLASH_DRIVE_VOLUME% dir /B /A %FLASH_DRIVE_VOLUME% | FIND /I "%RSAT_PACKAGE_W10x64%" > %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt)
IF EXIST %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt SET /P NETDOM_INSTALL= < %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Package [%NETDOM_INSTALL%] was found and will be used to install RSAT-Remote Server Administrative Tools [NETDOM]. >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt (IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	An error occured looking for RSAT-Remote Server Administrative Tools [NETDOM] installer!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt GoTo start
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Checking that the RSAT installer {%NETDOM_INSTALL%} meets the computer architecture {%COMPUTER_ARCHITECTURE%}... >> %LOG_LOCATION%\%LOG_FILE%
FIND /I "%COMPUTER_ARCHITECTURE%" %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt && (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	The RSAT package meets the %COMPUTER_ARCHITECTURE% computer architecture!) >> %LOG_LOCATION%\%LOG_FILE%
FIND /I "%COMPUTER_ARCHITECTURE%" %LOG_LOCATION%\var\var_NETDOM_INSTALL.txt || (
	IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	The RSAT package doesn't match the computer architecture!) >> %LOG_LOCATION%\%LOG_FILE%

IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Checking that the RSAT installer {%NETDOM_INSTALL%} meets the Windows Version {%var_WINDOWS_VERSION%}... >> %LOG_LOCATION%\%LOG_FILE%
FIND /I "%var_WINDOWS_VERSION%" "%LOG_LOCATION%\var\var_NETDOM_INSTALL.txt" && (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	The RSAT package is a match for the Windows Version {%var_WINDOWS_VERSION%}!) >> %LOG_LOCATION%\%LOG_FILE%
	FIND /I "%var_WINDOWS_VERSION%" "%LOG_LOCATION%\var\var_NETDOM_INSTALL.txt" || (
	IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	The RSAT package {%NETDOM_INSTALL%} is NOT a match for the Windows Version {%var_WINDOWS_VERSION%}!) >> %LOG_LOCATION%\%LOG_FILE%

REM WILL NEED ERROR CATCHING FOR THE ABOVE TWO CONDITIONS

IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Trying to install:{%NETDOM_INSTALL%}... >> %LOG_LOCATION%\%LOG_FILE%
ECHO Installing NETDOM with this installer {%NETDOM_INSTALL%}...
ECHO (Computer will reboot after instalation!)
SET /A "RSAT_ATTEMPT=RSAT_ATTEMPT+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	RSAT_ATTEMPT just got set to {%RSAT_ATTEMPT%}! >> %LOG_LOCATION%\%LOG_FILE%
ECHO %RSAT_ATTEMPT% > %LOG_LOCATION%\var\var_RSAT_attempt.txt
:: The RSAT installer
"%POST_FLIGHT_DIR%\%NETDOM_INSTALL%" /quiet /norestart
SET RSAT_INSTALL_ERRORLEVEL=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	RSAT installer return code: %RSAT_INSTALL_ERRORLEVEL% >> %LOG_LOCATION%\%LOG_FILE%
:: Wait for RSAT Rebooting
::IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Rebooting due to RSAT installation... >> %LOG_LOCATION%\%LOG_FILE%
:: TIMEOUT 15
:: Computer should be rebooting now so that RSAT can configure properly
::  will never reach here if everything worked correctly unless RSAT doesn't initiate a reboot
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	RSAT-Remote Server Administration Tools {%NETDOM_INSTALL%} [NETDOM] attempted to install! >> %LOG_LOCATION%\%LOG_FILE%
IF %RSAT_INSTALL_ERRORLEVEL% EQU 0 IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	RSAT-Remote Server Administration Tools [NETDOM] successfully installed! >> %LOG_LOCATION%\%LOG_FILE%
IF %RSAT_INSTALL_ERRORLEVEL% GEQ 1 IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	RSAT {%NETDOM_INSTALL%} installation failed! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Checking for NETDOM presence... >> %LOG_LOCATION%\%LOG_FILE%
dir %SYSTEMROOT%\System32 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
IF %NETDOM_PRESENCE% EQU 0 DIR %SYSTEMROOT%\SysWOW64 | FIND /I "netdom.exe" && SET NETDOM_PRESENCE=1
IF EXIST %SYSTEMROOT%\SysWOW64\netdom.exe SET "PATH=%PATH%;%SYSTEMROOT%\SysWOW64"
IF %NETDOM_PRESENCE% EQU 0 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR] NETDOM is still NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %NETDOM_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	NETDOM is now present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Dependency Check {9}: Remote Server Administrative Tools [NETDOM] check and installation. >> %LOG_LOCATION%\%LOG_FILE%
GoTo autoSU
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Automated setup for Windows Post-Flight as Scheduled Task
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:autoSU
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Auto-Setup for Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
:: Decide where to go
IF NOT EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% GoTo startS
IF EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (SCHTASKS /Query /V /FO LIST /TN "%SCRIPT_NAME%") | FIND /I "%NETDOM_USERD%" && GoTo startS
SCHTASKS /Query /TN "%SCRIPT_NAME%" && IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% GoTo stepSTD
SCHTASKS /Query /TN "%SCRIPT_NAME%" || GoTo stepSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Auto-Setup for Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%

:: As Local Computer Scheduled Task Setup
:stepSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Working on Scheduled Task as a local computer...

:trapSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Query /TN "%SCRIPT_NAME%" && GoTo skipSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%

:fSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Function for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
REM Setting /SC to ONLOGON did not work correctly. Works better with ONSTART
SCHTASKS /Create /TR "%POST_FLIGHT_DIR%\%POST_FLIGHT_CMD_NAME%" /RU Administrator /RP %ADMIN_PASSWORD% /TN "%SCRIPT_NAME%" /SC ONSTART /IT /DELAY 0001:00 /RL HIGHEST /HRESULT /F
IF %ERRORLEVEL% EQU 0 (
     IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Scheduled Task local for {%SCRIPT_NAME%} successfully created! >> %LOG_LOCATION%\%LOG_FILE%
	 ) ELSE (
	 IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Scheduled Task local for {%SCRIPT_NAME%} FAILED! >> %LOG_LOCATION%\%LOG_FILE%
	 ) >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Query /TN "%SCRIPT_NAME%" /FO LIST /V >> %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Function for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
GoTo startS

:skipSTL
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Skip for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Scheduled Task for {%SCRIPT_NAME%} already exists! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Skip for Local computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
GoTo startS

:://///////////////////////////////////////////////////////////////////////////

:: As Domain Computer Scheduled Task Setup
::  comes in after join domain function
:stepSTD
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Working on Scheduled Task as a domain computer...

:trapSTD
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap for Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Query /TN "%SCRIPT_NAME%" || IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Scheduled Task for [%SCRIPT_NAME%] doesn't already exist, and was expected! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (SCHTASKS /Query /V /FO LIST /TN "%SCRIPT_NAME%") | FIND /I "%NETDOM_USERD%" && GoTo skipSTD
IF EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (SCHTASKS /Query /V /FO LIST /TN "%SCRIPT_NAME%") | FIND /I "%NETDOM_USERD%" || GoTo fSTD
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap for Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%

:fSTD
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Function for Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Create /TR "%POST_FLIGHT_DIR%\%POST_FLIGHT_CMD_NAME%" /RU %NETDOM_DOMAIN%\%NETDOM_USERD% /RP %NETDOM_PASSWORDD% /TN "%SCRIPT_NAME%" /SC ONSTART /IT /DELAY 0001:00 /RL HIGHEST /F
SCHTASKS /Query /TN "%SCRIPT_NAME%" /FO LIST /V >> %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt
FINSTR /C:"%NETDOM_USERD%" %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt || IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Task Scheduler failed to set the domain user [%NETDOM_USERD%] for the task [%SCRIPT_NAME%]! >> %LOG_LOCATION%\%LOG_FILE%
:: If setting the domain account for the scheduled task fails resort back to STL
:: This is failing and skipping the reboot
:: FINSTR /C:"%NETDOM_USERD%" %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt || GoTo fSTL

:: Set that the Task scheduler for domain account is rebooting
IF NOT EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (
     SET TS_D_REBOOT=1
     ) && (
	 ECHO %TS_D_REBOOT% > %LOG_LOCATION%\var\var_TS_D_REBOOT.txt
     ) && (
     IF EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (
	      IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [var_TS_D_REBOOT.txt] just got created!
     )) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\var\var_TS_D_REBOOT.txt (SET /P TS_D_REBOOT= < %LOG_LOCATION%\var\var_TS_D_REBOOT.txt) && SET /A "TS_D_REBOOT=TS_D_REBOOT+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Task Scheduled Domain account reboot set to [%TS_D_REBOOT%]! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Function for Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
:: Computer should reboot to run as a domain user
(shutdown /r /t 15) & (GoTo feTime)

:skipSTD
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Skip for Domain computer Scheduled Task! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Scheduled Task for [%SCRIPT_NAME%] already exists! >> %LOG_LOCATION%\%LOG_FILE%
GoTo startS

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::*****************************************************************************
:startS
:: start processing
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Processing entered! >> %LOG_LOCATION%\%LOG_FILE%

:://///////////////////////////////////////////////////////////////////////////
:step1
:: Configures the local administrator account
::  Do this before joining the domain in order to ensure not getting locked out withouth admin priveleges
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step1 Local Administrator configuration >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 1: Working on setting up local administrator...

:trap1
:: TRAP 1 to catch if the local administrator has already been configured
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap1 catch if local Administrator already configured >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% GoTo skip1

:fadmin
:: FUNCTION Configure local administrator account
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION [1] Configure local administrator >> %LOG_LOCATION%\%LOG_FILE%
SET LOCAL_ADMINISTRATOR_STATUS=0
NET USER Administrator && SET LOCAL_ADMINISTRATOR_STATUS=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOCAL_ADMINISTRATOR_STATUS: {%LOCAL_ADMINISTRATOR_STATUS%} >> %LOG_LOCATION%\%LOG_FILE%
IF %LOCAL_ADMINISTRATOR_STATUS% EQU 1 IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Local Administrator was found in the user group >> %LOG_LOCATION%\%LOG_FILE%
NET USER Administrator %ADMIN_PASSWORD% /ACTIVE:YES || SET LOCAL_ADMINISTRATOR_STATUS=0
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: LOCAL_ADMINISTRATOR_STATUS: {%LOCAL_ADMINISTRATOR_STATUS%} after configuration >> %LOG_LOCATION%\%LOG_FILE%
IF %LOCAL_ADMINISTRATOR_STATUS% EQU 1 ECHO %DATE% %TIME% Local Administrator account configured/Re-configured! >> %LOG_LOCATION%\%PROCESS_1_FILE_NAME%
IF %LOCAL_ADMINISTRATOR_STATUS% EQU 1 IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Local Administrator account configured/Re-configured! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% ECHO Local Administrator account configured/Re-configured!
IF %LOCAL_ADMINISTRATOR_STATUS% EQU 0 GoTo err10
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION [1] Configure local administrator >> %LOG_LOCATION%\%LOG_FILE%
:: Go setup the Scheduled Task now that local administrator is configured
GoTo stepSTL

:skip1
:: Skip 1 means the local Administrator account has already been configured.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip1 local Administrator already configured >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Local Administrator already configured! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Local Administrator already configured!
GoTo step2
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step2
:: Process DiskPart to configure hard drive
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step2 >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 2: Working on computer disk configuration...

:trap2
:: TRAP 2 to catch if diskpart has already run
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Trap2 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% GoTo skip2

:trap2.1
:: Trap 2.1 to catch if this is a FirstTimeRun
::	first time runs could be running the WPF commandlet from a flash drive
::	which might be affected by DISKPART
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Trap2.1 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FirstTimeRun.txt IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	STEP2 DiskPart being skipped due to first time run. >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FirstTimeRun.txt GoTo step3

:fdisk
:: FUNCTION Run DISKPART utility
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION Diskpart... >> %LOG_LOCATION%\%LOG_FILE%
ECHO DISKPART is running...
ECHO %DATE% %TIME% DISKPART is running... >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
DISKPART /s %POST_FLIGHT_DIR%\%DISKPART_COMMAND_FILE% >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
SET DISKPART_ERROR=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DISKPART_ERROR: {%DISKPART_ERROR%} >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% GTR 0 GoTo err20
IF %DISKPART_ERROR% EQU 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Diskpart completed successfully! >> %LOG_LOCATION%\%LOG_FILE%) ELSE (
     IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Diskpart threw an error {%DISKPART_ERROR%}! Check disk configuration!) >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% LSS 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Since the diskpart error {%DISKPART_ERROR%} is a negative number, most likely diskpart completed successfully!) >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME% DISKPART finnished! >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
ECHO DISKPART finnished!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION Diskpart. >> %LOG_LOCATION%\%LOG_FILE%

:fchkdsk
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION Check Disk... >> %LOG_LOCATION%\%LOG_FILE%
CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is not dirty" && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Disk {%SYSTEMDRIVE%} is clean! >> %LOG_LOCATION%\%LOG_FILE%
CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is not dirty" && GoTo skipfck
CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Disk {%SYSTEMDRIVE%} is dirty! >> %LOG_LOCATION%\%LOG_FILE%
CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && echo y | chkdsk %systemdrive% /B

:skipfck
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION Check Disk. >> %LOG_LOCATION%\%LOG_FILE%

GoTo step3

:skip2
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip2 >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% ECHO DiskPart has already run! >> %LOG_LOCATION%\%PROCESS_2_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	DiskPart has already run! >> %LOG_LOCATION%\%LOG_FILE%
ECHO DiskPart has already run!
GoTo step3
:://///////////////////////////////////////////////////////////////////////////


:://///////////////////////////////////////////////////////////////////////////
:step3
:: Aquire the local MAC address and lookup host database file inorder to set the new hostname.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step3 >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 3: Working on setting the hostname...

:trap3
:: TRAP 3 to catch if the hostname is not the default, which means it's likey changed
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap3 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% GoTo skip3
IF /I "%COMPUTERNAME%"=="%DEFAULT_HOSTNAME%" (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Hostname:{%COMPUTERNAME%} needs to be changed!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%COMPUTERNAME%"=="%DEFAULT_HOSTNAME%" ECHO Hostname:[%COMPUTERNAME%] needs to be changed!
IF /I NOT "%COMPUTERNAME%"=="%DEFAULT_HOSTNAME%" (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Current computer name {%COMPUTERNAME%} is not the same as default hostname {%DEFAULT_HOSTNAME%}. The hostname will still be attempted to be changed based on Host file database {%HOST_FILE_DATABASE%}.) >> %LOG_LOCATION%\%LOG_FILE%
GoTo fmac

:fmac
:: FUNCTION	GET MAC Address
:: Getting the Host MAC Address
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION GETMAC >> %LOG_LOCATION%\%LOG_FILE%
GETMAC > %LOG_LOCATION%\Host_MAC.txt || GoTo err31
::	search the getmac file & set mac based on mac database
IF NOT EXIST %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% GoTo err02
FOR /F "skip=3 tokens=1" %%G IN (%LOG_LOCATION%\Host_MAC.txt) DO FIND "%%G" %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% && SET HOST_MAC=%%G
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	HOST_MAC: %HOST_MAC% >> %LOG_LOCATION%\%LOG_FILE%
ECHO Computer MAC: %HOST_MAC%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION GETMAC >> %LOG_LOCATION%\%LOG_FILE%
GoTo trap31

:trap31
:: Trap to catch if NETDOM is present or not
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap3.1 >> %LOG_LOCATION%\%LOG_FILE%
IF %RSAT_ATTEMPT% GEQ 2 GoTo err01
IF %NETDOM_PRESENCE% EQU 0 GoTo installRSAT
GoTo fhost

:fhost
:: FUNCTION SET THE HOSTNAME
::	based on MAC address
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION Set the hostname >> %LOG_LOCATION%\%LOG_FILE%
FIND "%HOST_MAC%" %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% > %LOG_LOCATION%\MAC-2-HOST.txt
IF NOT EXIST %LOG_LOCATION%\MAC-2-HOST.txt GoTo err33
IF EXIST %LOG_LOCATION%\MAC-2-HOST.txt (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {MAC-2-HOST.txt} just got created!) >> %LOG_LOCATION%\%LOG_FILE%
:: Strip the MAC address from the file and set the hostname
FOR /F "usebackq skip=2 tokens=1" %%G IN ("%LOG_LOCATION%\MAC-2-HOST.txt") DO SET HOST_STRING=%%G || GoTo err33
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	HOST_STRING: %HOST_STRING% >> %LOG_LOCATION%\%LOG_FILE%
IF NOT "HOST_STRING"=="" (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Hostname {%HOST_STRING%} found in HOST_FILE_DATABASE {%HOST_FILE_DATABASE%}) >>	%LOG_LOCATION%\%LOG_FILE%
IF /I %COMPUTERNAME%==%HOST_STRING% GoTo Skip3
NETDOM RENAMECOMPUTER %computername% /NewName:%HOST_STRING% /FORCE /REBoot:%NETDOM_REBOOT% || GoTo err30
IF %ERRORLEVEL% EQU 0 Echo %DATE% %TIME% Hostname [%COMPUTERNAME%] is being changed to [%HOST_STRING%]! > %LOG_LOCATION%\%PROCESS_3_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Hostname {%COMPUTERNAME%} has been renamed to: {%HOST_STRING%}) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO Hostname [%COMPUTERNAME%] has been renamed to: %HOST_STRING%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO %DATE% %TIME% Hostname [%HOST_STRING%] found in HOST_FILE_DATABASE [%HOST_FILE_DATABASE%] >> %LOG_LOCATION%\%PROCESS_3_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds! >> %LOG_LOCATION%\%PROCESS_3_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Computer is rebooting in {%NETDOM_REBOOT%} seconds! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds!
:: Goes to FUNCTION END TIME since the computer is rebooting
GoTo feTime

:skip3
:: Skip 3 means the hostname has already been set.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip 3 >> %LOG_LOCATION%\%LOG_FILE%
SET HOST_STRING=%COMPUTERNAME%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% ECHO %DATE% %TIME% Hostname already set to {%COMPUTERNAME%} matching {%HOST_STRING%} from host file:{%HOST_FILE_DATABASE%]} >> %LOG_LOCATION%\%PROCESS_3_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Hostname already set {%COMPUTERNAME%}! >> %LOG_LOCATION%\%LOG_FILE%
ECHO Hostname already set [%COMPUTERNAME%]!
IF EXIST %LOG_LOCATION%\Host_MAC.txt TYPE %LOG_LOCATION%\Host_MAC.txt >> %PROCESS_3_FILE_NAME% && del /F /Q %LOG_LOCATION%\Host_MAC.txt
IF EXIST %LOG_LOCATION%\MAC-2-HOST.txt TYPE %LOG_LOCATION%\MAC-2-HOST.txt >> %PROCESS_3_FILE_NAME% && del /F /Q %LOG_LOCATION%\MAC-2-HOST.txt
IF NOT EXIST %LOG_LOCATION%\Host_MAC.txt IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File Host_MAC.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\MAC-2-HOST.txt IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File MAC-2-HOST.txt just got deleted! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step4
:://///////////////////////////////////////////////////////////////////////////


:://///////////////////////////////////////////////////////////////////////////
:step4
:: Joins the computer to a Domain if chosen to do so
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step4 >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 4: Working on joining the computer to a Windows Domain network...

:trap4
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap4 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% GoTo skip4
:: Check to make sure a domain is configured, otherwise not joining a domain
IF /I "%NETDOM_DOMAIN%"=="" (IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	No Domain provided in configuration!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%NETDOM_DOMAIN%"=="NOT_SET" (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Not joining a domain! Domain was configured to skip!) >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%NETDOM_DOMAIN%"=="NOT_SET" GoTo step5
IF NOT DEFINED NETDOM_DOMAIN GoTo step5
IF /I NOT "%NETDOM_DOMAIN%"=="" GoTo trap41

:trap41
:: TRAP4.1 to catch if the computer has already been joined to a domain
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap4.1 >> %LOG_LOCATION%\%LOG_FILE%
::	multiple checks to really make sure...
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% GoTo skip4
IF /I "%NETDOM_DOMAIN%"=="%USERDOMAIN%" GoTo skip4
IF /I "%NETDOM_DOMAIN%"=="%USERDNSDOMAIN%" GoTo skip4
:: Check the current domain association
FOR /F "tokens=2 delims= " %%D IN ('FINDSTR /C:"Domain" %LOG_LOCATION%\var\var_systeminfo.txt') DO SET DOMAIN_ASSOCIATION=%%D
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Current domain association is {%DOMAIN_ASSOCIATION%} >> %LOG_LOCATION%\%LOG_FILE%
IF /I "%NETDOM_DOMAIN%"=="%DOMAIN_ASSOCIATION%" GoTo skip4
IF %NETDOM_PRESENCE% EQU 0 GoTo err01
:: Check to make sure computer can communicate with Windows domain
::  DNS is required
NSLOOKUP %NETDOM_DOMAIN% | FIND "Name" || GoTo err42
:: NETDOM QUERY DC /Domain:%NETDOM_DOMAIN% /User:%NETDOM_USERD% /PASSWORDD:%NETDOM_PASSWORDD% || GoTo err42
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap4.1 >> %LOG_LOCATION%\%LOG_FILE%
GoTo fdomain

:fdomain
:: FUNCTION Join the DOMAIN
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION Joining domain >> %LOG_LOCATION%\%LOG_FILE%
cls
ECHO Supply the domain account [%NETDOM_DOMAIN%\%NETDOM_USERD%] password to join [%NETDOM_DOMAIN%] domain:
NETDOM JOIN %COMPUTERNAME% /DOMAIN:%NETDOM_DOMAIN% /USERD:%NETDOM_USERD% /PASSWORDD:%NETDOM_PASSWORDD% /REBoot:%NETDOM_REBOOT% || GoTo err41
IF %ERRORLEVEL% EQU 0 ECHO %DATE% %TIME% Joined {%NETDOM_DOMAIN%} domain >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Joined {%NETDOM_DOMAIN%} domain!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% ECHO %DATE% %TIME% Computer is rebooting in %NETDOM_REBOOT% seconds! >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Computer is rebooting in %NETDOM_REBOOT% seconds! >> %LOG_LOCATION%\%LOG_FILE%

:: Adds the domain account used to join domain into local administrators group
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER Sub-Function Adding Domain User into Local Administrators Group >> %LOG_LOCATION%\%LOG_FILE%
NET LOCALGROUP Administrators %NETDOM_DOMAIN%\%NETDOM_USERD% /ADD
SET DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL: {%DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL%} >> %LOG_LOCATION%\%LOG_FILE%
IF %DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL% EQU 0 (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Domain user {%NETDOM_USERD%} was just added to the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL% EQU 2 (
	IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Domain User {%NETDOM_USERD%} was already in the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DOMAINUSER_LOCALGROUP_ADD_ERRORLEVEL% EQU 1 (
	IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Domain User {%NETDOM_USERD%} could not be added to the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT Sub-Function Adding Domain User into Local Administrators Group >> %LOG_LOCATION%\%LOG_FILE%


:: Need to reset the scheduled task after joining a domain otherwise the Task will not run
:: See if this fixes the scheduled task bug
::		this fixed this issue.
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER Sub-Function Resetting Scheduled Task after domain join! >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Create /TR "%POST_FLIGHT_DIR%\%POST_FLIGHT_CMD_NAME%" /RU %COMPUTERNAME%\Administrator /RP %ADMIN_PASSWORD% /TN "%SCRIPT_NAME%" /SC ONSTART /IT /DELAY 0001:00 /RL HIGHEST /HRESULT /F
IF %ERRORLEVEL% EQU 0 (
     IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Scheduled Task local for {%SCRIPT_NAME%} successfully created!
	 ) ELSE (
	 IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Scheduled Task local for {%SCRIPT_NAME%} FAILED!
	 ) >> %LOG_LOCATION%\%LOG_FILE%
SCHTASKS /Query /TN "%SCRIPT_NAME%" /FO LIST /V >> %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT Sub-Function Resetting Scheduled Task after domain join! >> %LOG_LOCATION%\%LOG_FILE%
::::
:: Going to function end time since computer is rebooting
GoTo feTime

:skip4
:: Skip 4 means the computer has already been joined to the domain
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip4 >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% ECHO %DATE% %TIME% %COMPUTERNAME% has already been joined to the domain [%NETDOM_DOMAIN%]! >> %LOG_LOCATION%\%PROCESS_4_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%COMPUTERNAME% has already been joined to the domain [%NETDOM_DOMAIN%]! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step5
:: Chocolatey Package Management 
::	script. Recommend running 'upgrade' instead of install for the latest version of an application

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step5 >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 5: Working on Chocolatey package management...

:trap5
:: TRAP 5 to catch if Chocolatey has already run
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap5 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% GoTo skip5
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap5 >> %LOG_LOCATION%\%LOG_FILE%


:: Chocolatey pre-processing
Echo Checking for Chocolatey...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Dependency Check: checking if Chocolatey is present... >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Checking for Chocolatey presence... >> %LOG_LOCATION%\%LOG_FILE%
::	not present until proven otherwise
SET CHOCO_PRESENCE=0
IF EXIST %ALLUSERSPROFILE%\chocolatey\bin\chocolatey.exe SET CHOCO_PRESENCE=1
IF DEFINED CHOCO_PRESENCE IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCO_PRESENCE {%CHOCO_PRESENCE%} >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ChocolateyInstall (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Chocolatey variable [ChocolateyInstall] exists!) ELSE (
	IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Chocolatey variable [ChocolateyInstall] is NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 1 (Choco | FIND "Chocolatey") > %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 SET /P var_CHOCOLATEY= < %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 Choco info Chocolatey > %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	{%var_CHOCOLATEY%} is present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Chocolatey is NOT present!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 GoTo err50


:trap51
:: TRAP 5.1 to see if Advanced CHOCOLATEY is turned on
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap5.1 >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCOLATEY_ADVANCED% EQU 1 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCOLATEY ADVANCED is turned on {%CHOCOLATEY_ADVANCED%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCOLATEY_ADVANCED% EQU 0 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCOLATEY ADVANCED is turned off {%CHOCOLATEY_ADVANCED%}!) >> %LOG_LOCATION%\%LOG_FILE%
:: If Advanced CHOCOLATEY is turned on go to the sub-routine
IF %CHOCOLATEY_ADVANCED% EQU 1 GoTo subr3
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap5.1 >> %LOG_LOCATION%\%LOG_FILE%

:fchoco
:: Check if available first
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION Chocolatey >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %ChocolateyInstall%\choco.exe GoTo err50

::	variable combine
SET /P CHOCO_PACKAGE_RUN= < %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%

:: FUNCTION RUN Chocolatey
ECHO %DATE% %TIME% %var_CHOCOLATEY% is running... >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Working on Chocolatey package management... >> %LOG_LOCATION%\%LOG_FILE%
Choco upgrade %CHOCO_PACKAGE_RUN% /Y
ECHO %DATE% %TIME%: %var_CHOCOLATEY% ran this package list {%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%}! >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
Choco LIST --Local-Only >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_CHOCOLATEY% ran this package list {%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%}! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6

:skip5
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip5 >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% Choco LIST --local-only >> %LOG_LOCATION%\%PROCESS_5_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_CHOCOLATEY% has already been run! >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6
:://///////////////////////////////////////////////////////////////////////////

:://///////////////////////////////////////////////////////////////////////////
:step6
:: Process Ultimate script file {cleaning, configurations, etc}
::	Author uses Sorcerer's Apprentice as ultimate script file
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: step6 >> %LOG_LOCATION%\%LOG_FILE%
ECHO Step 6: Working on processing the Ultimate Commandlet...

:trap6
:: TRAP6 is to catch if the Ultimat file has been processed
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap6 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% GoTo skip6
IF NOT EXIST %ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME% GoTo err60
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap6 >> %LOG_LOCATION%\%LOG_FILE%

:trap61
:: TRAP 6.1 Self-Preservation against Ultimate commandlet not properly set for Exit /B
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: trap6.1 >> %LOG_LOCATION%\%LOG_FILE%
FINDSTR /BLC:"EXIT /B" "%ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%" || GoTo err61
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	The Ultimate commandlet meets the Exit /B requirement! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: trap6.1 >> %LOG_LOCATION%\%LOG_FILE%

:fulti
:: FUNCTION Run the Ultimate Commandlet
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION [6] Ultimate commandlet >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME%: Ultimate file [%ULTIMATE_FILE_NAME%] is attempting to run... >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
IF EXIST %ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME% CALL :subr2
:jump2
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Jump2 >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Ultimate file [%ULTIMATE_FILE_NAME%] ran!) >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:skip6
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: skip6 >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% ECHO %DATE% %TIME% Ultimate file [%ULTIMATE_FILE_NAME%] has already run! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Ultimate file [%ULTIMATE_FILE_NAME%] has already run! >> %LOG_LOCATION%\%LOG_FILE%
GoTo end


:://///////////////////////////////////////////////////////////////////////////
::	Sub-Routines

:subr1
::	Sub-Routine Chocolatey
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine [subr1] Chocolatey installation >> %LOG_LOCATION%\%LOG_FILE%
::	tagged for removal
:: SETLOCAL ENABLEDELAYEDEXPANSION
::	Check for updates on Chocolatey webiste for installation:
::		https://chocolatey.org/install#install-with-cmdexe
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG] PATH just got set to: %PATH% >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %ALLUSERSPROFILE%\chocolatey\bin\chocolatey.exe SET CHOCO_PRESENCE=1
IF EXIST %ALLUSERSPROFILE%\chocolatey\bin\chocolatey.exe (Choco | FIND "Chocolatey") > %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF EXIST %ALLUSERSPROFILE%\chocolatey\bin\chocolatey.exe SET /P var_CHOCOLATEY= < %LOG_LOCATION%\var\var_%SCRIPT_NAME%_%SCRIPT_VERSION%_Chocolatey.txt
IF %CHOCO_PRESENCE% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%var_CHOCOLATEY% installed for the first time successfully!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 0 (IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Chocolatey failed to install for the first time!) >> %LOG_LOCATION%\%LOG_FILE%
IF %CHOCO_PRESENCE% EQU 1 ECHO %var_CHOCOLATEY% installed for the first time successfully!
IF %CHOCO_PRESENCE% EQU 0 ECHO Chocolatey failed to install for the first time!
::	tagged for removal
:: SETLOCAL DISABLEDELAYEDEXPANSION
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Sub-Routine [subr1] returned CHOCO_PRESENCE:%CHOCO_PRESENCE% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine [subr1] >> %LOG_LOCATION%\%LOG_FILE%
GoTo jump8


:subr2
::	Sub-Routine Ultimate Commandlet
SETLOCAL ENABLEDELAYEDEXPANSION
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine Ultimate Commandlet [%ULTIMATE_FILE_NAME%] >> %LOG_LOCATION%\%LOG_FILE%
ECHO %DATE% %TIME%: Ultimate commandlet [%ULTIMATE_FILE_NAME%] is running! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%
CALL "%ULTIMATE_FILE_LOCATION%\%ULTIMATE_FILE_NAME%"
IF %ERRORLEVEL% EQU 0 (ECHO %DATE% %TIME%: Ultimate file [%ULTIMATE_FILE_NAME%] ran successfully! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%) ELSE (
	ECHO %DATE% %TIME% Ultimate file [%ULTIMATE_FILE_NAME%] did not run successfully! >> %LOG_LOCATION%\%PROCESS_6_FILE_NAME%)
SETLOCAL DISABLEDELAYEDEXPANSION
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine [subr2] >> %LOG_LOCATION%\%LOG_FILE%
color 9E
GoTo jump2


:subr3
::	Sub-Routine for Advanced CHOCOLATEY
ECHO Processing advanced chocolatey...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine [3] Advanced Chocolatey >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCOLATEY_ADVANCED is set to: {%CHOCOLATEY_ADVANCED%} >> %LOG_LOCATION%\%LOG_FILE%
DIR /B %POST_FLIGHT_DIR% | FIND /I "criteria" || GoTo err51
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCOLATEY advanced META package list is set to: %CHOCO_META_PACKAGE_LIST% >> %LOG_LOCATION%\%LOG_FILE%
SET ADVANCED_CHOCOLATEY_META_PACKAGE=
:: Advanced Chocolatey List Counter
SET ACL_COUNTER=1
:: Advanced Chocolatey Search Counter
SET ACS_COUNTER=1

:sploop
:: Start the primary loop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine Primary Loop >> %LOG_LOCATION%\%LOG_FILE%
::	ACMPLS (Advanced Chocolatey Meta Package List Search)
SET ACMPLS=
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACL Advanced Chocolatey List Counter is set to {%ACL_COUNTER%}! >> %LOG_LOCATION%\%LOG_FILE%
::	Using the META package list, find the criteria file
FOR /F "tokens=%ACL_COUNTER%" %%L IN ("%CHOCO_META_PACKAGE_LIST%") DO SET ACMPLS=%%L
IF NOT DEFINED ACMPLS (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACMPLS Advanced Chocolatey Meta Package List Search set to {%ACMPLS%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ACMPLS (IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	ACMPLS Advanced Chocolatey Meta Package List Search nothing was found!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ACMPLS GoTo eploop
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACMPLS Advanced Chocolatey Meta Package List Search set to {%ACMPLS%}! >> %LOG_LOCATION%\%LOG_FILE%
FOR /F "tokens=%ACL_COUNTER%" %%L IN ("%CHOCO_META_PACKAGE_LIST%") DO (
	IF EXIST "%CHOCO_PACKAGE_LIST_LOCATION%\criteria_Chocolatey_%%L_Packages.txt" SET ADVANCED_CHOCOTALEY_CRITERIA_FILE=criteria_Chocolatey_%%L_Packages.txt)
IF DEFINED ADVANCED_CHOCOTALEY_CRITERIA_FILE (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ADVANCED_CHOCOTALEY_CRITERIA_FILE just got set to {%ADVANCED_CHOCOTALEY_CRITERIA_FILE%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST "%CHOCO_PACKAGE_LIST_LOCATION%\%ADVANCED_CHOCOTALEY_CRITERIA_FILE%" SET /P ACSC= < "%CHOCO_PACKAGE_LIST_LOCATION%\%ADVANCED_CHOCOTALEY_CRITERIA_FILE%"
IF DEFINED ACSC (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACSC Advanced Chocolatey Search Criteria just got set to {%ACSC%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS SET /A "ACL_COUNTER=ACL_COUNTER+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACL Advanced Chocolatey List Counter is set to {%ACL_COUNTER%}! >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS SET ACS_COUNTER=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACS Advanced Chocolatey Search Counter is set to {%ACS_COUNTER%}! >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED ACMPLS (GoTo ssloop) ELSE (GoTo esloop)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine Primary Loop >> %LOG_LOCATION%\%LOG_FILE%


:ssloop
:: start the secondary loop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine Secondary loop >> %LOG_LOCATION%\%LOG_FILE%
SET CSW=
FOR /F "tokens=%ACS_COUNTER%" %%W IN ("%ACSC%") DO SET CSW=%%W
IF DEFINED CSW (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CSW Chocolatey Search Word set to {%CSW%}!) >> %LOG_LOCATION%\%LOG_FILE%
:: If criteria search word is not defined there were no more search terms
IF NOT DEFINED CSW (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CSW Chocolatey Search Word no search term found!) >> %LOG_LOCATION%\%LOG_FILE%
:: If CSW is not set, that means there are no more search terms
IF NOT DEFINED CSW GoTo sploop
FOR /F "tokens=%ACS_COUNTER%" %%S IN ("%ACSC%") DO ((ECHO %COMPUTERNAME%) | FIND /I "%%S")
IF %ERRORLEVEL% EQU 0 SET ADVANCED_CHOCOLATEY_META_PACKAGE=%ACMPLS%
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ADVANCED_CHOCOLATEY_META_PACKAGE is set to {%ADVANCED_CHOCOLATEY_META_PACKAGE%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE SET /A "ACS_COUNTER=ACS_COUNTER+1"
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	ACS_COUNTER is now set to {%ACS_COUNTER%} >> %LOG_LOCATION%\%LOG_FILE%
:: fail safe?
IF %ACS_COUNTER% GTR 20 GoTo sploop
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE GoTo eploop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine Secondary loop >> %LOG_LOCATION%\%LOG_FILE%
GoTo ssloop
:: end the secondary loop
:esloop

:: end the primary loop
:eploop
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine Primary ^& Secondary loops >> %LOG_LOCATION%\%LOG_FILE%
:: Always defaults to the Universal CHOCO_PACKAGE
:: SET CHOCO_META_PACKAGE=Universal
:: SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt
IF DEFINED ADVANCED_CHOCOLATEY_META_PACKAGE SET CHOCO_META_PACKAGE=%ADVANCED_CHOCOLATEY_META_PACKAGE%
IF DEFINED CHOCO_META_PACKAGE SET CHOCO_PACKAGE_LIST_FILE=Chocolatey_%CHOCO_META_PACKAGE%_Packages.txt
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCO_META_PACKAGE is now set to {%CHOCO_META_PACKAGE%}! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	CHOCO_PACKAGE_LIST_FILE is now set to [%CHOCO_PACKAGE_LIST_FILE%]! >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE% SET CHOCOLATEY_ADVANCED=0
IF EXIST %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Package list file is set to {%CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%}!) >> %LOG_LOCATION%\%LOG_FILE%
ECHO The following Choco list will be used: %CHOCO_PACKAGE_LIST_LOCATION%\%CHOCO_PACKAGE_LIST_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine [3] Advanced Chocolatey >> %LOG_LOCATION%\%LOG_FILE%
GoTo fchoco


:subr4
:: Sub-Routine 4 (Windows Registry)
::  disable auto-login
::   avoids having to use the GUI "netplwiz"
ECHO Processing Windows Registry...
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Sub-Routine [4] Windows Registry >> %LOG_LOCATION%\%LOG_FILE%
FOR /F "tokens=3 delims= " %%R IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon') DO SET REG_AUTOADMINLOGON=%%R
IF NOT %REG_AUTOADMINLOGON% EQU 0 (REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /d 0)
FOR /F "tokens=3 delims= " %%R IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon') DO SET REG_AUTOADMINLOGON_CHK=%%R
IF %ERRORLEVEL% EQU 0 (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Registry Key [AutoAdminLogon] set to {%REG_AUTOADMINLOGON_CHK%}!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Sub-Routine [4] Windows Registry >> %LOG_LOCATION%\%LOG_FILE%
GoTo jump4

:://///////////////////////////////////////////////////////////////////////////

::*****************************************************************************

:end
:: Processing end
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: end >> %LOG_LOCATION%\%LOG_FILE%
::	Check to see if everything has actually run
::		current actions is a total of %PROCESS_CHECK_NUMBER%
SET PROCESS_COUNT=0
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	PROCESS_COUNT reset to: %PROCESS_COUNT% >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_1_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_2_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_3_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_4_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_5_FILE_NAME% SET /A PROCESS_COUNT+=1
IF EXIST %LOG_LOCATION%\%PROCESS_6_FILE_NAME% SET /A PROCESS_COUNT+=1
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Current Process Count: %PROCESS_COUNT% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Process Check Number: %PROCESS_CHECK_NUMBER% >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_1_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_1_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_1_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_2_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_2_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_2_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_3_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_3_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_3_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_4_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_4_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_4_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_5_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_5_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_5_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% (Type %LOG_LOCATION%\%PROCESS_6_FILE_NAME% >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
IF %PROCESS_COUNT% EQU %PROCESS_CHECK_NUMBER% del /F /Q %LOG_LOCATION%\%PROCESS_6_FILE_NAME% && (
	IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_6_FILE_NAME% file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
:: Logging output for COMPLETE OR INCOMPLETE
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%PROCESS_COMPLETE_FILE% just got created!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Post-Flight completed %PROCESS_COUNT% tasks!) >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% ECHO %DATE% %TIME% POST-FLIGH is INCOMPLETE! Check main log [%LOG_FILE%] for details! >> %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log
IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG] [INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log] just got created!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	POST-FLIGH is INCOMPLETE!) >> %LOG_LOCATION%\%LOG_FILE%

:: Text file cleanup when everything is complete
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log DEL /F /Q %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log)
IF NOT EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (
     IF EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log (TYPE %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)
	 ) && IF EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log DEL /F /Q %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
IF NOT EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log] deleted!) >> %LOG_LOCATION%\%LOG_FILE%
::  systeminfo file
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (
     IF EXIST %LOG_LOCATION%\var\var_systeminfo.txt (
	      TYPE %LOG_LOCATION%\var\var_systeminfo.txt >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%))
IF EXIST %LOG_LOCATION%\var\var_systeminfo.txt DEL /F /Q %LOG_LOCATION%\var\var_systeminfo.txt
IF NOT EXIST %LOG_LOCATION%\var\var_systeminfo.txt (
     IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [var_systeminfo.txt] deleted!) >> %LOG_LOCATION%\%LOG_FILE%

IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (
	IF EXIST %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt DEL /F /Q %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt)
IF NOT EXIST %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt (
     IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [var_systeminfo_TimeZone.txt] deleted!) >> %LOG_LOCATION%\%LOG_FILE%

IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (
	IF EXIST %LOG_LOCATION%\var\var_WPF_SHA256_check.txt DEL /F /Q %LOG_LOCATION%\var\var_WPF_SHA256_check.txt)
IF NOT EXIST %LOG_LOCATION%\var_var_WPF_SHA256_check.txt (
     IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File {var_WPF_SHA256_check.txt} deleted!) >> %LOG_LOCATION%\%LOG_FILE%

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Jump4! >> %LOG_LOCATION%\%LOG_FILE%
:: Process Registry Sub-Routine
GoTo subr4
:jump4
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Jump4! >> %LOG_LOCATION%\%LOG_FILE%

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Task Scheduler cleanup! >> %LOG_LOCATION%\%LOG_FILE%
:: cleanup the scheduled task
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (
     IF EXIST %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt (TYPE %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%)) && DEL /F /Q %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt
IF NOT EXIST %LOG_LOCATION%\TASK_SCHEDULER_%SCRIPT_NAME%.txt (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	{TASK_SCHEDULER_%SCRIPT_NAME%.txt} file just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (SCHTASKS /Query /TN "%SCRIPT_NAME%") && (SCHTASKS /Delete /TN "%SCRIPT_NAME%" /F)
IF EXIST %LOG_LOCATION%\INCOMPLETE_%SCRIPT_NAME%_%SCRIPT_VERSION%.log (SCHTASKS /Query /TN "%SCRIPT_NAME%") && (SCHTASKS /Delete /TN "%SCRIPT_NAME%" /F)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Task Scheduler cleanup! >> %LOG_LOCATION%\%LOG_FILE%

:: Cleanup the domain user that was added to local Administrators group
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% NET LOCALGROUP Administrators | FIND /I "%NETDOM_USERD%" && NET LOCALGROUP Administrators %NETDOM_USERD% /DELETE
SET DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABVLE: DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL: {%DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL%} >> %LOG_LOCATION%\%LOG_FILE%
IF %DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 0 (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Domain user {%NETDOM_USERD%} was just deleted from the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 2 (
	IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Domain User {%NETDOM_USERD%} was not in the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 1 (
	IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Domain User {%NETDOM_USERD%} could not be removed from the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)

:: Cleanup up the Default user from unattend.xml that was added to local Administrators group
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% NET LOCALGROUP Administrators | FIND /I "%DEFAULT_USER%" && NET LOCALGROUP Administrators %DEFAULT_USER% /DELETE
SET DEFAULTUSER_LOCALGROUP_DELETE_ERRORLEVEL=%ERRORLEVEL%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	{DOMAINUSER_LOCALGROUP_DELETE_ERRORLEVEL} equals %DEFAULTUSER_LOCALGROUP_DELETE_ERRORLEVEL% >> %LOG_LOCATION%\%LOG_FILE%
IF %DEFAULTUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 0 (
	IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Default user from unattend.xml [%DEFAULT_USER%] was just deleted from the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DEFAULTUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 2 (
	IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Default user from unattend.xml [%DEFAULT_USER%] was not in the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)
IF %DEFAULTUSER_LOCALGROUP_DELETE_ERRORLEVEL% EQU 1 (
	IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Default user from unattend.xml [%DEFAULT_USER%] could not be removed from the local administrators group! >> %LOG_LOCATION%\%LOG_FILE%
	)

:endc
:: ending when complete (this is a jump spot for err100 --when everything is already done).
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Ending for complete >> %LOG_LOCATION%\%LOG_FILE%
:: 	the following var_files get created each time the commandlet runs 
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (DEL /F /Q %LOG_LOCATION%\var\var_*.txt)
dir /B %LOG_LOCATION% | FIND /I "var_" && IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	All the var_ files have been deleted! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF %SEED_LOCATION_CLEANUP% EQU 1) IF EXIST "%LOG_LOCATION%\var" RD /S /Q "%LOG_LOCATION%\var"
IF %SEED_LOCATION_CLEANUP% EQU 1 (IF NOT EXIST "%LOG_LOCATION%\var" (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VAR LOCATION {%LOG_LOCATION%\var} has been deleted!)) >> %LOG_LOCATION%\%LOG_FILE%
::  cleaning up the post flight directory
IF EXIST %POST_FLIGHT_DIR% DEL /F /Q /A:H %POST_FLIGHT_DIR%\*.*
IF EXIST %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE% DEL /F /Q /A:H %POST_FLIGHT_DIR%\%LOCAL_ADMIN_PW_FILE%
IF EXIST %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE% DEL /F /Q /A:H %POST_FLIGHT_DIR%\%NETDOM_USERD_PW_FILE%
IF EXIST %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log DEL /F /Q %LOG_LOCATION%\updated_POST-FLIGHT-SEED_%SCRIPT_VERSION%.log
::  Seed location cleanup
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: SEED cleanup >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 0 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Leaving SEED LOCATION contents!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	SEED_LOCATION_CLEANUP is set to: %SEED_LOCATION_CLEANUP% >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 1 (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Cleaning up SEED LOCATION [%POST_FLIGHT_DIR%], but leaving logs) >> %LOG_LOCATION%\%LOG_FILE%
IF %SEED_LOCATION_CLEANUP% EQU 1 (ROBOCOPY %POST_FLIGHT_DIR% %POST_FLIGHT_DIR%\TOBEDELETED *.* /S /E /MOVE /R:1 /W:2 /XF %SCRIPT_NAME%.cmd /XD Logs TOBEDELETED)
IF EXIST %POST_FLIGHT_DIR%\TOBEDELETED RD /S /Q %POST_FLIGHT_DIR%\TOBEDELETED
IF %SEED_LOCATION_CLEANUP% EQU 1 (IF NOT EXIST %POST_FLIGHT_DIR%\TOBEDELETED (IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	SEED LOCATION [%POST_FLIGHT_DIR%] has been cleaned up!)) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: SEED cleanup >> %LOG_LOCATION%\%LOG_FILE%

::	Avoid ERROR Section
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: end >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                    START ERROR SECTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 00's (DEPENDENCY ERROR)

:errCONF
:: ERROR CONF is a FATAL ERROR for NO configuration file
Color 4E
ECHO %ISO_DATE% %TIME% [FATAL]	FATAL ERROR! NO CONFIGURATION FILE [.\%CONFIG_FILE_NAME%] FOUND! >> %TEMP%\%SCRIPT_NAME%_%SCRIPT_VERSION%.log
ECHO FATAL ERROR!
ECHO NO CONFIGURATION FILE WAS FOUND
PAUSE
EXIT 

:err00
:: ERROR 00 FATAL ERROR for folder cannot be created
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error00 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Folder {%LOG_LOCATION%} could not be created! Aborting! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Folder {%LOG_LOCATION%\var} could not be created! Aborting! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	Exit error00 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err01
:: ERROR 01 (NETDOM)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error01 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	RSAT NETDOM is not installed! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Aborting %SCRIPT_NAME%! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error01 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err02
:: ERROR 02 (No Host Database Found)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error02 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	The Host File database was not found! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Looking for: %HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Aborting %SCRIPT_NAME% due to host file database [%HOST_FILE_DATABASE_LOCATION%\%HOST_FILE_DATABASE%] NOT FOUND! >> %LOG_LOCATION%\%LOG_FILE%
ECHO FATAL ERROR: NO HOST DATABASE FOUND! ABORTING!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error02 >> %LOG_LOCATION%\%LOG_FILE%
GoTo feTime

:err03
:: ERROR 03 (Configuration file schema doesn't meet minimum version)
CLS
Color 4E
ECHO %ISO_DATE% %TIME% [FATAL]	FATAL ERROR! CONFIGURATION FILE [%CONFIG_FILE_NAME%] SCHEMA DOESN'T MEET MINIMUM VERSION! >> %TEMP%\%SCRIPT_NAME%_%SCRIPT_VERSION%.log
ECHO FATAL ERROR!
ECHO CONFIGURATION FILE SCHEMA DOESN'T MEET MINIMUM VERSION!
PAUSE
EXIT 

:err04
:: ERROR 04 Computer Architecture requirement not met
CLS
Color 4E
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error04 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	The computer doesn't meet the x64 computer architecture requirement! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Aborting %SCRIPT_NAME%! >> %LOG_LOCATION%\%LOG_FILE%
ECHO The computer doesn't meet the x64 computer architecture requirement!
ECHO Aborting %SCRIPT_NAME%! 
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error04 >> %LOG_LOCATION%\%LOG_FILE%
TIMEOUT 60
GoTo feTime


:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 10's (Local Administrator)
:err10
:: ERROR 10 Local Administrator configuration failed
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error10 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Local Administrator account doesn't exist! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_FATAL% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Aborting %SCRIPT_NAME% due to no default local adminstrator account! >> %LOG_LOCATION%\%LOG_FILE%
ECHO FATAL ERROR: NO LOCAL ADMINISTRATOR ACCOUNT! ABORTING!
GoTo feTime
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error10 >> %LOG_LOCATION%\%LOG_FILE%

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 20's (Disk Configuration)
:err20
:: ERROR 20 Diskpart
::  These errors are from source documentaion:
::   https://technet.microsoft.com/en-us/library/bb490893.aspx
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error20 >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% EQU 1 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	A fatal exception occurred. There may be a serious problem. >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% EQU 2 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	The parameters specified for a DiskPart command were incorrect. >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% EQU 3 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	DiskPart was unable to open the specified script or output file. >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% EQU 4 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	One of the services DiskPart uses returned a failure. >> %LOG_LOCATION%\%LOG_FILE%
IF %DISKPART_ERROR% EQU 5 IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	A command syntax error occurred. The script failed because an object was improperly selected or was invalid for use with that command. >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error20 >> %LOG_LOCATION%\%LOG_FILE%

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 30's (Hostname)

:err30
:: ERROR 30 Hostname
::	ERROR 3 (Failed to rename computer & Failed to join a domain)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error30 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Something went wrong trying to rename the computer! Can't Rename hostname! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error30 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err31
:: ERROR 31 Host file database


:err32
:: ERROR 31 LOCAL MAC
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error31 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	GETMAC error to get computer MAC! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Skipping Steps 3 & 4! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error31 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err33
:: ERROR 33 Setting the hostname
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error33 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Something went wrong with setting the hostname! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Skipping Steps 3 & 4! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error33 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 40's (DOMAIN JOIN)

:err40
:: ERROR 40 (Failed to join Domain General)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error40 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Failed to join domain! [%NETDOM_DOMAIN%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Aborting Domain join! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error40 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err41
::	ERROR 3.1 (Computer failed to join domain due to NETDOM)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error41 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	NETDOM failed to join the computer [%COMPUTERNAME%]to domain [%NETDOM_DOMAIN%]! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Aborting joining the domain! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error41 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:err42
:: No DNS to communicate with configured Windows Domain
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error42 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [FATAL]	Failed to communicate with Windows DNS to [%NETDOM_DOMAIN%] domain! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Aborting joining the domain! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error42 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step5

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 50's (CHOCOLATEY)

:err50
:: ERROR 50 (Chocolatey is not present)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error50 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Chocolatey is not present! Aborting Chocolatey step! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Expecting Chocolatey to be here: %ChocolateyInstall%\choco.exe >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error50 >> %LOG_LOCATION%\%LOG_FILE%
GoTo step6

:err51
:: ERROR 51 (Advanced Chocolatey error catching for NO criteria files)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error51 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	No chocolatey criteria files found! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Aborting advanced chocolatey! >> %LOG_LOCATION%\%LOG_FILE%
SET CHOCOLATEY_ADVANCED=0
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error51 >> %LOG_LOCATION%\%LOG_FILE%
:: return to normal chocolatey package install
GoTo step5

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 60's (ULTIMATE)

:err60
:: ERROR 60 (Ulimate file cannot be found or is off-line)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error60 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	FAILED to load Ultimate FILE [%ULTIMATE_FILE_NAME%] from %ULTIMATE_FILE_LOCATION% >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %ULTIMATE_FILE_LOCATION% ECHO %ISO_DATE% %TIME% [ERROR]	Ultimate file location [%ULTIMATE_FILE_LOCATION%] is OFF-LINE! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	Aborting running [%ULTIMATE_FILE_NAME%]!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error60 >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:err61
:: ERROR 61 (Ulimate file doesn't meet the exit requirements) commandlet self-presevation
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error61 >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ERROR% EQU 1 ECHO %ISO_DATE% %TIME% [ERROR]	The Ultimate commandlet [%ULTIMATE_FILE_NAME%] doesn't meet the "EXIT /B" requirement! >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_WARN% EQU 1 ECHO %ISO_DATE% %TIME% [WARN]	Aborting running the Ultimate commandlet [%ULTIMATE_FILE_NAME%] >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error61 >> %LOG_LOCATION%\%LOG_FILE%
GoTo end

:://///////////////////////////////////////////////////////////////////////////
:: ERROR LEVEL 100 (DONE)
:err100
:: ERROR 100 (Everything already ran)
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: error100 >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [INFO]	EVERYTHING IS ALREADY DONE? >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [INFO]	%PROCESS_COMPLETE_FILE% Exists! >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [INFO]	Aborting %SCRIPT_NAME%! >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% ECHO %DATE% %TIME% %SCRIPT_NAME%_%SCRIPT_VERSION% ATTEMPTED BUT ABORTED! >> %LOG_LOCATION%\%PROCESS_COMPLETE_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: error100 >> %LOG_LOCATION%\%LOG_FILE%
GoTo endc

:: END ERROR SECTION
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:feTime
:: FUNCTION: End Time
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION end time >> %LOG_LOCATION%\%LOG_FILE%

:: Calculate lapse time by capturing end time
::	Parsing %TIME% variable to get an interger number
FOR /F "tokens=1 delims=:." %%h IN ("%TIME%") DO SET E_hh=%%h
FOR /F "tokens=2 delims=:." %%h IN ("%TIME%") DO SET E_mm=%%h
FOR /F "tokens=3 delims=:." %%h IN ("%TIME%") DO SET E_ss=%%h
FOR /F "tokens=4 delims=:." %%h IN ("%TIME%") DO SET E_ms=%%h
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	E_hh: %E_hh%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	E_mm: %E_mm%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	E_ss: %E_ss%) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	E_mm: %E_mm%) >> %LOG_LOCATION%\%LOG_FILE%

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
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Time Lapsed (mm:ss.ms): %L_tm%:%L_ss%.%L_ms% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION end time >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:EOF
:: END OF FILE
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: end of file >> %LOG_LOCATION%\%LOG_FILE%
IF EXIST %LOG_LOCATION%\FirstTimeRun.txt DEL /F /Q %LOG_LOCATION%\FirstTimeRun.txt && (IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [FirstTimeRun.txt] just got deleted!) >> %LOG_LOCATION%\%LOG_FILE%
IF DEFINED LOG_SHIPPING_LOCATION IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	WPF Log {%LOG_FILE%} will attempt to ship to {%LOG_SHIPPING_LOCATION%}. >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	END! >> %LOG_LOCATION%\%LOG_FILE%
ECHO END %DATE% %TIME%
Echo. >> %LOG_LOCATION%\%LOG_FILE%
IF %DOMAIN_USER_STATUS% EQU 1 IF DEFINED LOG_SHIPPING_LOCATION IF NOT EXIST "%LOG_SHIPPING_LOCATION%" MD "%LOG_SHIPPING_LOCATION%"
IF %DOMAIN_USER_STATUS% EQU 1 IF DEFINED LOG_SHIPPING_LOCATION COPY /Y "%LOG_LOCATION%\%LOG_FILE%" "%LOG_SHIPPING_LOCATION%"
IF EXIST %LOG_LOCATION%\%PROCESS_COMPLETE_FILE% (IF "%DEFAULT_USER%"=="%CONSOLE_USER%" shutdown /r /t 10)
ENDLOCAL
IF "%DEFAULT_USER%"=="%CONSOLE_USER%" logoff console
TIMEOUT 30
EXIT