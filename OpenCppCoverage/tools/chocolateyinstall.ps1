
$ErrorActionPreference = 'Stop';

$url32 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.9.0/OpenCppCoverageSetup-x86-0.9.9.0.exe'
$url64 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.9.0/OpenCppCoverageSetup-x64-0.9.9.0.exe'
$checksum32 = 'EB28D3EF4E9A95C0A27F6348D20F2159DF68C981CC50C866583677C02B25748F3EF2A3D051E3EBD4BFA6C604DF46DA4A8DB2319E86D75D811513FB5ED68360AE'
$checksum64 = 'B06E280A89D89F6901E79C58159348B68165B6101B6C5FA4B6AB4D80668B38F9231A4EE623C1B451C15DD3883E3F4E4FC8FC75DA6993FB11409E8CCEFA3574A6'

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
