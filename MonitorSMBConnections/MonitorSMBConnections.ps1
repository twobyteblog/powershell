
$Script = 'C:\Scripts\MonitorSMBConnections.ps1'
$TaskName = 'Gather Incoming SMB Sessions'
$Description = 'This task gathers incoming SMB connections'
$User = "NT AUTHORITY\SYSTEM"
$Executable = "PowerShell.exe"

$Action = New-ScheduledTaskAction -execute $Executable -Argument "-file $Script"

$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 5)

$Settings = New-ScheduledTaskSettingsSet –StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Setting $Settings -description $Description -User $User -RunLevel Highest

[array]$ResultArray = Import-Csv C:\Scripts\MonitorSMBConnections\Connections.csv

$ServerConnections = Get-SmbSession
foreach ($Connection in $ServerConnections) {
$Date = Get-Date -Format 'yyyy-MM-dd'
$ServerObject = [PSCustomObject]@{
  ClientComputerName = $Connection.ClientComputerName
  ClientUserName     = $Connection.ClientUserName
  Dialect            = $Connection.Dialect
  Date               = $Date
  Occurence          = 1
  }
  $ResultArray += $ServerObject
}

$Groups = $ResultArray | Group-Object ClientComputerName,ClientUserName,Dialect | where { $_.count -gt 1 }

foreach ($Group in $Groups) {
  for ($i = 0; $i -lt $Group.Count; $i++) {
   $Object = $ResultArray | where { $_ -eq $Group.Group[$i] }
   $object.Occurence = $Group.Count
  }
}

$ResultArray | Export-Csv C:\Scripts\MonitorSMBConnectionsConnections.csv