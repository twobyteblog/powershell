
<#
.SYNOPSIS

  Script that installs or uninstalls a printer onto a device.

.DESCRIPTION

  Script that either installs or uninstalls a TCP/IP printer onto a device. The script will check and either add/remove the printer object, 
  printer port and required driver. This script does not work with shared printers as it installs the printers onto the device and not onto 
  a user profile.


.PARAMETER <Parameter_Name>

    -Install     - Add Printer.
    -Uninstall   - Remove Printer.

.INPUTS

  None

.OUTPUTS

  Log file stored in C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\[PRINTER NAME]-[DATE].log

.NOTES

  Version:        1.0
  Author:         twobyte.blog
  
.EXAMPLE

  # Add Printer.
  %SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -File .\main.ps1 -Install

  # Remove Printer.
  %SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoLogo -File .\main.ps1 -Uninstall

#>

#---------------------------------------------------------[Initializations]--------------------------------------------------------

Param (
    [parameter(Mandatory=$true, ParameterSetName="WithA")]
    [switch] $Install,

    [parameter(Mandatory=$true, ParameterSetName="WithB")]
    [switch] $Uninstall
)

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Import printer settings from configuration.
$ConfigFilePath = "$PSScriptRoot\printer.json"
$Printer = Get-Content -Raw $ConfigFilePath | ConvertFrom-Json

$PrtVersion = $Printer.Version
$PrtVersionSave = $Printer.VersionSave

$PrtName = $Printer.Name
$PrtPortName = $Printer.PortName
$PrtAddress = $Printer.PortAddress
$PrtDriverName = $Printer.DriverName
$PrtDriverFile = $Printer.DriverFile
$PrtColor = $Printer.Color
$PrtDuplexMode = $Printer.DuplexMode

# Logging Configuration
$sLogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$sLogName = "$PrtName Install $(get-date -f yyyy-MM-dd).log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#------------------------------------------------------------[Function]------------------------------------------------------------

function Write-Log {
  param (
    [string]$message
  )

  Write-Host "$PrtName : $message"

}

function Set-RegistryKey {
  param(
      [string]$Path,
      [string]$Name,
      [string]$Value,
      [string]$Type
  )

  try {
      if (-not (Test-Path $Path)) {
          New-Item -Path $Path -Force | Out-Null
          New-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
      } else {
          Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
      }
  } catch {
      Write-Log "Unable to successfully set $Path\$Name with value $Value of type $Type."
      Exit 1
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Transcript -Path $sLogFile -Append

If ($Install) {

  if (Get-PrinterDriver -Name $PrtDriverName -ErrorAction SilentlyContinue) {
    Write-Log "Driver already installed in the Microsoft Driver Repository. Reinstalling driver to ensure its up-to-date."

    Write-Host "======================"
    Pnputil /add-driver "$PSScriptRoot\Driver\$PrtDriverFile"
    Write-Host "======================"

  } else {

    Write-Log "No existing driver found. Adding driver to the Microsoft Driver Repository."

    Write-Host "======================"
    Pnputil /add-driver "$PSScriptRoot\Driver\$PrtDriverFile"
    Write-Host "======================"

    Write-Log "Adding driver: `"$PrtDriverName`" to the Print subsystem."
    Add-PrinterDriver -Name $PrtDriverName

  }

  if (Get-Printer -Name $PrtName -ErrorAction SilentlyContinue) {
    Write-Log "Existing printer object: `"$PrtName`" found. Removing."
    Remove-Printer -Name $PrtName
  } else {
    Write-Log "No existing printer object found."
  }

  if (Get-PrinterPort -Name $PrtPortName -ErrorAction SilentlyContinue) {
    Write-Log "Existing Printer Port named `"$PrtPortName`" found. Removing."

    try {
      Remove-PrinterPort -Name $PrtPortName
    } catch{
      Write-Log "Unable to remove printer port. Conflict found with another printer. Exiting..."
      Exit 1
    }
    } else {
      Write-Log "No existing printer port found."
    }

  Write-Log "Adding required printer port: `"$PrtPortName`" with address of `"$PrtAddress`"."
  Add-PrinterPort -Name $PrtPortName -PrinterHostAddress $PrtAddress

  Write-Log "Creating printer object."
  Add-Printer -Name $PrtName -PortName $PrtPortName -DriverName $PrtDriverName

  if ($PrtColor -eq "False") {
    Set-PrintConfiguration -PrinterName $PrtName -DuplexingMode $PrtDuplexMode -Color $false
    Write-Log "Set color default to false."
  } else {
    Set-PrintConfiguration -PrinterName $PrtName -DuplexingMode $PrtDuplexMode -Color $true
    Write-Log "Set color default to true."
  }

  Write-Log "Restarting Print Spooler service."
  Restart-Service -Name Spooler

  # Set versioning information on device.
  Write-Log "Setting version information in registry."
  Write-Host $PrtVersionSave
  Set-RegistryKey -Path $PrtVersionSave -Name "Version" -Value $PrtVersion -Type "String"

  Write-Log "Printer successfully installed."
  Write-Log "Exit Code: $lastexitcode"

}

if ($Uninstall) {

  if (Get-Printer -Name $PrtName -ErrorAction SilentlyContinue) {
    Write-Log "Printer found. Removing."
    Remove-Printer -Name $PrtName -Confirm:$false -ErrorAction SilentlyContinue

  } else {
    Write-Log "Printer not found. Continuing."
  }

  if (Get-Printerport | Where-Object  { $_.Name -eq $PrtPortName }) {
    Write-Log "Printer Port `"$PrtPortName`" found. Removing."

    try {
      Remove-PrinterPort -Name $PrtPortName
    } catch{
      Write-Log "Unable to remove printer port. Conflict found with another printer. Exiting..."
      Exit 1
    }

  } else {
    Write-Log "Printer Port `"$PrtPortName`" not found. Continuing."
  }

  Write-Log "Restarting Print Spooler service."
  Restart-Service -Name Spooler

  # Remove versioning information.
  Write-Log "Cleanup registry."
  Remove-Item -Path $PrtVersionSave -Force | Out-Null

  Write-Log "Printer successfully uninstalled."
  Write-Log "Exit Code: $lastexitcode"

}

Stop-Transcript