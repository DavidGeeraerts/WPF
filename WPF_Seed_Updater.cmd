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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Windows Post Flight Seed updater
:: PURPOSE: Populate or update the flash drive with all needed files
SET Name=Windows_Post-Flight_Seed_Updater
SET Version=1.5.1
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

:: Default Flash Drive Volume
SET FLASH_DRIVE_VOLUME=F:
SET FLASH_DRIVE_VOLUME_KEYWORD=POSTFLIGHT
SET SEED_SOURCE_WPF=D:\David_Geeraerts\Projects\Script Code\Windows Post-Flight
SET SEED_SOURCE_CHOCO=D:\David_Geeraerts\Projects\Script Code\Chocolatey
SET SEED_SOURCE_ULTI=D:\David_Geeraerts\Projects\Script Code
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CLS
echo --------------------------------------------------------------------------
echo.
echo			Windows_Post-Flight_Seed_Updater [%VERSION%]
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
DIR %FLASH_DRIVE_VOLUME% | FIND /I "%FLASH_DRIVE_VOLUME_KEYWORD%" && GoTo run
:: IF NOT THE DEFAULT FLASH DRIVE VOLUME FIND IT
SET FLASH_DRIVE_VOLUME=0
FOR /F "tokens=* delims=:" %%F IN ('FSUTIL VOLUME LIST') DO DIR %%F | FIND /I "%FLASH_DRIVE_VOLUME_KEYWORD%" && SET FLASH_DRIVE_VOLUME=%%F
IF EXIST %FLASH_DRIVE_VOLUME% FOR /F "tokens=1 delims=\" %%P IN ("%FLASH_DRIVE_VOLUME%") DO SET FLASH_DRIVE_VOLUME=%%P
IF %FLASH_DRIVE_VOLUME% EQU 0 GoTo error00 ELSE (ECHO Flash Drive: %FLASH_DRIVE_VOLUME% will be updated!)


:run
:: Main WPF commandlet and config file
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows_Post-Flight.cmd /R:2 /W:5
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" Windows_Post-Flight.config /R:2 /W:5
:: Windows Unattend.xml file
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" unattend.xml /R:2 /W:5
:: Text files
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" *.txt /R:2 /W:5
:: RSAT installer
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_WPF%" "%FLASH_DRIVE_VOLUME%" *.msu /NP /R:2 /W:5
:: All of the Chocolatey support files
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_CHOCO%" "%FLASH_DRIVE_VOLUME%" *.* /R:2 /W:5

:: Ultimate script
IF EXIST %FLASH_DRIVE_VOLUME%\ ROBOCOPY "%SEED_SOURCE_ULTI%" "%FLASH_DRIVE_VOLUME%" SC_Sorcerer's_Apprentice.cmd /R:2 /W:5

IF EXIST %FLASH_DRIVE_VOLUME% dir /O-D %FLASH_DRIVE_VOLUME% 
IF EXIST %FLASH_DRIVE_VOLUME% GoTo EOF

:: Make password files hidden
IF EXIST %FLASH_DRIVE_VOLUME%\Local_Administrator_Password.txt ATTRIB +H %FLASH_DRIVE_VOLUME%\Local_Administrator_Password.txt
IF EXIST %FLASH_DRIVE_VOLUME%\Domain_Join_Password.txt ATTRIB +H %FLASH_DRIVE_VOLUME%\Domain_Join_Password.txt

:error00
cls
IF NOT EXIST %FLASH_DRIVE_VOLUME% COLOR 4A
IF NOT EXIST %FLASH_DRIVE_VOLUME% ECHO No flash drive was found with volume label [%FLASH_DRIVE_VOLUME_KEYWORD%]!
TIMEOUT /T 900

:EOF
ENDLOCAL
TIMEOUT /T 300
EXIT