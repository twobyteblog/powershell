<#

Microsoft Deployment Toolkit (MDT) script to import and configure a default start menu on a PC.

1. On a PC, create a start menu that works best for your organization.
2. Open PowerShell and run "Export-StartLayout -Path "C:\StartMenu.xml""
3. Copy this script and the StartMenu.xml file into the %SCRIPTROOT% directory on MDT.
4. Within your Task Sequence, add a "Run Command Line" step under Custom Tasks with the following settings:

Powershell.exe -ExcutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\StartMenu.ps1"

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
    Write-Host -Value "Importing Default Start Layout."
    Copy-Item "$($PSScriptRoot)\DefaultStart.xml" -Destination "$OSDisk\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -ErrorAction SilentlyContinue -Force
    Write-Host "Successfully Imported Default Start Layout..."

    Write-Host "Removing Cached Default Start Layout..."
    Remove-Item -Path "$OSDisk\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml" -Force
    Write-Host "Successfully removed Cached Default Start Layout..."
}
catch [System.Exception] {
    Write-Host "FAILED Applying - Importing Default start Layout. Error message: $($_.Exception.Message)"
}