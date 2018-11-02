Param (
    [Parameter(Mandatory=$true)][String]$dest,

    $javaVersion = "8",
    $releaseType = "releases",
    $impl = "hotspot",
    $os = "windows",
    $arch = "x64",
    $release = "latest",
    $type = "jdk",
    $proxy
)

$ErrorActionPreference = "Stop"

. $PSScriptRoot\download.ps1

$url= "https://api.adoptopenjdk.net/v2/binary/${releaseType}/openjdk${javaVersion}?openjdk_impl=${impl}&os=${os}&arch=${arch}&release=${release}&type=${type}"
$url = Get-RedirectedUrl $url

if($proxy) {
    $url = $url -replace '^https://github\.com/AdoptOpenJDK', $proxy
}

DownloadAndUnzip "$url" "$dest"
exit $?
