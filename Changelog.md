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