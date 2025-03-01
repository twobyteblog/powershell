<# 

Microsoft Deployment Toolkit (MDT) script to call and run a predefined PDQ Deploy task.

1. Copy this script into %SCRIPTROOT% directory wtihin MDT.
2. Add a "Run Command Line" step under the Custom Tasks section of your task sequence with the following command: 

Powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPTROOT%\PDQDeployment.ps1"

#>


#-----------------------------------------------------------[Execution]------------------------------------------------------------

netsh advfirewall set allprofiles state off
ipconfig /registerdns

# Wait a few seconds to allow the DNS record to update.
Start-Sleep 15

Invoke-Command -ComputerName INU-S00-MDT01.ad.inundation.ca -ScriptBlock { ipconfig /flushdns; pdqdeploy.exe Deploy -Package "Deployment Package" -Targets $args[0] } -ArgumentList "$env:COMPUTERNAME"

# Give PDQ Deploy a chance to start deploying to the device.
Start-Sleep 30

# Continually check if PDQ Deploy is running on the device. Loop until process is completed.
while(test-path "C:\Windows\AdminArsenal\PDQDeployRunner\service-1.lock") {
Start-Sleep 30
}