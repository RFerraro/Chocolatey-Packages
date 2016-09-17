
$ErrorActionPreference = 'Stop';

$url32 = 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=opencppcoverage&DownloadId=1594913&FileTime=131138685087100000&Build=21031'
$url64 = 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=opencppcoverage&DownloadId=1594912&FileTime=131138681432830000&Build=21031'
$checksum32 = '980DE3A272BB2AE325DAA3331319BC45854CBFD768EE1D7474FAA731656EAC42D4D0CC2970B3C4F54F8ADD6488DA73C5D5F8165828E3F0707C1DE06226B8440F'
$checksum64 = '49D4B42D9AAD4942F60E0AD72EBF99B89205D3E56A1FD8941A69ED1FDE8B2CB8DD8B0DD44A7D7FC4495153C908020426A1E760F5648CC15362EF1393E09D862A'

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
