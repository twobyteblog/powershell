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