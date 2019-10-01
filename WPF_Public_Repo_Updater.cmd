:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author: David Geeraerts
:: Location: Olympia, Washington USA
:: E-Mail: geeraerd@evergreen.edu

:: Copyleft License(s)
:: GNU GPL Version 3
:: https://www.gnu.org/licenses/gpl.html

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
SET Name=Windows_Post-Flight_Public_Repo_Updater
SET Version=1.1.0
Title %Name% Version:%Version%
Prompt WPF$G
color 1A
mode con:cols=85
mode con:lines=50

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Default Flash Drive Volume
SET "WPF_PUBLIC_REPO=D:\David_Geeraerts\Projects\Script Code\Windows Post-Flight\Public"
SET "WPF_DEV_REPO=D:\David_Geeraerts\Projects\Script Code\Windows Post-Flight"
SET "WUC=D:\David_Geeraerts\Projects\Script Code\Windows_Ultimate_Commandlet"
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
echo This commandlet will update the Windows Post Flight Public Repository...
echo.
echo.
ECHO %DATE% %TIME%
echo.
echo.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:run
:: MAIN cmd
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" Windows-Post-Flight.cmd /R:2 /W:5
:: Config file
:: ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" Windows_Post-Flight.config /R:2 /W:5
:: SHA256
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" Windows-Post-Flight_SHA256.txt /R:2 /W:5
:: ReadMe
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" README.md /R:2 /W:5
:: License
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" LICENSE.md /R:2 /W:5
:: Default Diskpart
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" DiskPart_Hard_Drive_Config.txt /R:2 /W:5
:: Change Log
ROBOCOPY "%WPF_DEV_REPO%" "%WPF_PUBLIC_REPO%" Changelog.md /R:2 /W:5
:: Windows Ultimate Template
ROBOCOPY "%WUC%" "%WPF_PUBLIC_REPO%" Windows_Ultimate_Template.cmd /R:2 /W:5

dir /A:-D /O-D "%WPF_PUBLIC_REPO%"

:EOF
ENDLOCAL
TIMEOUT /T 300
EXIT