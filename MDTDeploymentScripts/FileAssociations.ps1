<#

Microsoft Deployment Toolkit (MDT) script to import and configure default file associations on a PC.

1. On a PC, configure the default file associations that best for your organization.
2. Open PowerShell and run "Dism /Online /Export-DefaultAppAssociations:"C:\FileAssociations.xml""
3. Copy this script and the FileAssociations.xml file into the %SCRIPTROOT% directory on MDT.
4. Within your Task Sequence, add a "Run Command Line" step under Custom Tasks with the following settings:

Powershell.exe -ExcutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\FileAssociations.ps1"

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

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