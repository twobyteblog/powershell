
# Location of Script to run.
$ScriptPath = "\\ad.twobyte.blog\scripts\myscript.ps1"

# Account to run script under. In this case an MSA account.
$LogonAccount = 'in\host01-msa$'

# When the Scheduled Task should run.
$ScheduledDayofWeek = "Tuesday"
$ScheduledTime = "9am"

$Action = New-ScheduledTaskAction -Execute Powershell.exe  -Argument "PowerShell.exe -ExecutionPolicy Bypass -NoProfile -File $ScriptPath"
$Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek $ScheduledDayofWeek -At $ScheduledTime
$Principal = New-ScheduledTaskPrincipal -UserID $LogonAccount -LogonType Password

Register-ScheduledTask -TaskName DisableInactiveComputerObjects –Action $Action –Trigger $Trigger –Principal $Principal