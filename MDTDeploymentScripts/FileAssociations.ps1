# Microsoft Deployment Toolkit (MDT) script to import and configure file associations on a PC.

# Add a PowerShell step under the Custom Tasks section of your task sequence with the following command:
# Powershell.exe -ExcutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\FileAssociations.ps1"

# Ensure your DefaultFileAssociations.xml file is located within your %SCRIPTROOT% directory.

# Load Microsoft.SMS.TSEnvironment COM object

try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object" ; exit 1
}
try {
    Write-Host -Value "Getting OS Disk Location."
    $OSDisk = $TSEnvironment.Value("OSDISK")

    Write-Host -Value "OS Disk Location. $($OSDisk)"
    Write-Host -Value "Importing Custom File Associations."
    Dism /online /import-defaultappassociations:$($PSScriptRoot)\DefaultFileAssociation.xml
    Write-Host "Successfully Imported Custom File Associations..."
}
catch [System.Exception] {
    Write-Host "FAILED Applying - Importing Custom File Associations. Error message: $($_.Exception.Message)"
}