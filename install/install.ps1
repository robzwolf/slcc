##################################################################################################################
# powershell script to setup project and repository
##################################################################################################################

param (
    [Parameter(Mandatory=$true)][String]$projectDir,
    [String]$repo,
    [String]$scriptsDir=$PSScriptRoot
)

$ErrorActionPreference = "Stop"

$templatesDir = "${projectDir}\install\templates"
$toolsDir = "${projectDir}\tools\"

$gradleWrapperPropertiesTemplate = "${templatesDir}gradle-wrapper.properties.template"
$gradlePropertiesTemplate = "${templatesDir}gradle.properties.template"

$propertiesContent = Get-Content "$scriptsDir/PROPERTIES"
$properties = @{}
foreach($line in $propertiesContent) {
    $words = $line.Split('=', 2)
    $properties.add($words[0].Trim(), $words[1].Trim())
}

#
# Install JDK
#

$jdkDir = "${toolsDir}jdk\"

$args = @{
    dest = $jdkDir;
    javaVersion = $properties['javaVersion']
}
if($repo) {
    $args.proxy = "$repo/openjdk"
}
& "$scriptsDir\install-jdk.ps1" @args

$jdks = @(Get-ChildItem $jdkDir)
if($jdks.length -ne 1) {
    throw "Error with JDK installation: more than 1 JDK directory detected: $jdks (${jdks.length})"
}

$javaHome = $jdks[0].FullName -replace '\\', '/'

#
# Modify properties files
#

Add-Content -Path "$projectDir\gradle.properties" -Value ""
Add-Content -Path "$projectDir\gradle.properties" -Value "org.gradle.java.home=$javaHome"

if($repo) {
    Add-Content -Path "$projectDir\gradle.properties" -Value "mavenProxyUrl=$repo/maven-public"

    (Get-Content "$projectDir\gradle\wrapper\gradle-wrapper.properties") |
        Foreach-Object {
            $_ -replace 'https?\\?://services\.gradle\.org/distributions', "$repo/gradle-distributions"
        } |
        Set-Content "$projectDir\gradle\wrapper\gradle-wrapper.properties"
}
