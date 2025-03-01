<# 

Microsoft Deployment Toolkit (MDT) script to install a printer driver onto the PC.

1. Copy this script into %SCRIPTROOT% directory wtihin MDT.
2. Copy the drivers into a subfolder the %SCRIPTROOT% directory wtihin MDT.
3. Open the printer drivers .inf file to determine the drivers name.
4. Update the DriverName and DriverPath variables within the script.
5. Add a "Run Command Line" step under the Custom Tasks section of your task sequence with the following command: 

Powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\PrinterDriver.ps1"

#>

#---------------------------------------------------------[Initializations]--------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# WScript Version
$sScriptVersion = "1.0"

#Log File Configuration
$TSENV = New-Object -COMObject Microsoft.SMS.TSEnvironment
$logPath = $TSENV.Value("LogPath")
$logFile = "$logPath$($myInvocation.MyCommand).log"

#Variables

$DriverName = "Printer Name"
$DriverPath = ".\driver\printer.inf"

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Start-Transcript -Path $LogFile -Append

if (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue) {
    Write-Host "Driver already installed. Updating."

    Pnputil /add-driver $DriverPath

} else {

    Write-Host "No existing driver found. Adding driver to driver store."
    Pnputil /add-driver $DriverPath

    Write-Host "Installing driver."
    Add-PrinterDriver -Name $DriverName

}

Stop-Transcript