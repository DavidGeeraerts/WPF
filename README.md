# Windows Post-Flight Commander


(the anti-Windows Deployment Services | Doppelganer to Windows Autopilot)




***No [Full] Documentation yet! Some Documentation in the config file.***


# Major Features
1.	Configures local administrator account
2.	Configures local hard drives on the computer
3.	Renames the computer
4.	Joins a domain (or not)
5.	Runs customized Chocolatey package list based on hostname
6.	Runs Windows Ultimate commandlet (like Ansible Playbooks)
7.	Microsoft Windows updates via PowerShell

## Minor Features
- Create computer object in AD in specified OU
- Configuration file
- Log level control
- Extensive logging
- Log shipping to network/remote server
- SHA256 checking
- Auto-config PC Debugger
- Script lapse time
- Auto install RSAT (Remote Server Administrator Tools)
- Disk check & repair
- Host mac database lookup



### WINDOWS ULTIMATE COMMANDLET
(A playbook for Windows)

The commandlet should be thoroughly tested to ensure it doesn't break the main Windows Post Flight Commandlet.

As a suggestion for authoring a Ultimate commandlet, make 3 sections:
(most activities will fall into one of these sections)

1.	INSTALLATIONS
2.	CONFIGURATIONS
3.	CLEANUP

There's a template available.