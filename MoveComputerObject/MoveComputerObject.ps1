# Grab Computer Name
$Computer = $env:computerName

# Variables
$LaptopNameContains = "INU-S01-LP"
$WorkstationNameContains = "INU-S01-WS"
$DestinationLaptopOU = "OU=Laptops,OU=Devices,OU=Corporate,DC=ad,DC=twobyte,DC=blog"
$DetinationWorkstationOU = "OU=Workstations,OU=Devices,OU=Corporate,DC=ad,DC=twobyte,DC=blog"
$DomainController = "INU-S01-DC01.ad.twobyte.blog"

if ($Computer.contains($LaptopNameContains)) {
    $path = $DestinationLaptopOU
} elseif ($Computer.contains($WorkstationNameContains)) {
    $path = $DetinationWorkstationOU
} else {
    exit
}

# Run PS Remote Session on DC
$Session = New-PSSession -ComputerName $DomainController

Invoke-Command { Import-Module ActiveDirectory } -Session $Session
Invoke-Command { Get-ADComputer $Using:Computer | Move-ADObject -TargetPath $Using:path } -session $Session