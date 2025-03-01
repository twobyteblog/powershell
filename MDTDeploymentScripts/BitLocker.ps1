<#

Microsoft Deployment Toolkit (MDT) script to enable BitLocker on a PC. Note, this only enables BitLocker. Ensure a GPO is applied against the PC with the required BitLocker settings.


1. Copy this script into %SCRIPTROOT% directory wtihin MDT.
2. Add a "Run Command Line" step under the Custom Tasks section of your task sequence with the following command: 

Powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\BitLocker.ps1"

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Check if a TPM is present, exit if the system does not have a TPM.
$TPMStatus = Get-TPM

if ($TPMStatus.TPMPresent -eq $False) {
    Exit 1
}

# Check if BitLocker is installed; install if not available.
$BitLockerStatus = Get-WindowsOptionalFeature -Online -FeatureName BitLocker

if ($BitLockerStatus.State -eq "Disabled") {
    Install-WindowsFeature BitLocker -IncludeAllSubFeature -IncludeManagementTools
}

# Check if C:\ is already encrypted. If not, initiate BitLocker encryption on the drive.
$CDriveStatus = Get-BitLockerVolume -MountPoint 'c:'

if ($CDriveStatus.volumeStatus -eq 'FullyDecrypted') {
    C:\Windows\System32\manage-bde.exe -on c: -recoverypassword -skiphardwaretest
}