:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION
::  Semantic Versioning used
::   http://semver.org/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
setlocal enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET "SCRIPT_NAME=Windows Ultimate"
SET SCRIPT_Version=0.0.0
Title %SCRIPT_NAME% Version:%SCRIPT_VERSION%
Prompt SA$G
color 0D
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::#############################################################################
:: Windows Ultimate Commandlet
::	a.k.a The Sorcerer's Apprentice
:: PURPOSE: unruly actions, mischief, and cleanup; a Windows Ultimate commandlet is the last commandlet to run for Windows Post Flight.
::	It's also the commandlet to run for regular maintenance of Windows PC's.

::	Contains 3 sections
::	(1)	INSTALLATIONS
::		a.k.a "Unruly Actions"
::	(2)	CONFIGURATIONS
::		a.k.a "Mischief"
::	(3)	Cleanup
::		a.k.a. "Send in the broom!"
::#############################################################################


::#############################################################################
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::#############################################################################





:: LOGGING
:: Log Files Settings
SET LOG_LOCATION=
SET LOG_FILE=Windows_Ultimate_%COMPUTERNAME%.Log
:: Log File shipping
:: change <server> to server hostname
SET "LOG_SHIPPING_LOCATION=\\<SERVER>\Logs\Ultimate"


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		*******************
::		 Advanced Settings
::		*******************
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Configure a Debugger to auto set all logging
SET DEBUGGER_PC=

:: LOGGING LEVEL CONTROL
::  by default: ALL=0 & DEBUG=0 & TRACE=0
SET LOG_LEVEL_ALL=0
SET LOG_LEVEL_INFO=1
SET LOG_LEVEL_WARN=1
SET LOG_LEVEL_ERROR=1
SET LOG_LEVEL_FATAL=1
SET LOG_LEVEL_DEBUG=0
SET LOG_LEVEL_TRACE=0

:: To cleanup or Not to cleanup, the variable files
::  0 = OFF (NO)
::  1 = ON (YES)
SET VAR_CLEANUP=1

::*****************************************************************************


::#############################################################################
::
::	##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::#############################################################################

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Calculate lapse time by capturing start time
::	Parsing %TIME% variable to get an interger number
SET TIME_START=%Time%
::*****************************************************************************

:: CONSOLE OUTPUT
ECHO ############################################
ECHO Windows Ultimate Commandlet
ECHO.
ECHO a.k.a. %SCRIPT_NAME%
ECHO.
ECHO Purpose [Contains 3 sections]: 
ECHO.
ECHO [1] INSTALLATIONS
ECHO     a.k.a "Unruly Actions"
ECHO.
ECHO [2] CONFIGURATIONS
ECHO     a.k.a "Mischief"
ECHO.
ECHO [3] Cleanup
ECHO     a.k.a. "Send in the broom!"
ECHO.
ECHO ############################################
ECHO.
ECHO.

ECHO Processing...
ECHO.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:dependency

:: LOG
::	Check log location and fallback if needed
IF NOT EXIST "%LOG_LOCATION%" MD "%LOG_LOCATION%" || SET "LOG_LOCATION=%PUBLIC%\Documents"
ECHO TEST Log output %DATE% %TIME% >> %LOG_LOCATION%\test_%LOG_FILE% || SET "LOG_LOCATION=%PUBLIC%\Documents"
IF EXIST %LOG_LOCATION%\test_%LOG_FILE% DEL /Q %LOG_LOCATION%\test_%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var MD %LOG_LOCATION%\var
CD /D "%LOG_LOCATION%"

:: USER
::	user should be a domain user for everything to run properly
ECHO Checking domain user...
ECHO. 
(WHOAMI /FQDN 2> nul) && SET DOMAIN_USER_STATUS=1
IF DEFINED DOMAIN_USER_STATUS GoTo skipD1
(WHOAMI /FQDN 2> nul) || SET DOMAIN_USER_STATUS=0
ECHO.
:skipD1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Powershell CHECK
ECHO Checking on Powershell...
IF NOT DEFINED PSModulePath SET PS_STATUS=0 & GoTo skipPS
IF DEFINED PSModulePath (@powershell $PSVersionTable.PSVersion > %LOG_LOCATION%\var\var_PS_Version.txt) && SET PS_STATUS=1
IF EXIST "%LOG_LOCATION%\var\var_PS_Version.txt" GoTo skipPSv
FOR /F "usebackq skip=3 tokens=1 delims= " %%P IN ("%LOG_LOCATION%\var\var_PS_Version.txt") DO SET "PS_MAJOR_VERSION=%%P"
FOR /F "usebackq skip=3 tokens=2 delims= " %%P IN ("%LOG_LOCATION%\var\var_PS_Version.txt") DO SET "PS_MINOR_VERSION=%%P"
FOR /F "usebackq skip=3 tokens=3 delims= " %%P IN ("%LOG_LOCATION%\var\var_PS_Version.txt") DO SET "PS_BUILD_VERSION=%%P"
FOR /F "usebackq skip=3 tokens=4 delims= " %%P IN ("%LOG_LOCATION%\var\var_PS_Version.txt") DO SET "PS_REVISION_VERSION=%%P"
:skipPSv

:skipPS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:fISO8601
:: Function to ensure ISO 8601 Date format yyyy-mmm-dd
IF %PS_STATUS% EQU 0 GoTo fmanualISO
:: Easiest way to get ISO date
@powershell Get-Date -format "yyyy-MM-dd" > %LOG_LOCATION%\var\var_ISO8601_Date.txt
SET /P ISO_DATE= < %LOG_LOCATION%\var\var_ISO8601_Date.txt


:fmanualISO
:: Manually create the ISO 8601 date format in case powershell not available
IF DEFINED ISO_DATE GoTo skipfmiso
FOR /F "tokens=2 delims=/ " %%T IN ("%DATE%") DO SET ISO_MONTH=%%T
FOR /F "tokens=3 delims=/ " %%T IN ("%DATE%") DO SET ISO_DAY=%%T
FOR /F "tokens=4 delims=/ " %%T IN ("%DATE%") DO SET ISO_YEAR=%%T
SET ISO_DATE=%ISO_YEAR%-%ISO_MONTH%-%ISO_DAY%

:skipfmiso
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:start


::	Certain test computers should always have ALL logging turned on
(HOSTNAME | FIND /I "%DEBUGGER_PC%" 2> nul) && (SET LOG_LEVEL_ALL=1) && (SET VAR_CLEANUP=0)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




:: Check for ALL logging
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	START DEBUGGING...) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [DEBUG]	ALL LOGGING IS TURNED ON!) >> %LOG_LOCATION%\%LOG_FILE%

:: LOGGING LEVEL
:flogl
:: FUNCTION: Check and configure for ALL LOG LEVEL
IF %LOG_LEVEL_ALL% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: function Check for ALL log level...) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_INFO=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_WARN=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_ERROR=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_FATAL=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_DEBUG=1
IF %LOG_LEVEL_ALL% EQU 1 SET LOG_LEVEL_TRACE=1
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: function Check for ALL log level.) >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO Gthering general information...
ECHO.
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: General Information...) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	START... >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Script Name: %SCRIPT_NAME% %SCRIPT_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Script Version: %SCRIPT_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
IF NOT EXIST %LOG_LOCATION%\var\var_systeminfo.txt systeminfo > %LOG_LOCATION%\var\var_systeminfo.txt
IF NOT EXIST %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt (
	FOR /F "tokens=2-3 delims=(" %%S IN ('systeminfo ^| FIND /I "Time Zone"') Do ECHO Time Zone: ^(%%S^(%%T > %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt
	) && IF EXIST "%LOG_LOCATION%\var\var_systeminfo_TimeZone.txt" IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	File [var_systeminfo_TimeZone.txt] created! >> %LOG_LOCATION%\%LOG_FILE%
SET /P var_TimeZone= < %LOG_LOCATION%\var\var_systeminfo_TimeZone.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	"%var_TimeZone%" >> %LOG_LOCATION%\%LOG_FILE%
whoami > %LOG_LOCATION%\var\var_whoami.txt
IF %DOMAIN_USER_STATUS% EQU 1 WHOAMI /FQDN > %LOG_LOCATION%\var\var_whoami_fqdn.txt
SET /P APPRENTICE= < %LOG_LOCATION%\var\var_whoami.txt
IF %DOMAIN_USER_STATUS% EQU 1 SET /P APPRENTICE_FQDN= < %LOG_LOCATION%\var\var_whoami_fqdn.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%APPRENTICE% >> %LOG_LOCATION%\%LOG_FILE%
IF %DOMAIN_USER_STATUS% EQU 1 IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	%APPRENTICE_FQDN% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%COMPUTERNAME% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	Power Shell Version: Major: %PS_MAJOR_VERSION% Minor: %PS_MINOR_VERSION% Build: %PS_BUILD_VERSION% Revision: %PS_BUILD_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: General Information...) >> %LOG_LOCATION%\%LOG_FILE%
::*****************************************************************************

:varS
:: Start of variable debug
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Variable debug!) >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_DEBUG% EQU 0 GoTo varE
ECHO %ISO_DATE% %TIME% [DEBUG]	SCRIPT_NAME: %SCRIPT_NAME% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	SCRIPT_VERSION: %SCRIPT_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LOCATION: %LOG_LOCATION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_FILE: %LOG_FILE% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_SHIPPING_LOCATION: %LOG_SHIPPING_LOCATION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	[C]urrent[D]irectory: %CD% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_ALL: %LOG_LEVEL_ALL% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_INFO: %LOG_LEVEL_INFO% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_WARN: %LOG_LEVEL_WARN% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_ERROR: %LOG_LEVEL_ERROR% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_FATAL: %LOG_LEVEL_FATAL% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_DEBUG: %LOG_LEVEL_DEBUG% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	LOG_LEVEL_TRACE: %LOG_LEVEL_TRACE% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_hh: %S_hh% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_mm: %S_mm% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_ss: %S_ss% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	S_ms: %S_ms% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	PS_MAJOR_VERSION: %PS_MAJOR_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	PS_MINOR_VERSION: %PS_MINOR_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	PS_BUILD_VERSION: %PS_BUILD_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	PS_REVISION_VERSION: %PS_REVISION_VERSION% >> %LOG_LOCATION%\%LOG_FILE%
ECHO %ISO_DATE% %TIME% [DEBUG]	ISO_DATE: %ISO_DATE% >> %LOG_LOCATION%\%LOG_FILE%
:varE
IF %LOG_LEVEL_TRACE% EQU 1 (ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Variable debug!) >> %LOG_LOCATION%\%LOG_FILE%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:INSTALLATIONS
:: !Unruly Actions!
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: INSTALLATIONS: unruly actions. >> %LOG_LOCATION%\%LOG_FILE%




:: END Unruly Actions!
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: INSTALLATIONS: unruly actions. >> %LOG_LOCATION%\%LOG_FILE%
::*****************************************************************************


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CONFIGURATIONS
:: !Mischief!
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: CONFIGURATIONS: Start the mischief! >> %LOG_LOCATION%\%LOG_FILE%



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		Application Fixes
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		Start Menu Application Shortcuts
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: CONFIGURATIONS: Application Start Menu shortcuts. >> %LOG_LOCATION%\%LOG_FILE%

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: CONFIGURATIONS: Application Start Menu shortcuts. >> %LOG_LOCATION%\%LOG_FILE%
:skipSMS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:power
:: Power Scheme
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: CONFIGURATIONS: Power Scheme. >> %LOG_LOCATION%\%LOG_FILE%
::	Going to set power scheme and modify display turn-off setting
::		the GUID should be universal to Windows	(Hih Performance)
Powercfg /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
::			value in minutes
Powercfg /CHANGE monitor-timeout-ac 20
::		just for good measure
Powercfg /HIBERNATE Off
powercfg /GETACTIVESCHEME > %LOG_LOCATION%\var\var_powercfg.txt
SET /P POWER_SCHEME= < %LOG_LOCATION%\var\var_powercfg.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	%POWER_SCHEME% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: CONFIGURATIONS: Power Scheme. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::





:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::			Scheduled Task Configuration
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: CONFIGURATIONS: Scheduled Task Creation... >> %LOG_LOCATION%\%LOG_FILE%





IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: CONFIGURATIONS: Scheduled Task Creation. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: CONFIGURATIONS: Start the mischief. >> %LOG_LOCATION%\%LOG_FILE%
::*****************************************************************************


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Clean
:: !Cleanup!
::	(send in the broom!)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: CLEANUP: send in the broom... >> %LOG_LOCATION%\%LOG_FILE%





IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: CLEANUP: send in the broom. >> %LOG_LOCATION%\%LOG_FILE%
::*****************************************************************************

IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Variable [var] file cleanup... >> %LOG_LOCATION%\%LOG_FILE%
:: Commandlet cleanup
IF %VAR_CLEANUP% EQU 1 IF EXIST %LOG_LOCATION%\var RD /S /Q %LOG_LOCATION%\var
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: Variable [var] file cleanup. >> %LOG_LOCATION%\%LOG_FILE%

:: Calculate lapse time
:Time
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: Time lapse end... >> %LOG_LOCATION%\%LOG_FILE%
:: capturing end time
::	End Time
SET TIME_END=%TIME%
IF %LOG_LEVEL_DEBUG% EQU 1 ECHO %ISO_DATE% %TIME% [DEBUG]	VARIABLE: TIME_END: %TIME_END% >> %LOG_LOCATION%\%LOG_FILE%

:: Calculate the actual lapse time
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	ENTER: FUNCTION lapse time >> %LOG_LOCATION%\%LOG_FILE%
IF %PS_STATUS% EQU 0 GoTo skipPSLT
@PowerShell.exe -c "$span=([datetime]'%Time_End%' - [datetime]'%Time_Start%'); '{0:00}:{1:00}:{2:00}' -f $span.Hours, $span.Minutes, $span.Seconds" > %LOG_LOCATION%\var\var_Time_Lapse.txt
IF EXIST %LOG_LOCATION%\var\var_Time_Lapse.txt SET /P TIME_LAPSE= < %LOG_LOCATION%\var\var_Time_Lapse.txt
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	Time Lapsed (hh:mm.ss): %TIME_LAPSE% >> %LOG_LOCATION%\%LOG_FILE%
:skipPSLT
:: Time Lapse
IF NOT DEFINED TIME_LAPSE IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	End time: %TIME_END% >> %LOG_LOCATION%\%LOG_FILE%
IF %LOG_LEVEL_TRACE% EQU 1 ECHO %ISO_DATE% %TIME% [TRACE]	EXIT: FUNCTION lapse time. >> %LOG_LOCATION%\%LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:EOF
:: END OF FILE
IF %LOG_LEVEL_INFO% EQU 1 ECHO %ISO_DATE% %TIME% [INFO]	END. >> %LOG_LOCATION%\%LOG_FILE%
Echo. >> %LOG_LOCATION%\%LOG_FILE%
:: Log Shipping if configured
IF DEFINED LOG_SHIPPING_LOCATION IF NOT EXIST %LOG_SHIPPING_LOCATION% MD %LOG_SHIPPING_LOCATION%
IF DEFINED LOG_SHIPPING_LOCATION COPY /Y %LOG_LOCATION%\%LOG_FILE% %LOG_SHIPPING_LOCATION%

ENDLOCAL
EXIT /B