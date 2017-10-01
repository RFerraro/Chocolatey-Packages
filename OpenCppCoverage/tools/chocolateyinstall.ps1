
$ErrorActionPreference = 'Stop';

$url32 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.6.1/OpenCppCoverageSetup-x86-0.9.6.1.exe'
$url64 = 'https://github.com/OpenCppCoverage/OpenCppCoverage/releases/download/release-0.9.6.1/OpenCppCoverageSetup-x64-0.9.6.1.exe'
$checksum32 = '7DCD8858C068E61DC20F8A687291A5DF2174E0FDC76485DC7F8ED1D460D7A6CE4F2FF2C84FD426B5C865F3DBBBD1CEC17337DEF6D3A178B28B24DA6FF08907C8'
$checksum64 = 'E21EE29F827ABA12EE23FEE04FFCD8142A40E57B1252C9178332DD324E0C3F26F4C602916D6C718947E032B2FA2256F4EEE4F41BF9CFC32D00DDAE8FBDB9F287'

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
