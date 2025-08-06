# Windows Post Flight ToDo 

## Add

	

## Change
- All variables start with "$"
- Dump all the process complete logs into a report instead of the COMPLETED_log


## Fix
- Check for INCOMPLETE file and write to log

- With Windows 11 24H2, RSAT install seems to require reboot before working.
- Wireless [wi-fi] doesn't parse IPv4 correctly since using netsh
	netsh interface ipv4 show addresses wi-fi
	need to find the "connected" interface
	netsh interface show interface
		"connected"

## Odd Issues

- RSAT via DISM prompting for reboot ?

- Maual initiation of post-flight only runs up to domain join.
- Windows 11 laptop ran through complete WPF. didn't reboot after completion --was logged in.

- After reboot, did not kick off WPF from scheduled task, despite being there.
- [INFO]	OS Name: Microsoft Windows 11 Pro 
- [INFO]	Windows 10 version: 2009 #not to hard code, take from OS Name
- [INFO]	Working on Chocolatey package management... #what choco list is being used?


-------------------------------------------------------------------------------


## DONE

#### 2025-07
- Config file parameter to remove domain admins from domain computer

#### 2025-07-15
- COMPLETED_log should just have a timestamp

#### 2025-07
- @powershell Rename-Computer -NewName "NewHostname" -Restart
- @powershell Add-Computer -DomainName "YourDomainName" -Restart
- Windows Ultimate Playbook should be last to run.




#### 2024-10-17
- Product Key
- Don't abort if NETDOM fails to install
- include in Running_Chocolatey.txt file what choco list is being used?

#### 2022-01-13

- File DiskPart_Commands should be in cache
- File DiskPart_Volume_LIST should be in cache
- Don't install MS SilverLight KB4481252
- wmic cpu get name,caption /value

#### 2021-12-23

- Rename VAR to Cache

- Pull the "Code Name" from the registry:

REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "DisplayVersion"

- main log folder too busy
	System folder?
	
	
#### 2021-12-22
- Get PID for program

#### 2020-08-11
- Get computer make
- Get computer model
- Get computer BIOS
- Get Dell Service Tag