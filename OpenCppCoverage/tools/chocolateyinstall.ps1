
$ErrorActionPreference = 'Stop';

$url32 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.8.0/OpenCppCoverageSetup-x86-0.9.8.0.exe'
$url64 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.8.0/OpenCppCoverageSetup-x64-0.9.8.0.exe'
$checksum32 = '9D223CF58E9A0840F1B2C8504BEA9A8FA111E8801175132E0A1FA51108431B7F09699381A4028D369246C30B42597391F206A623AA4F8D62F287CE6A86D7F32F'
$checksum64 = '380ECA32A7CFC88C464177B8B10DD7498045543CE2990C78BAA32548B11DC01AC54AE7D15F65E748CAC57C5B9D36179C2ABB44D5FF42FEF1046FF1CF826A9E02'

$packageArgs = @{
  packageName   = 'OpenCppCoverage'
  unzipLocation = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  fileType      = 'EXE'
  url           = $url32
  url64bit      = $url64
  softwareName  = 'OpenCppCoverage*'

  checksum      = $checksum32
  checksumType  = 'sha512'
  checksum64    = $checksum64
  checksumType64= 'sha512'

  silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs
