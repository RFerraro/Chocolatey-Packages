
$ErrorActionPreference = 'Stop';

$url32 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.7.0/OpenCppCoverageSetup-x86-0.9.7.0.exe'
$url64 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.7.0/OpenCppCoverageSetup-x64-0.9.7.0.exe'
$checksum32 = '7D0C64DED2FF91A3BF320BA4AC57D96FDB33095E727652F515D24667779A152310B206D1FE3F713F16A3AB4D23F62F4E882BE464682D60D43368B925D975B5FB'
$checksum64 = '40BEDAFC9B819B90C5FB08CE222D109B9B88E7F0BBCE6E5F8543C1A595270FCB1479F8B385B04D3D251213375A44ADCA7EA7992C03867D4ED67925D959CE192C'

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
