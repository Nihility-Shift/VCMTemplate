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

# print variables
Write-Output "OutputDir: $OutputDir"
Write-Output "SolutionDir: $SolutionDir"
Write-Output "ProjectDir: $ProjectDir"

$DefaultFilesDir = Join-Path $PSScriptRoot "DefaultFiles"
$DefaultReadmeFilePath = Join-Path $DefaultFilesDir "README_Template.md"
$DefaultConfigFilePath = Join-Path $DefaultFilesDir "PluginInfo.config"

$ReleaseFilesDir = Join-Path $ProjectDir "ReleaseFiles"
$ReadmeFilePath = Join-Path $ReleaseFilesDir "README_Template.md"
$ConfigFilePath = Join-Path $ReleaseFilesDir "PluginInfo.config"
$ChangelogFilePath = Join-Path $ReleaseFilesDir "CHANGELOG.md"
$IconFilePath = Join-Path $ReleaseFilesDir "icon.png"

$CSInfoFilePath = Join-Path $ProjectDir "MyPluginInfo.cs"


### Check Template and config files exist
if (-not (Test-Path -PathType container $ReleaseFilesDir))
{
    New-Item -ItemType Directory -Path $ReleaseFilesDir | Out-Null
}

$FailCheck = $false
if (-not (Test-Path $ReadmeFilePath))
{
    Copy-Item $DefaultReadmeFilePath -Destination $ReadmeFilePath -Force
    Write-Output "PreBuild : Error 2 : Release file does not exist. A file has been created at $ReadmeFilePath, please configure."
    $FailCheck = $true
}

if (-not (Test-Path $ConfigFilePath))
{
    Copy-Item $DefaultConfigFilePath -Destination $ConfigFilePath -Force
    Write-Output "PreBuild : Error 2 : Release file does not exist. A file has been created at $ConfigFilePath, please configure."
    $FailCheck = $true
}

if($FailCheck)
{
    Exit 2
}



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
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" # Key
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

# Leave blank for auto GUID (OAthor.Name)
$GUID = $ConfigData["ReleaseProperties"]["GUID"]

# The name of the mod, used for AutoGUID, FileName, and anything else which needs a file-friendly name. Leave blank to use existing data.
$PluginName = $ConfigData["ReleaseProperties"]["PluginName"]

# User friendly name of the mod. Used for thunderstore and BepinPlugin names visible to users. Leave blank to use the PluginName.
$UserPluginName = $ConfigData["ReleaseProperties"]["UserPluginName"]

$ThunderstorePluginName = $ConfigData["ReleaseProperties"]["ThunderstorePluginName"]

# The current version of the mod. Used for file version, BepinPlugin, and Thunderstore manifest.
$PluginVersion = $ConfigData["ReleaseProperties"]["PluginVersion"]

# The version of Void Crew the mod is built for.
[string]$GameVersion = $ConfigData["ReleaseProperties"]["GameVersion"]

# The simple description of the mod, used for VoidManager and thunderstore manifest descriptions. Must be less than 250 Characters
[string]$PluginDescription = $ConfigData["ReleaseProperties"]["PluginDescription"]

# The original author of the mod, used for auto GUID.
$PluginOriginalAuthor = $ConfigData["ReleaseProperties"]["PluginOriginalAuthor"]

# The various authors/editors of the mod.
$PluginAuthors = $ConfigData["ReleaseProperties"]["PluginAuthors"]

# Github Link
[string]$WebpageLink = $ConfigData["ReleaseProperties"]["WebpageLink"]

# FOR FUTURE VOIDMANAGER FEATURE.
# ThunderStore ID (https://thunderstore.io/c/void-crew/p/VoidCrewModdingTeam/VoidManager/ the section equivelant to 'VoidCrewModdingTeam/VoidManager'). Leave blank if unknown.
$ThunderstoreID = $ConfigData["ReleaseProperties"]["ThunderstoreID"]

# Dependency Strings, Comma Deliniated
[string]$DependencyStrings = $ConfigData["ReleaseProperties"]["DependencyStrings"]


## PreBuild Execution Params

# README output path for github readme.
# For output to project dir, use: "$PSScriptRoot\README.md"
# For output to solution Dir, use: "$SolutionDir\README.md"
$ProjectReadmeFileOutPath = $ConfigData["PrebuildExecParams"]["ProjectReadmeOutPath"]
if ($ProjectReadmeFileOutPath -eq "SolutionDir")
{
    $ProjectReadmeFileOutPath = Join-Path $SolutionDir "README.md"
}
elseif($ProjectReadmeFileOutPath -eq "ProjectDir")
{
    $ProjectReadmeFileOutPath = Join-Path $ProjectDir "README.md"
}
elseif($ProjectReadmeFileOutPath.StartsWith("ProjectDir"))
{
    $ProjectReadmeFileOutPath = $ProjectReadmeFileOutPath.Replace("ProjectDir", $ProjectDir)
}
elseif($ProjectReadmeFileOutPath.StartsWith("SolutionDir"))
{
    $ProjectReadmeFileOutPath = $ProjectReadmeFileOutPath.Replace("SolutionDir", $ProjectDir)
}


# Throw error if icon.png does not exist.
$IconError = $ConfigData["PrebuildExecParams"]["IconError"] -eq "True"

# Throw error if CHANGELOG is not updated.
$ChangelogError = $ConfigData["PrebuildExecParams"]["ChangelogError"] -eq "True"

## Edit beyond at your own peril...


Write-Output "Starting Prebuild..."


### Data Validation

# Auto-Fill blank Authors
if(-not $PluginAuthors) { $PluginAuthors = $PluginOriginalAuthor }

# Auto-Fill blank description
if(-not $PluginDescription) { $PluginDescription = $PluginName }

# Exit early if description is too long
if($PluginDescription.Length -gt 250)
{
    Write-Output "PreBuild : Error 3 : PluginDescription is too long. Must be less than 250 characters."
	Exit 3
}


### Update .csproj file.
Write-Output "Updating CSProj file..."

$CSProjPath = Join-Path $ProjectDir "*.csproj"
$CSProjDir = (@(Get-ChildItem -Path $CSProjPath)[0])
$CSProjXML = [xml](Get-Content -Path $CSProjDir.FullName)

# Set Version
Set-XMLText "//Project/PropertyGroup" "Version" $PluginVersion

# Get DefaultNameSpace for MyPluginInfo.cs generation
$TargetNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/RootNamespace")
$DefaultNamespace = $TargetNode.InnerText


# Set AssemblyName
$AssemblyNameXMLNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/AssemblyName")

# Auto-Fill emlpty Plugin Name.
if(-Not $PluginName) { $PluginName = $AssemblyNameXMLNode.InnerText }
else { $AssemblyNameXMLNode.InnerText = $PluginName }


# Set File Description
Set-XMLText "//Project/PropertyGroup" "AssemblyTitle" $PluginDescription

# Set Extra File Description. - Disabled, as some users may not want this. If desired, it can be re-enabled or a config setting can be added.
# Set-XMLText "//Project/PropertyGroup" "Description" $PluginDescription


$CSProjXML.Save($CSProjDir.FullName)




# Auto-Fill UserPluginName if left blank. Must run after PluginName autofill.
if(-Not $UserPluginName)
{
	$UserPluginName = $PluginName
}
# Thunderstore Plugin Name auto-fill. Run after UserPluginName auto-fill.
if(-not $ThunderstorePluginName)
{
    $ThunderstorePluginName = $UserPluginName.Replace(" ", "_")
}


### Create/Update MyPluginInfo.cs
Write-Output "Auto-Filling MyPluginInfo.cs..."

$InfoFileContent = "#pragma warning disable CS1591`r`nnamespace $DefaultNamespace`r`n{`r`n    //Auto-Generated File. Created by PreBuild.ps1`r`n    public class MyPluginInfo`r`n    {"
if($GUID)
{
	$InfoFileContent += "`r`n        public const string PLUGIN_GUID = `"" + $GUID + "`";"
}
else
{
    if(-not $PluginOriginalAuthor)
    {
        Write-Output "PreBuild : Error 4 : Original Author must be filled in if using GUID auto-fill."
        Exit 4
    }
	$InfoFileContent += "`r`n        public const string PLUGIN_GUID = $`"{PLUGIN_ORIGINAL_AUTHOR}.{PLUGIN_NAME}`";"
}
$InfoFileContent += "`r`n        public const string PLUGIN_NAME = `"" + $PluginName + "`";"
$InfoFileContent += "`r`n        public const string USERS_PLUGIN_NAME = `"" + $UserPluginName + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_VERSION = `"" + $PluginVersion + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_DESCRIPTION = `"" + $PluginDescription + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_ORIGINAL_AUTHOR = `"" + $PluginOriginalAuthor + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_AUTHORS = `"" + $PluginAuthors + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_THUNDERSTORE_ID = `"" + $ThunderstoreID + "`";"
$InfoFileContent += "`r`n    }`r`n}`r`n#pragma warning restore CS1591"
Set-Content -LiteralPath $CSInfoFilePath -Value $InfoFileContent




### Auto-Fill Template Files
Write-Output "Starting work on Template Files..."



## Manifest file
Write-Output "Updating manifiest.json..."

$Dependencies = $DependencyStrings.Split(',').Trim();
if ($Dependencies.GetType().Name -eq "String")
{
    $Dependencies = @($Dependencies)
}
$ManifestData = [ordered]@{
    name = $ThunderstorePluginName
    version_number = $PluginVersion
    description = $PluginDescription
    website_url = $WebpageLink
    dependencies = $Dependencies
}
$ManifestOutputPath = Join-Path $OutputDir "manifest.json"
ConvertTo-Json $ManifestData | % { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Out-File -FilePath $ManifestOutputPath -Encoding UTF8


## README file
Write-Output "Updating README.md..."

$ReadmeData = Get-Content -Path $ReadmeFilePath -Encoding UTF8

$ReadmeData = $ReadmeData.Replace("[GameVersion]", $GameVersion)
$ReadmeData = $ReadmeData.Replace("[ModVersion]", $PluginVersion)
$ReadmeData = $ReadmeData.Replace("[Authors]", $PluginAuthors)
$ReadmeData = $ReadmeData.Replace("[Dependencies]", $DependencyStrings)
$ReadmeData = $ReadmeData.Replace("[UserModName]", $UserPluginName)
$ReadmeData = $ReadmeData.Replace("[ModName]", $PluginName)
$ReadmeData = $ReadmeData.Replace("[Description]", $PluginDescription)


# Write README to Output folder - Old code, saved file with BOM. Thunderstore does not accept BOM.
# $ReadmeData | Out-File -FilePath "$OutputDir\README.md" -Encoding utf8

# Write README to Output folder
$ReadmeOutputPath = Join-Path $OutputDir "README.md"
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($ReadmeOutputPath, $ReadmeData, $Utf8NoBomEncoding)

# Write 2nd README to Project Output folder for github
if($ProjectReadmeFileOutPath)
{
    [System.IO.File]::WriteAllLines($ProjectReadmeFileOutPath, $ReadmeData, $Utf8NoBomEncoding)
    ## $ReadmeData | Out-File -FilePath $ProjectReadmeFileOutPath -Encoding utf8
}



## Changelog file
if(Test-Path -Path $ChangelogFilePath)
{
    Write-Output "Copying CHANGELOG.md..."

    $ChangelogData = Get-Content -Path $ChangelogFilePath
    if(-Not $ChangelogData.Contains("## $PluginVersion"))
    {
    	if($ChangelogError)
    	{
            Write-Output "PreBuild : Error 5 : Changelog does not contain an entry for the current plugin version."
    		Exit 5
    	}
        Write-Output "PreBuild : Warning 5 : Changelog does not contain an entry for the current plugin version."
    }
    $ChangelogOutputDest = Join-Path $OutputDir (Split-Path $ChangelogFilePath -Leaf)
    Copy-Item -Path $ChangelogFilePath -Destination $ChangelogOutputDest
}



## icon file
Write-Output "Copying icon.png..."
if(Test-Path $IconFilePath)
{
    $IconOutputDest = Join-Path $OutputDir (Split-Path $IconFilePath -Leaf)
    Copy-Item -Path $IconFilePath -Destination $IconOutputDest
}
else
{
	if($IconError)
	{
        Write-Output "PreBuild : Error 6 : icon.png does not exist in ReleaseFiles."
		Exit 6
	}
    else
    {
        Write-Output "PreBuild : Warning 6 : icon.png does not exist in ReleaseFiles."
    }
}

Write-Host "PreBuild Complete!"
