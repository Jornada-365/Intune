<#
  .NOTES
  ===========================================================================
   Created on:    19.07.2025
   Created by:    Júlio César Vasconcelos    
   Filename:      EnableMicrosoftSensitivityLabelsinAdobeAcrobat.ps1
   Info:          https://github.com/Jornada-365
  ===========================================================================
  
  .DESCRIPTION
    This script sets registry information in Windows 10 and Windows 11
    to enable Adobe Acrobat and Adobe Reader to work with Microsoft Sensitivity labels.
            
  .EXAMPLE
    EnableMicrosoftSensitivityLabelsinAdobeAcrobat.ps1
#>

# Set the execution policy to bypass for the device to avoid script blocking
# Requires administrative privileges

Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass -Force

# Get information of current user
$currentUser = (Get-Process -IncludeUserName -Name explorer | Select-Object -First 1 | Select-Object -ExpandProperty UserName).Split("\")[1] 

$Data = $currentUser
$Keys = GCI "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\" -Recurse
Foreach ($Key in $Keys) {
  IF (($key.GetValueNames() | % { $key.GetValue($_) }) -match "\b$CurrentUser\b" ) { $sid = $key }
}

# Add SID of current user to a variable
$sid = $sid.pschildname

New-PSDrive HKU Registry HKEY_USERS | out-null
#endregion

#region Variables for sensitivity labels in Adobe Acrobat and Reader

# Registry paths for Acrobat and Reader
$RegKeyPathAcrobat = "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"
$RegKeyPathReader = "HKLM:\SOFTWARE\Policies\Adobe\Adobe Reader\DC\FeatureLockDown"
$RegKeyPathUser = "HKU:\$sid\SOFTWARE\Adobe\Adobe Acrobat\DC\MicrosoftAIP"

# Variables for Browser Authentication
$bMIPExternalAuthAdmin = "bMIPExternalAuthAdmin"
$bMIPExternalAuthAdminValue = 1

# Variables for Double Key Encryption (DKE)
$bEnableDKEAdmin = "bEnableDKEAdmin"
$bEnableDKEAdminValue = 1

# Variables for consistent viewing of protected PDFs
$bShowDMB = "bShowDMB"
$bShowDMBValue = 1

# Original variables for sensitivity labels
$bMIPCheckPolicyOnDocSave = "bMIPCheckPolicyOnDocSave"
$bMIPCheckPolicyOnDocSaveValue = 1
$bMIPLabelling = "bMIPLabelling"
$bMIPLabellingValue = 1
#endregion

#region Implementation of registry settings
# Create registry paths if they don't exist
IF (!(Test-Path $RegKeyPathAcrobat)) {
  New-Item -Path $RegKeyPathAcrobat -Force | Out-Null
}

IF (!(Test-Path $RegKeyPathReader)) {
  New-Item -Path $RegKeyPathReader -Force | Out-Null
}

IF (!(Test-Path $RegKeyPathUser)) {
  New-Item -Path $RegKeyPathUser -Force | Out-Null
}

# Set registry entries for Acrobat
New-ItemProperty -Path $RegKeyPathAcrobat -Name $bMIPCheckPolicyOnDocSave -Value $bMIPCheckPolicyOnDocSaveValue -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $RegKeyPathAcrobat -Name $bMIPLabelling -Value $bMIPLabellingValue -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $RegKeyPathAcrobat -Name $bMIPExternalAuthAdmin -Value $bMIPExternalAuthAdminValue -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $RegKeyPathAcrobat -Name $bEnableDKEAdmin -Value $bEnableDKEAdminValue -PropertyType DWord -Force | Out-Null

# Set registry entries for Reader
New-ItemProperty -Path $RegKeyPathReader -Name $bMIPExternalAuthAdmin -Value $bMIPExternalAuthAdminValue -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $RegKeyPathReader -Name $bEnableDKEAdmin -Value $bEnableDKEAdminValue -PropertyType DWord -Force | Out-Null

# Set registry entry for consistent viewing
New-ItemProperty -Path $RegKeyPathUser -Name $bShowDMB -Value $bShowDMBValue -PropertyType DWord -Force | Out-Null

# Clears the error log from PowerShell before exiting
$error.clear()
#endregion
