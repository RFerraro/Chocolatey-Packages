param(
    [string]$ReleaseName = "latest"
     )

Add-Type -AssemblyName System.Web

function Split-Items
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Item
        )
    
    Process
    {
        if($Item.Contains('='))
        {
            $pair = $Item -split '='
            
            @{ ($pair[0].ToLower().Trim()) = ($pair[1].Trim()) }
        }
        else
        {
            @{ ($Item.ToLower().Trim()) = '' }
        }
    }
}

function Parse-ReleasePlatform
{
    param(
        [string]$Filename
        )

    Process
    {
        if($Filename.Contains('-x64-'))
        {
            'x64'
        }
        elseif($Filename.Contains('-x86-'))
        {
            'x86'
        }
        else
        {
            'unknown'
        }
    }
}

function Get-ReleaseInfo
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        $ReleaseInfo
        )

    Process
    {
        $downloadUri = $ReleaseInfo.browser_download_url
        
        $tmpfilename=[System.IO.Path]::GetTempFileName()
        $tmpfilename=[System.IO.Path]::ChangeExtension($tmpfilename, '.exe')
        
        $response = Invoke-WebRequest $downloadUri -ErrorAction Ignore

        if($response.StatusDescription -ne "OK")
        {
            throw "WebRequest failed..."
        }

        [io.file]::WriteAllBytes($tmpfilename, $response.content)

        $info = (Get-ChildItem $tmpfilename).VersionInfo
        $checksum = checksum -t sha512 -f $tmpfilename

        $platform = Parse-ReleasePlatform $ReleaseInfo.name

        @{
            FileName = $ReleaseInfo.name
            FileDescription = $info.FileDescription
            FileVersion = $info.FileVersion
            ProductVersion = $info.ProductVersion
            Platform = $platform
            Uri = $downloadUri
            Checksum = $checksum
        }

        Remove-Item $tmpfilename
    }
}

function Get-GreaterThanOrZero
{
    param(
        [int]$Value
        )

    Process
    {
        if($Value -lt 0)
        {
            Write-Output 0
        }
        else
        {
            Write-Output $Value
        }
    }
}

function Append-PackageVersion
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$String
        )

    Process
    {
        $version = [System.Version]::Parse($String)

        $major    = Get-GreaterThanOrZero $version.Major
        $minor    = Get-GreaterThanOrZero $version.Minor
        $build    = Get-GreaterThanOrZero $version.Build
        $revision = Get-GreaterThanOrZero ($version.Revision * 100)

        "{0}.{1}.{2}.{3}" -f $major,$minor,$build,$revision
    }
}

function Get-Latest
{
    $repoInfoUri = 'https://api.github.com/repos/OpenCppCoverage/OpenCppCoverage'
    $githubRepoInfo = Invoke-RestMethod -Method Get -Uri $repoInfoUri -Header @{ "Accept" = "application/vnd.github.v3+json" }

    if($ReleaseName -ne "latest")
    {
        $releaseUri = 'https://api.github.com/repos/OpenCppCoverage/OpenCppCoverage/releases/tags/' + $ReleaseName
    }
    else
    {
        $releaseUri = 'https://api.github.com/repos/OpenCppCoverage/OpenCppCoverage/releases/latest'
    }
    
    $githubReleaseInfo = Invoke-RestMethod -Method Get -Uri $releaseUri -Header @{ "Accept" = "application/vnd.github.v3+json" }

    $releaseLinks = $githubReleaseInfo.assets `
        | Get-ReleaseInfo `
        | %{ `
            @{ `
                $_.Platform = `
                    @{ 
                        Uri = $_.Uri
                        ProductVersion =  $_.ProductVersion
                        Checksum = $_.Checksum
                    } 
             } 
           }

    if(-Not $releaseLinks.x64)
    {
        throw "No x64 Download found!"
    }

    if(-Not $releaseLinks.x86)
    {
        throw "No x86 Download found!"
    }
    
    if($releaseLinks.x64.Uri -eq $releaseLinks.x86.Uri)
    {
        throw "Download links are the same!"
    }

    if($releaseLinks.x64.ProductVersion -ne $releaseLinks.x86.ProductVersion)
    {
        throw "Product version is not the same between x64 and x86!"
    }

    $packageVersion = $releaseLinks.x64.ProductVersion | Append-PackageVersion

    @{
        ProjectUrl = $githubRepoInfo.html_url
        LicenseUrl = $githubRepoInfo.html_url + '/blob/master/LICENSE.txt'
        ProjectSourceUrl = $githubRepoInfo.html_url + "/archive/" + $githubReleaseInfo.tag_name + ".zip"
        DocsUrl = $githubRepoInfo.html_url + '/wiki'
        BugTrackerUrl = $githubRepoInfo.html_url + '/issues'
        
        ReleaseNotes = $githubReleaseInfo.body
        PackageVersion = $packageVersion
        Uri64 = $releaseLinks.x64.Uri
        Uri32 = $releaseLinks.x86.Uri
        Checksum64 = $releaseLinks.x64.Checksum
        Checksum32 = $releaseLinks.x86.Checksum
    }
}

function global:au_SearchReplace 
{    
    @{  
        'tools\chocolateyInstall.ps1' = `
        @{
            "(^[$]url64\s*=\s*)('.*')"      = "`$1'$($Latest.Url64)'"
            "(^[$]url32\s*=\s*)('.*')"      = "`$1'$($Latest.Url32)'"
            "(^[$]checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
            "(^[$]checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
     }
}

function global:au_GetLatest 
{
    $info = Get-Latest

    @{
        Version = $info.PackageVersion
        ProjectUrl = $info.ProjectUrl
        LicenseUrl = $info.LicenseUrl
        ProjectSourceUrl = $info.ProjectSourceUrl
        DocsUrl = $info.DocsUrl
        BugTrackerUrl = $info.BugTrackerUrl
        ReleaseNotes = $info.ReleaseNotes
        Url64 = $info.Uri64
        Url32 = $info.Uri32
        ChecksumType64 = 'sha512'
        ChecksumType32 = 'sha512'
        Checksum64 = $info.Checksum64
        Checksum32 = $info.Checksum32
    }
}

Update-Package -ChecksumFor none

$scriptPath = Split-Path -Parent $PSCommandPath

$nuspec = New-Object xml
$nuspec.PSBase.PreserveWhitespace = $true

$nuspec.Load("$scriptPath\opencppcoverage.nuspec")

$nuspec.package.metadata.id = $nuspec.package.metadata.id.ToLower()
$nuspec.package.metadata.releaseNotes = [string]$Latest.ReleaseNotes

$nuspec.package.metadata.projectUrl = [string]$Latest.ProjectUrl
$nuspec.package.metadata.licenseUrl = [string]$Latest.LicenseUrl
$nuspec.package.metadata.projectSourceUrl = [string]$Latest.ProjectSourceUrl
$nuspec.package.metadata.docsUrl = [string]$Latest.DocsUrl
$nuspec.package.metadata.bugTrackerUrl = [string]$Latest.BugTrackerUrl

$nuspec.Save("$scriptPath\opencppcoverage.nuspec")
