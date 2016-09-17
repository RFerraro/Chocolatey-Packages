$ErrorActionPreference = 'Stop'; # stop on all errors

$uninstalled = $false

$uninstallKey = "{74933D3C-7641-4FA4-840E-313A4D076D87}_is1"

$uninstall64Root = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$uninstall32Root = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

$uninstall64Path = Join-Path $uninstall64Root $uninstallKey
$uninstall32Path = Join-Path $uninstall32Root $uninstallKey

if(Test-Path $uninstall64Path)
{
	$uninstallPath = $uninstall64Path
}
elseif(Test-Path $uninstall32Path)
{
	$uninstallPath = $uninstall32Path
}
else
{
	Write-Warning "$packageName has already been uninstalled by other means."
	return 0
}

$packageArgs = @{
  packageName    = 'OpenCppCoverage'
  fileType       = 'EXE'
  silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes = @(0)
  file           = $((Get-ItemProperty $uninstallPath).UninstallString.Trim('"'))
}

Uninstall-ChocolateyPackage @packageArgs
