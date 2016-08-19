$ErrorActionPreference = 'Stop'; # stop on all errors

$uninstalled = $false

#only verified on a 64bit install on a 64bit os
$uninstallKey = "{74933D3C-7641-4FA4-840E-313A4D076D87}_is1"
$systemUninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$uninstallPath = Join-Path $systemUninstallPath $uninstallKey

if(Test-Path $uninstallPath)
{
    $packageArgs = @{
      packageName    = 'OpenCppCoverage'
      fileType       = 'EXE'
      silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
      validExitCodes = @(0)
      file           = "$((Get-ItemProperty $uninstallPath).UninstallString)"
    }

    Uninstall-ChocolateyPackage @packageArgs
}
else
{
    Write-Warning "$packageName has already been uninstalled by other means."
}
