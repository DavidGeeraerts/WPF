:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: David Geeraerts
:: Location: Olympia, Washington USA
:: E-Mail: geeraerd@evergreen.edu

:: Copyleft License(s)
:: GNU GPL Version 3
:: https://www.gnu.org/licenses/gpl.html


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION
::  Semantic Versioning used
::   http://semver.org/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
setlocal enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Windows Post Flight Seed updater
:: PURPOSE: Populate or update the flash drive with all needed files
SET Name=Windows_Post-Flight_Production_Post
SET Version=1.2.0
Title %Name% Version:%Version%
Prompt WPFPU$G
color 0B
mode con:cols=85
mode con:lines=50

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Master REPO
SET "MASTER_SOURCE_WPF=D:\Projects\Script Code\Windows-Post-Flight"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
echo --------------------------------------------------------------------------
echo.
echo			%NAME%
echo.
ECHO %DATE% %TIME%
echo --------------------------------------------------------------------------
echo.
echo.
echo This commandlet will update a Windows Post Flight MASTER repository
echo.
echo.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CD /D %MASTER_SOURCE_WPF%
echo Processing attributes...
ATTRIB -H .\Configurations\Domain_Join_Password.txt
ATTRIB -H .\Configurations\Local_Administrator_Password.txt
ATTRIB -A /S /D
ATTRIB +H .\Configurations\Domain_Join_Password.txt
ATTRIB +H .\Configurations\Local_Administrator_Password.txt
:: DELETE THE OLD FILES
DEL /Q "%MASTER_SOURCE_WPF%\Windows-Post-Flight.cmd.old" 2> nul
DEL /Q "%MASTER_SOURCE_WPF%\Windows-Post-Flight.config.old" 2> nul
echo old deleted
echo.
:: RENAME THE WORKING FILES TO OLD
RENAME "%MASTER_SOURCE_WPF%\Windows-Post-Flight.cmd" "Windows-Post-Flight.cmd.old"
echo working renamed to old 
echo.
:: COPY DEVELOPER FILES TO WORKING FILES Keeping DEV
COPY /Y "%MASTER_SOURCE_WPF%\Windows-Post-Flight-dev.cmd" "%MASTER_SOURCE_WPF%\Windows-Post-Flight.cmd"
REM The dev.config is different and shouldn't be copied
REM Changes to dev.config should be manually merged into the working config.
:: COPY /Y "%MASTER_SOURCE_WPF%\Windows-Post-Flight-dev.config" "%MASTER_SOURCE_WPF%\Windows-Post-Flight.config"
echo dev copied to working
echo.
:: UPDATE THE SHA256 FILE
IF EXIST "var_get_WPF_SHA256.txt" DEL /Q /F var_get_WPF_SHA256.txt
FOR /F "skip=1 tokens=1" %%P IN ('certUtil -hashfile "%MASTER_SOURCE_WPF%\Windows-Post-Flight.cmd" SHA256') DO ECHO %%P>> var_get_WPF_SHA256.txt
SET /P VAR_GET_WPF_SHA256= < var_get_WPF_SHA256.txt
ECHO %VAR_GET_WPF_SHA256%> "%MASTER_SOURCE_WPF%\Windows-Post-Flight_SHA256.txt"
del /Q var_get_WPF_SHA256.txt
echo SHA256 updated.
echo.

:: Ignore certain files
ATTRIB -A *.old
CLS
echo --------------------------------------------------------------------------
echo.
echo			%NAME%
echo.
ECHO %DATE% %TIME%
echo --------------------------------------------------------------------------
:: Report out
echo.
echo The following files have been updated:
echo.
dir /A:-DA
dir /A:-DA .\Configurations 2> nul
ENDLOCAL
TIMEOUT /T 120
EXIT