# Changelog project: Windows Post Flight
***The Anti-SCCM (System Center Configuration Manager), the Windows Autopilot Doppelganger.***

---

## Features Heading
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Fixed` for any bug fixes.
- `Removed` for now removed features.
- `Security` in case of vulnerabilities.
- `Deprecated` for soon-to-be removed features.

[//]: # (Copy paste pallette)
[//]: # (#### Added)
[//]: # (#### Changed)
[//]: # (#### Fixed)
[//]: # (#### Removed)
[//]: # (#### Security)
[//]: # (#### Deprecated)


---

## Version 4.20.0 (2025-07-18)
#### Added
- Domain Admin check to remove

#### Changed
- (USB) Seed updater tool 
 
---


## Version 4.19.0 (2025-07-15)
#### Fixed
- WPF total time

#### Changed
- name of playbook
- WPF total time handling
- Process 6 --> 7
- Process 7 --> 6

## Version 4.18.1 (2025-06-30)
#### Fixed
- logging for hostname rename
- 

## Version 4.18.0 (2025-03-21)
#### Added
- some REM
  
#### Changed
- Handling of RSAT install
- Order of process, Windows Playbook Ultimate to last
- Step4 trap numbering

#### Removed
- Numbering from dependencies
  
## Version 4.17.0 (2025-01-28)
#### Added
- reboot flag
- Windows product key
- RSAT install error catch
- choco package detail logging
- domain join logging
- reboot check

#### Changed
- var_ver to $var_ver
- NETDOM to DISM_RSAT variable
- sch task suppress error
- netdom to powershell for hostname change


## Version 4.16.0 (2024-10-15)
#### Added
- Configurations folder
- Trap for Domain join password; now required unless * specified

#### Changed
- location of diskpart now in Configurations\Diskpart
- WMIC calls to powershell calls
- 64-bit to x64 for architecture
- folder structure
- WPF_Production_Post

#### Deprecated
- WMIC depracated as of Windows 11 24H2

#### Removed
- Difference with Public repo
- Archive folder

## Version 4.15.0 (2024-01-22)
#### Changed
- robocopy parameters for xd xf on seed drive
- reset attributes for post-fligh directory after seeding 

#### Fixed
- choco first time run

## Version 4.14.0 (2023-07-27)
#### Added
- more choco debug

#### Changed
- config schema
- names of choco variables
- how to check choco just using --version


#### Fixed
- Process numbering comment
- reading choco variables from config
- incomplete choco logging
- choco list


## Version 4.13.2 (2022-10-21)
#### Added
- check to make sure Ultimate script ran
- exclude SysVol info for seed


## Version 4.13.0 (2022-07-08)
#### Added
- better logging
 
### Changed
- Default HOST_FILE_DATABASE=Computing_Inventory.txt
- Chocolatey directory structure has it's own directory

### Fixed
- RSAT install is now /Quiet


## Version 4.12.0 (2022-04-28)
### Changed
- Using cache for process files

### Fixed
- formating


## Version 4.11.0 (2022-01-13)
### Added
- KB_BL KB Black List for Windows updates

### Changed
- location of SystemInfo to cache
- location of ComputerInfo to cache
- location of Diskpart commands to cache
- location of Diskpart Volume list to cache
- Minimum Config Schema 3.8.0


## Version 4.10.0 (2021-12-23)
### Added
- Windows display version 
- additional TRACE
- VARIABLE DEBUG list
- CPU Spec's

### Changed
- var folder name to cache
- min schema to 3.7.0
- Order of OS info
- Order of networking info
- variable var_WINDOWS_VERSION to $OS_BUILD
- language aborting to exiting if EVERYTHING IS ALREADY DONE
- location of SEED log to cache
- location of DISM log to cache
- location of Task Scheduler log to cache


### Fixed
- run id not generating under certain conditions


## Version 4.9.0 (2021-12-22)
### Added
- PID

### Changed
- moved WPF_Start_Time.txt into var folder 

### Removed
- WPF_Start_Time.txt deletion if delete var selected since already in var folder.


## Version 4.8.0 (2021-07-27)
### Added
- Powershell Get-ComputerInfo to file

### Changed
- If not running with administrative privelege, will immediately go to error.
- Timezone check, more efficient

## Version 4.7.1 (2020-09-25)
### Added
- WindowsUpdate powershell check to speed up process


## Version 4.7.0 (2020-08-12)
### Added
- Get computer make
- Get computer model
- Get computer BIOS
- Get Dell Service Tag
- WPF Runout check

### Changed
- NETSH Network info IPv4 & IPv6
- variable names with $
- Skip WPF Total Lapse time with runout

### Fixed
- Blank out SHA256 check file
- Debug dump for IPv4 IPv6
- Debug dump RSAT status
- clean rsat


---

## Version 4.6.0 (2020-07-30)
### Added
- info CloneZilla image file name
- unattend.xml for pre-seeding
- unattend.xml removal when pre-seeded

### Changed
- Seed drive logging
- relocated FOUND_SEED_DRIVE into var folder

### Fixed
- variable {} encapsulation consistency

---


## Version 4.5.1 (2020-07-22)
### Changed
- Log verbage
- Log info order
- INFO items to DEBUG items

---

## Version 4.5.0 (2020-03-03)
#### Added
- Computer UUID (Universally unique identifier)

#### Changed
- console lines 45

#### Fixed
- log output for start of debug

---

## Version 4.4.0 (2020-01-27)
#### Fixed
- If hostname is default, don't join domain

#### Changed
- log formatting for paths's: []

---

## Version 4.3.0 (2019-12-02)
#### Added
- RSAT Cleanup

#### Changed
- Config file schema

---

## Version 4.2.6 (2019-12-02)
#### Fixed
- Last time lapse 

#### Changed
- Casing for WFP_start_Time file

---

## Version 4.2.5 (2019-11-22)
#### Fixed
- PS Check Major typo
- Powershell handle for total lapse time
- post var file cleanup

---

## Version 4.2.4 (2019-11-18)
#### Added
- Script start file

#### Changed
- Total lapse time now handled by powershell

#### Fixed
- Powershell check

#### Removed
- Extra "Start" in the log file

---

## Version 4.2.3 (2019-10-28)
#### Added
- NuGet logs to Windows_Update_Powershell.log
- Chocolatey Internet connectivity check

#### Fixed
- Bug in Windows update if no reboot required

---

## Version 4.2.2 (2019-10-25)
#### Added
- GITHUB_WPF_CMD_URI for future use in Config file

#### Changed
- TEMP to PUBLIC for alternate log location

#### Fixed
- typos
- Error handling for no entry in host database
- Error handling for Choco path not set on first run
- Root script folder has attribute of system folder and is thus hidden


## Version 4.2.1 (2019-10-23)
#### Added
- Local log shipping status log
- Additional TRACE for step 7
- Internet check for Microsoft Windows updates

#### Changed
- OS architecture handled by wmic
- Process file names are prepented with <#>_

#### Fixed
- Chocolatey err80 now goes GoTo correct location
- Line 2164 caused script to crash. Removed line.

---

## Version 4.1.0 (2019-10-11)
#### Added
- IPv6 Address
- Network check in order to run Chocolatey
- Number of total reboots

#### Changed
- Some debug wording

#### Fixed
- Chocolatey var file, removed script version
- Debug output "SCRIPT_VERSION"
- Running file not deleting

---

## Version 4.0.3 (2019-10-01)
#### Fixed
- RUNNING_ log file not getting deleted when done.
- improved logging output

---

## Version 4.0.2 (2019-09-25)
#### Added
- Windows updates via Powershell 
#### Changed
- Time lapse now processed by PowerShell
- Name change to Windows-Post-Flight, keep separator consistent
- Process files prepended with "Process_"
#### Fixed
- logging wording
- shipping log file even if incomplete
- WPF Total lapse time

---

## Version 3.6.1 (2019-09-19)
#### Changed
- Some logging output to be more consistent
#### Fixed
- WPF total lapse time
#### Changed
- Process files default names

---

## Version 3.6.0 (2019-09-18)
#### Added
- WPF Run ID
- Calculated total lapse time.
#### Changed
- Ultimate file to Windows Ultimate as default
- DISM RSAT log no longer in var folder, but in main log.
- DISM RSAT log goes in completed log.

---

## Version 3.5.3 (2019-08-29)
#### Changed
- minor formatting

#### Fixed
- WPF running file not deleted when run ends

---

## Version 3.5.2 2019-08-28
#### Added
- Chocolatey Running file
- Chocolatey Running file now contains package list

#### Changed
- Running WPF log name
- RAN --> RAN

#### Fixed
- when scheduled task first created with domain user, reported error.
- First time run or follow up run.

---

## Version 3.5.1 2019-08-19
#### Fixed
- RUNNING_WPF file
- Log shipping

---

## Version 3.5.0 2019-08-15
#### Added
- DISM RSAT output into var file
- RSAT check goes to nul

#### Fixed
- Chocolatey variable log output

---

## Version 3.4.1 2019-08-06
#### Changed
- RSAT attempts to 3

#### Fixed
- RSAT Tools error handling for no msu on W10 1803 and older
- RSAT logging
- RSAT console output formatting

---

## Version 3.4.0 2019-05-30
#### Added
- Variable debug separator in log file
- PW files deletion controlled by DEBUG_MODE

#### Changed
- Wording for dependency checks in log file

#### Fixed
- Log output for PROCESS_3_FILE_NAME

---

## Version 3.3.0 2019-05-02
#### Added
- Add computer to specified OU in AD
- AD OU in Config

#### Changed
- Log shipping now appends
- Config Schema version 3.3.0
- Debugger improved
- MAC files now go to var

#### Fixed
- Process Complete 3 log file
- Trace on Debugger

#### Removed
- Deleting the MAC files as individual files

---

## Version 3.2.0 2019-05-01
#### Added
- Get IP
- Script is running file
- Script Build for dev (avoid collision)

#### Changed
- Order of collected general information in log
- Order for domain user check

#### Fixed
- If debugger is set, not to delete seed location.
- Typos for lapse time

#### Removed
- mode line numbers

#### Security
- SHA256 check for all lower case

---

## Version 3.1.0 2019-04-26
#### Fixed
- syntax error
- logging for debugger

---

## Version 3.1.0 2019-04-26
#### Added
- console output
- powershell ISO date
- RSAT/NETDOM installation via DISM
- VAR_CLEANUP variable. Auto set to 0 {off} with debugger

#### Changed
- Config file schema 3.1.0

#### Fixed
- error output to the console
- Timezone output

#### Removed
- script version from logfile name