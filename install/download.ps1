##################################################################################################################
# PowerShell functions for downloading files from the interweb
##################################################################################################################

# Converts a URL into its redirection target
function Get-RedirectedUrl
{
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )

    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    $response=$request.GetResponse()

    If ($response.StatusCode -eq "Found")
    {
        $response.GetResponseHeader("Location")
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Unzips a file
#
# Parameters:
#  zipFile - The path of the file to unzip
#  outPath - The path of the directory to unzip to
function Unzip
{
    param(
        [String]$zipFile,
        [String]$outPath,
        [String]$description=$zipFile
    )

    Write-Host "Extracting $description to $outPath"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outpath)
}

# Downloads a file
#
# Parameters:
#  url - The url to download from
#  destFile - The file to download to
function Download
{
    param(
        [Parameter(Mandatory=$true)][string]$url,
        [Parameter(Mandatory=$true)][string]$destFile
    )

    Write-Host "Downloading $url"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri $url -OutFile $destFile -ErrorAction Stop
}

# Downloads a file (assumed to be a zip), and extracts it
#
# Parameters:
#  url - The url to download from
#  destDir - The directory to extract the downloaded zip into
function DownloadAndUnzip
{
    param(
        [Parameter(Mandatory=$true)][string]$url,
        [Parameter(Mandatory=$true)][string]$destDir
    )

    $tempFile = [System.IO.Path]::GetTempFileName()
    $description = [System.IO.Path]::GetFileName($url)
    Download $url $tempFile
    Unzip $tempFile $destDir -description $description
}
