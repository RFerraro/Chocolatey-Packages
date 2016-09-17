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

function Decode-HtmlString
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$String
        )

    Process
    {
        [System.Web.HttpUtility]::HtmlDecode($String)
    }
}

function Read-Feed
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Uri
        )
    
    Process
    {
        $rssResponse = Invoke-WebRequest $feedUrl
        Write-Verbose $rssResponse

        $xml = [xml]$rssResponse.Content
        $latest = $xml.rss.channel.SelectSingleNode('item')
        if($latest)
        {
            @{
                RssTitle = $latest.title
                RssUri = $latest.link
                RssDescription = $latest.description
            }
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

function Read-ReleaseUri
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Uri
        )
    
    Process
    {
        $response = Invoke-WebRequest $Uri
        Write-Verbose $response

        $response.Links `
            | Where {$_.id} `
            | Where {$_.id.StartsWith('fileDownload')} `
            | %{@{ ReleaseTitle = $_.innerText; ReleaseLink = $_.href }}
    }
}

function Get-DownloadLink
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Uri
        )

    Process
    {
        $request = Invoke-WebRequest $Uri -MaximumRedirection 0 -ErrorAction Ignore

        $request.Links | Where {$_.innerText -eq "here"} | Select -expand href | Decode-HtmlString
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
        $uri = $ReleaseInfo.ReleaseLink | Get-DownloadLink
        
        $tmpfilename=[System.IO.Path]::GetTempFileName()
        $tmpfilename=[System.IO.Path]::ChangeExtension($tmpfilename, '.exe')
        
        $response = Invoke-WebRequest $Uri -ErrorAction Ignore

        if($response.StatusDescription -ne "OK")
        {
            throw "WebRequest failed..."
        }

        [io.file]::WriteAllBytes($tmpfilename,$response.content)
        $contentDisposition = $response.Headers.'Content-Disposition' -split ';' | Split-Items

        $info = (Get-ChildItem $tmpfilename).VersionInfo
        $checksum = checksum -t sha512 -f $tmpfilename

        $platform = Parse-ReleasePlatform $contentDisposition.filename

        @{
            FileName = $contentDisposition.filename
            FileDescription = $info.FileDescription
            FileVersion = $info.FileVersion
            ProductVersion = $info.ProductVersion
            Platform = $platform
            Uri = $uri
            Checksum = $checksum
        }

        Remove-Item $tmpfilename
    }
}

function Remove-HtmlTags
{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$String
        )

    Begin
    {
        $regex = '<[^>]+>'
        $newline = '<[bB][rR][^>]+>'
    }

    Process
    {
        $String = $String -replace $newline,[System.Environment]::NewLine
        $String -replace $regex,''
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
    #RSS
    $feedUrl = 'https://opencppcoverage.codeplex.com/project/feeds/rss?ProjectRSSFeed=codeplex%3a%2f%2frelease%2fopencppcoverage'

    $feedInfo = Read-Feed -Uri $feedUrl

    $releaseNotes =  $feedInfo | %{ $_.RssDescription } | Remove-HtmlTags | Out-String

    $releaseLinks = $feedInfo `
        | %{ $_.RssUri } `
        | Read-ReleaseUri `
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
        ReleaseNotes = $($releaseNotes | Out-String)
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

$nuspec.Save("$scriptPath\opencppcoverage.nuspec")
