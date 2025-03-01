<#

Microsoft Deployment Toolkit (MDT) script to activate Windows using the burned in Activation Key stored in the BIOS.


1. Copy this script into %SCRIPTROOT% directory wtihin MDT.
2. Add a "Run Command Line" step under the Custom Tasks section of your task sequence with the following command: 

Powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\OEMLicenseActiviation.ps1"

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$OEMKey = ((Get-WmiObject -Query ‘Select * from SoftwareLicensingService’).OA3xOriginalProductKey).ToString()

slmgr /ipk $OEMKey
slmgr /ato