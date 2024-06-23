# DisableInactiveComputers

Disables (never delete) all computer objects which have not been active within the last 90 days (configurable).

WARNING: As this script directly modifies your domain, ensure you test and verify this script prior to running on a production environment.

# Requirements

- The account used to run this script must have access to manipulate Active Directory, specifically to modify computer objects and move computer objects between OUs.
- If run from a remote server, this script must be able to communicate with Active Directory.

# Configuration

Copy this script onto a Domain Controller, or a server which can interact with your Active Directory domain.

## Variables

Configure the following variables for your environment:

| Variable   | Description |
| -------- | ------- |
| $DaysInactive  | Indicates how long a computer object can be inactive before being disabled.    |
| $SearchBase | DN of the OU containing the active computer objects. If you have multiple nested OUs, specify the top-most OU.    |
| $DisabledOU    | DN of the OU inactive computer objects will be moved into.   |

## MSA Account

Prepare a (g)MSA account which the script will run under. For instructions on setting up a MSA account, please see [Creating a MSA Account](https://inundation.ca/walk/active_directory/additional_features/msa_accounts/).

## Scheduled Task

Create a scheduled task which will run this script once a week on Monday at 6am.

```
$Action = New-ScheduledTaskAction -Execute Powershell.exe  -Argument "PowerShell.exe -ExecutionPolicy Bypass -NoProfile -File C:\Scripts\DisableInactiveComputers.ps1"
$Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Monday -At 6am
$Principal = New-ScheduledTaskPrincipal -UserID 'DOMAIN\MSA_USERNAME$ -LogonType Password
Register-ScheduledTask -TaskName TaskName –Action $Action –Trigger $Trigger –Principal $Principal
```

Test and verify thats its function. Enjoy!