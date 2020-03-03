:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: David Geeraerts
:: Location: Olympia, Washington USA
:: E-Mail: geeraerd@evergreen.edu

:: Copyleft License(s)
:: GNU GPL Version 3
:: https://www.gnu.org/licenses/gpl.html

:: Creative Commons: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)  
:: http://creativecommons.org/licenses/by-nc-sa/3.0/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION
::  Semantic Versioning used
::   http://semver.org/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
setlocal enableextensions
CD %~dp1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Windows Post Flight Seed updater
:: PURPOSE: Populate or update the flash drive with all needed files
SET Name=Windows_Post-Flight_Seed_Updater
SET Version=3.5.0
Title %Name% Version:%Version%
Prompt WPF$G
color 0B
mode con:cols=85
mode con:lines=50

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Master PC
SET MASTER_PC=SC-Sphere

:: Default Flash Drive Volume
SET FLASH_DRIVE_VOLUME=F:
SET FLASH_DRIVE_VOLUME_KEYWORD=POSTFLIGHT
SET SEED_SOURCE_WPF=D:\David_Geeraerts\Projects\Script Code\Windows Post-Flight
SET SEED_SOURCE_CHOCO=D:\David_Geeraerts\Projects\Script Code\Chocolatey
SET SEED_SOURCE_ULTI=D:\David_Geeraerts\Projects\Script Code\Windows_Ultimate_Commandlet
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
echo --------------------------------------------------------------------------
echo.
echo			Windows_Post-Flight_Dev_Seed_Updater [%VERSION%]
echo.
echo --------------------------------------------------------------------------
echo.
echo.
echo This commandlet will update a Windows Post Flight flash drive.
echo The Flash drive will act as a seed for a Windows computer to 
echo	process Windows Post Flight.
echo.
ECHO %DATE% %TIME%
echo.
echo Looking for a Flash drive with volume label: %FLASH_DRIVE_VOLUME_KEYWORD%
echo.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Determine where running from: Master or elsewhere
(hostname | find /I "%MASTER_PC%" 2> nul) && GoTo skipD
SET "SEED_SOURCE_WPF=\\%MASTER_PC%\D$\David_Geeraerts\Projects\Script Code\Windows Post-Flight"
SET "SEED_SOURCE_CHOCO=\\%MASTER_PC%\D$\David_Geeraerts\Projects\Script Code\Chocolatey"
SET "SEED_SOURCE_ULTI=\\%MASTER_PC%\D$\David_Geeraerts\Projects\Script Code\Windows_Ultimate_Commandlet"
:skipD


(DIR %FLASH_DRIVE_VOLUME% 2> nul) | (FIND /I "%FLASH_DRIVE_VOLUME_KEYWORD%" 2> nul) && GoTo run
:: IF NOT THE DEFAULT FLASH DRIVE VOLUME FIND IT
SET FLASH_DRIVE_VOLUME=0
FOR /F "tokens=* delims=:" %%F IN ('FSUTIL VOLUME LIST') DO DIR %%F | (FIND /I "%FLASH_DRIVE_VOLUME_KEYWORD%" 2> nul) && SET FLASH_DRIVE_VOLUME=%%F
IF EXIST %FLASH_DRIVE_VOLUME% FOR /F "tokens=1 delims=\" %%P IN ("%FLASH_DRIVE_VOLUME%") DO SET FLASH_DRIVE_VOLUME=%%P
IF %FLASH_DRIVE_VOLUME% EQU 0 GoTo error00 ELSE (ECHO Flash Drive: %FLASH_DRIVE_VOLUME% will be updated!)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:run
:: Main WPF commandlet and config file
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows-Post-Flight-dev.cmd /R:2 /W:5
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows-Post-Flight-dev.config /R:2 /W:5
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows-Post-Flight-debugger.config /R:2 /W:5
IF EXIST "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight.cmd" DEL /Q "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight.cmd"
IF EXIST "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight.config" DEL /Q "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight.config" 
IF EXIST "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight-dev.cmd" rename "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight-dev.cmd" Windows-Post-Flight.cmd
::IF EXIST "%FLASH_DRIVE_VOLUME%\Windows_Post-Flight-dev.config" rename "%FLASH_DRIVE_VOLUME%\Windows_Post-Flight-dev.config" Windows_Post-Flight.config
IF EXIST "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight-debugger.config" rename "%FLASH_DRIVE_VOLUME%\Windows-Post-Flight-debugger.config" Windows-Post-Flight.config
:: Windows Unattend.xml file
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" unattend.xml /R:2 /W:5
:: Text files
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" *.txt /R:2 /W:5
:: RSAT installer
:: Deprecating
:: IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" *.msu /NP /R:2 /W:5
:: All of the Chocolatey support files
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_CHOCO%" "%FLASH_DRIVE_VOLUME%" *.* /R:2 /W:5
:: Shortcut link
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows-Post-Flight.lnk /R:2 /W:5
:: Ultimate script
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_ULTI%" "%FLASH_DRIVE_VOLUME%" SC_Sorcerer's_Apprentice_Dev.cmd /R:2 /W:5
IF EXIST "%FLASH_DRIVE_VOLUME%\SC_Sorcerer's_Apprentice.cmd" del /F /Q "%FLASH_DRIVE_VOLUME%\SC_Sorcerer's_Apprentice.cmd"
IF EXIST "%FLASH_DRIVE_VOLUME%\SC_Sorcerer's_Apprentice_Dev.cmd" rename "%FLASH_DRIVE_VOLUME%\SC_Sorcerer's_Apprentice_Dev.cmd"  SC_Sorcerer's_Apprentice.cmd

IF EXIST %FLASH_DRIVE_VOLUME% dir /O-D %FLASH_DRIVE_VOLUME% 
IF EXIST %FLASH_DRIVE_VOLUME% GoTo EOF

:: Make password files hidden
IF EXIST %FLASH_DRIVE_VOLUME%\Local_Administrator_Password.txt ATTRIB +H %FLASH_DRIVE_VOLUME%\Local_Administrator_Password.txt
IF EXIST %FLASH_DRIVE_VOLUME%\Domain_Join_Password.txt ATTRIB +H %FLASH_DRIVE_VOLUME%\Domain_Join_Password.txt

:: Make DEBUGGER file
IF EXIST %FLASH_DRIVE_VOLUME% ECHO %DATE% %TIME% Updated! > %FLASH_DRIVE_VOLUME%\DEBUGGER.txt

:error00
cls
IF NOT EXIST %FLASH_DRIVE_VOLUME% COLOR 4A
IF NOT EXIST %FLASH_DRIVE_VOLUME% ECHO No flash drive was found with volume label [%FLASH_DRIVE_VOLUME_KEYWORD%]!
TIMEOUT /T 900

:EOF
ENDLOCAL
TIMEOUT /T 300
EXIT