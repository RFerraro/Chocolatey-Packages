
$ErrorActionPreference = 'Stop';

$url32 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.6/OpenCppCoverageSetup-x86-0.9.6.exe'
$url64 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.6/OpenCppCoverageSetup-x64-0.9.6.exe'
$checksum32 = '685A82178C544C51BF2180E5356C91FB5B8E73F706715C9F62E26B458932EA653A272B82AF0BCB83943243CF860F9EBB50D4CD98F370F9FBF0B373946B8257F3'
$checksum64 = 'E479B1FC0855C13310B80A93F2D7CCEE91936DEADC1ECE24A5CBA2E679F79C4F7AF9548F78D305EC117342D98B8B680E61684DE02C5C2FFFF0FDF0CA7AEAEFAA'

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
