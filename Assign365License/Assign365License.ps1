<#
.DESCRIPTION

  Script to assign licenses to users on Microsoft 365. Requires the installation of the Microsoft Graph PowerShell module:

  Install-Module Microsoft.Graph.Intune -Scope CurrentUser

  The script will connect to Microsoft 365 via certificate if a certificate thumbprint is provided, however will fallback 
  to an interactive login if not provided.

.PARAMETERS

  -Group (Required)

  Security group whos members will be assigned the license as specified by the -SKU parameter. Provide the group name, not
  group ID. For example: "MY_GROUP".

  -SKU (Required)

  The SKU of the license to be assigned. To determine the appropiate SKU, browse:

  https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference

  The SKU is the column marked "String ID".

  -Add or -Remove (Required)

  Specify -Add switch to assign a license or -Remove switch to remove a license. Only one switch may be specified.

.NOTES
  Version:        1.0
  Author:         Inundation

  Sources:

  https://learn.microsoft.com/en-us/microsoft-365/enterprise/view-licenses-and-services-with-microsoft-365-powershell?view=o365-worldwide
  https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference
  
.EXAMPLE
  Assigns a Microsoft 365 Audio Conferencing license to members of MY_GROUP.
  .\Assign365License -Group MY_GROUP -SKU MCOMEETADV -Add

  Unassigns a Microsoft 365 Business Premium license to members of MY_GROUP.
  .\Assign365License -Group MY_GROUP -SKU SBP -Remove
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

param (
  [String]$SKU,
  [String]$Group,
  [Switch]$Add,
  [Switch]$Remove
)

#Set Error Action to Silently Continue
$ErrorActionPreference = "Stop"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Verify that a security group and SKU has been provided.

if ($Group -eq "" -or $SKU -eq "") {
  Write-Host "Missing -Group or -SKU parameter. Exiting."
  Exit 1
}

# Verify whether the addition or removal of the license has been properly specified.

if ($Add -and $Remove) {
  Write-Host "Error: Please only specify -Add or -Remove, not both. Exiting."
  Exit 1
} elseif (-not $Add -and -not $Remove) {
  Write-Host "Error: Please specify either -Add or -Remove. Exiting."
  Exit 1
}

# Connect to Microsoft 365.

try {
  Write-Host "Signing into Microsoft Graph."
  Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

} catch {
  Write-Host "Error: Unable to sign into Microsoft 365. Exiting."
  exit 1

}

# Get Group GUID based off of Display Name.

try {
  $GroupObj = Get-MgGroup -Filter "displayName eq '$Group'" | Select-Object -First 1
  Write-Host "Determined Group ID: $($GroupObj.ID)."

} catch {
  Write-Host "Error: Unable to locate group: $Group. Exiting."
  exit 1
}

# Get list of members from Group GUID. Output is an object of the User's ID's.

try {
  $Members = Get-MgGroupMember -GroupId $GroupObj.ID
  Write-Host "Found $(@($Members).Count) member(s) in Group: $Group."

} catch {
  Write-Host "Error: Unable to determine members of the group: $Group. Exiting."
  exit 1
}

# Determine ID from provided SKU.

try {
  $SKUObj = Get-MgSubscribedSku -All | Where SkuPartNumber -eq $SKU
  Write-Host "Resolved $SKU to ID: $($SKUObj.SkuId)."
} catch {
  Write-Host "Error: Unable to determine SKU ID from provided SKU. Exiting."
  Exit 1
}

# For each member of group, assign license.

foreach ($member in $Members) {

  $UserId = $member.Id
  $UserPrincipalName = Get-MgUser -UserId $member.Id

  if ($Add) {

    try {
      Set-MgUserLicense -UserId $UserId -AddLicenses @{SkuId = $SKUObj.SkuId} -RemoveLicenses @() | Out-Null
      Write-Host "Assigned license to: $($UserPrincipalName.DisplayName)."

    } catch {
      Write-Host "Error: Unable to assign license to $($UserPrincipalName.DisplayName)."
    }
  }

  if ($Remove) {

    try {
      Set-MgUserLicense -UserId $UserId -AddLicenses @{} -RemoveLicenses @($SKUObj.SkuId) | Out-Null
      Write-Host "Unassigned license to: $($UserPrincipalName.DisplayName)."

    } catch {
      Write-Host "Error: Unable to unassign license to $($UserPrincipalName.DisplayName)."
    }
  }
}

Write-Host "License changes completed."
