<#
.SYNOPSIS
  Searches and locates any computer object which has been inactive for a set period of time, disabling the account.
.DESCRIPTION
  This script searches Active Directory for any computer objects which have been inactive for a set period of time.
  If an computer object meets these requirements, the object is disabled and moved into the Disabled OU.
.PARAMETER
    None
.INPUTS
    None
.OUTPUTS
    None
.NOTES
  Version:        1.0
  Author:         inundation.ca
  Creation Date:  September 01, 2023
  
.EXAMPLE
  .\DisableInActiveComputers.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Stop
$ErrorActionPreference = "Stop"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

# Base OU which will be searched for inactive computer objects.
$SearchBase = "OU=Devices,OU=Corporate,DC=ad,DC=inundation,DC=ca"

# OU which inactive computer objects will be moved into.
$DisabledOU = "OU=Disabled,OU=Devices,OU=Corporate,DC=ad,DC=inundation,DC=ca"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Find all computer objects which have not been logged into within $DaysInactive or have never been logged into.
$ComputerObjects = Search-ADAccount -AccountInactive -DateTime $InactiveDate -ComputersOnly -SearchBase $SearchBase | Select-Object Name, LastLogonDate, Enabled, DistinguishedName

# Rebuild the array, selecting only the computer objects which are not disabled. 
# This step is required as Search-ADAccount has no method to filter on enabled accounts.
$ComputerObjects = $ComputerObjects | Where-Object { $_.Enabled -eq "True" }

# Disable found computer objects and move them into the Disabled OU.
ForEach ($Item in $ComputerObjects){
  $DistName = $Item.DistinguishedName
  Set-ADComputer -Identity $DistName -Enabled $false
  Move-ADObject -Identity $DistName -TargetPath $DisabledOU
}