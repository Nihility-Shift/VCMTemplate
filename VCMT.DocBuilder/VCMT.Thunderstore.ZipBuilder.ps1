###
### Void Crew Modding DocBuilder Script
### For general modding usage
###
### Written by Dragon of VoidCrewModdingTeam.
### Modified by: 
###
### Script Version 1.2.1
###
###
### This script was created for auto-generation/fill of release files for Void Crew mods.
###
###

### Error codes
##
## 2 - Release files do not exist.
## Files should automatically be copied to a folder "ReleaseFiles". Fill the config out at a minumum.
## 
## 3 - PluginDescription is too long. Must be less than 250 characters.
##
## 4 - GUID Auto Fill - Plugin name needs to exist.
##
## 5 - Changelog does not contain an entry for the current plugin version.
##
## 6 - icon.png does not exist in ReleaseFiles.
##
## 50 - Debug error, you should never see this in a released version.


### Parameters input by commandline.
param ($OutputDir, $SolutionDir, $ProjectDir)

$DefaultReadmeFilePath = "$PSScriptRoot\DefaultFiles\README_Template.md"
$DefaultConfigFilePath = "$PSScriptRoot\DefaultFiles\PluginInfo.config"

$ReleaseFilesDir = $ProjectDir + "ReleaseFiles"
$ReadmeFilePath = "$ReleaseFilesDir\README_Template.md"
$ConfigFilePath = "$ReleaseFilesDir\PluginInfo.config"
$ChangelogFilePath = "$ReleaseFilesDir\CHANGELOG.md"
$IconFilePath = "$ReleaseFilesDir\icon.png"

$CSInfoFilePath = $ProjectDir + "MyPluginInfo.cs"

### Script Functions

## Sets XML text, Creates XML entry if non-existant. Requires CSProjXML var set
function Set-XMLText
{
    param ( $ParentPath, $NodeName, $Text )

    $TargetNode = $Script:CSProjXML.SelectSingleNode("$ParentPath/$NodeName")
    if($TargetNode)
    {
        $TargetNode.InnerText = $Text
    }
    else
    {
        Write-Host ("Creating XML Node $NodeName")
        $XMLElement = $Script:CSProjXML.CreateElement($NodeName)
        $XMLElement.InnerXml = $Text
        $ParentNode = $Script:CSProjXML.SelectSingleNode("$ParentPath")
        $_ = $ParentNode.AppendChild($XMLElement)
    }
}

## Simple Config reader. Credit to https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-any-ini-file/
function Get-ConfigContent ($FilePath)
{
    $ini = @{}
    switch -regex -File $FilePath
    {
        “^\[(.+)\]” # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        “^(;.*)$” # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = “Comment” + $CommentCount
            $ini[$section][$name] = $value
        }
        “(.+?)\s*=(.*)” # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}


### Load config data from .config file.
$ConfigData = Get-ConfigContent($ConfigFilePath)

### Input Vars

# The name of the mod, used for AutoGUID, FileName, and anything else which needs a file-friendly name. Leave blank to use existing data.
$PluginName = $ConfigData["ReleaseProperties"]["PluginName"]

# The current version of the mod. Used for file version, BepinPlugin, and Thunderstore manifest.
$PluginVersion = $ConfigData["ReleaseProperties"]["PluginVersion"]

# Build Zip File
$BuildZip = $ConfigData["PrebuildExecParams"]["ZipOutput"] -eq "True"

## PostBuild Execution Params

# Throw error if icon.png does not exist.
$IconError = $ConfigData["PrebuildExecParams"]["IconError"] -eq "True"

## Edit beyond at your own peril...


Write-Output "Starting Postbuild..."


### Data Validation

### Update .csproj file.
Write-Output "Reading CSProj file..."

$CSProjDir = (@(Get-ChildItem -Path ($ProjectDir + "\*.csproj"))[0])
$CSProjXML = [xml](Get-Content -Path $CSProjDir.FullName)

# Set AssemblyName
$AssemblyNameXMLNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/AssemblyName")

# Auto-Fill empty Plugin Name.
if(-Not $PluginName) { $PluginName = $AssemblyNameXMLNode.InnerText }


### Build Zip

if ($BuildZip -and $PluginVersion)
{
    Write-Output "Building Zip file..."
    [System.IO.Directory]::CreateDirectory("$OutputDir\Releases")
    Compress-Archive -Path "$OutputDir\README.md", "$OutputDir\CHANGELOG.md", "$OutputDir\manifest.json", "$OutputDir$PluginName.dll"   -DestinationPath "$OutputDir\Releases\$PluginName-$PluginVersion.zip" -Force

    ## icon file
    Write-Output "Copying icon.png..."
    if(Test-Path $IconFilePath)
    {
        Compress-Archive -Path "$OutputDir\icon.png" -DestinationPath "$OutputDir\Releases\$PluginName-$PluginVersion.zip" -Update
    }
    else
    {
	    if($IconError)
	    {
            Write-Output "PostBuild : Error 6 : icon.png does not exist in ReleaseFiles."
		    Exit 6
	    }
        else
        {
            Write-Output "PostBuild : Warning 6 : icon.png does not exist in ReleaseFiles."
        }
    }
}

Write-Host "PostBuild Complete!"
