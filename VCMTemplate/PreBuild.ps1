###
### Void Crew Modding PreBuild Script
### For use with VoidManager
###
### Written by Dragon of VoidCrewModdingTeam.
### Modified by: 
###
### Script Version 0.0.2
###
###
### This script was created for auto-generation/fill of release files for Void Crew mods.
###
###



param ($OutputDir, $SolutionDir)

$ReleaseFilesDir = "$PSScriptRoot\ReleaseFiles"
$ManifestFilePath = "$ReleaseFilesDir\manifest.json"
$ReadmeFilePath = "$ReleaseFilesDir\README.md"
$ChangelogFilePath = "$ReleaseFilesDir\CHANGELOG.md"
$IconFilePath = "$ReleaseFilesDir\icon.png"
$CSInfoFilePath = "$PSScriptRoot\MyPluginInfo.cs"

# README output path for github. 
# For output to project dir, use: "$PSScriptRoot\README.md"
# For output to solutionDir, use: "$SolutionDirREADME.md"
$ProjectReadmeFileOutPath = "$SolutionDir\README.md"


## INTERNAL NOTE - Move variable entry to props file. If users update their mod settings by re-importing their PreBuild file, they will lose all settings.
### Input Vars
## Value assignments start here

# Leave blank for auto GUID (OAthor.Name)
$GUID = "" 

# The name of the mod, used for AutoGUID, FileName, and anything else which needs a file-friendly name. Leave blank to use existing data.
$PluginName = ""

# User friendly name of the mod. Used for thunderstore and BepinPlugin names visible to users. Leave blank to use the PluginName.
$UserPluginName = ""

# The current version of the mod. Used for file version, BepinPlugin, and Thunderstore manifest.
$PluginVersion = "1.0.0"

# The version of VoidManager utilized by the mod.
$VoidManagerVersion = "1.1.7"

# The version of Void Crew the mod is built for.
$GameVersion = "0.26.3"

# The simple description of the mod, used for VoidManager and thunderstore manifest descriptions. Must be less than 250 Characters
$PluginDescription = ""

# The original author of the mod, used for auto GUID.
$PluginOriginalAuthor = ""

# The various authors/editors of the mod.
$PluginAuthors = "$PluginOriginalAuthor"

# Github Link
$GithubLink = ""

# NOT IMPLEMENTED. FOR FUTURE VOIDMANAGER FEATURE.
# ThunderStore ID (https://thunderstore.io/c/void-crew/p/VoidCrewModdingTeam/VoidManager/ the section equivelant to 'VoidCrewModdingTeam/VoidManager')
$ThunderStoreID = ""


### PreBuild Execution Params

# Throw error if icon.png does not exist.
$IconError = $false

# Throw error if CHANGELOG is not updated.
$ChangelogError = $true

## Value assignments end here.
## Edit beyond at your own peril...

Write-Output "Starting Prebuild..."

# ERROR CODE 2 - Exit early if description is too long
if($PluginDescription.Length -gt 250)
{
	Write-Warning "PluginDescription is too long. Must be less than 250 characters."
	Exit 2
}

### Update .csproj file.
Write-Output "Updating CSProj file..."

$CSProjDir = (@(Get-ChildItem -Path ($PSScriptRoot + "\*.csproj"))[0])
$CSProjXML = [xml](Get-Content -Path $CSProjDir.FullName)

# Set Version
$TargetNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/Version")
$TargetNode.'#text' = $PluginVersion

$TargetNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/RootNamespace")
$DefaultNamespace = $TargetNode.'#text'

# Set AssemblyName
$AssemblyNameXMLNode = $CSProjXML.SelectSingleNode("//Project/PropertyGroup/AssemblyName")
if(-Not $PluginName)
{
	# Auto-Fill Plugin Name.
	$PluginName = $AssemblyNameXMLNode.'#text'
}
if($AssemblyNameXMLNode.'#text' -ne $PluginName)
{
	$AssemblyNameXMLNode.'#text' = $PluginName
}

$CSProjXML.Save($CSProjDir.FullName)


# Auto-Fill UserPluginName if left blank. Must run after PluginName autofill.
if(-Not $UserPluginName)
{
	$UserPluginName = $PluginName
}




### Create/Update MyPluginInfo.cs
Write-Output "Auto-Filling MyPluginInfo.cs..."

$InfoFileContent = "namespace $DefaultNamespace`r`n{`r`n    //Auto-Generated File. Created by PreBuild.ps1`r`n    public class MyPluginInfo`r`n    {"
if($GUID)
{
	$InfoFileContent += "`r`n        public const string PLUGIN_GUID = `"" + $GUID + "`";'"
}
else
{
	$InfoFileContent += "`r`n        public const string PLUGIN_GUID = $`"{PLUGIN_ORIGINAL_AUTHOR}.{PLUGIN_NAME}`";"
}
$InfoFileContent += "`r`n        public const string PLUGIN_NAME = `"" + $PluginName + "`";" 
$InfoFileContent += "`r`n        public const string PLUGIN_VERSION = `"" + $PluginVersion + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_DESCRIPTION = `"" + $PluginDescription + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_ORIGINAL_AUTHOR = `"" + $PluginOriginalAuthor + "`";"
$InfoFileContent += "`r`n        public const string PLUGIN_AUTHORS = `"" + $PluginAuthors + "`";"
$InfoFileContent += "`r`n    }`r`n}"
Set-Content -LiteralPath $CSInfoFilePath -Value $InfoFileContent




### Auto-Fill Template Files
Write-Output "Starting work on Template Files..."

## Manifest file
Write-Output "Updating manifiest.json..."

$ManifestData = Get-Content -Path $ManifestFilePath | ConvertFrom-Json
$ManifestData.name = $UserPluginName
$ManifestData.version_number = $PluginVersion
$ManifestData.website_url = $GithubLink
$ManifestData.description = $PluginDescription
$ManifestData.dependencies = ([string]$ManifestData.dependencies).Replace("[VoidManagerVersion]", $VoidManagerVersion).Split(', ')
ConvertTo-Json $ManifestData | Out-File -FilePath "$OutputDir\manifest.json"



## README file
Write-Output "Updating README.md..."

$ReadmeData = Get-Content -Path $ReadmeFilePath -Encoding UTF8

$ReadmeData = $ReadmeData.Replace("[GameVersion]", $GameVersion)
$ReadmeData = $ReadmeData.Replace("[ModVersion]", $PluginVersion)
$ReadmeData = $ReadmeData.Replace("[Authors]", $PluginAuthors)
$ReadmeData = $ReadmeData.Replace("[VoidManagerVersion]", $VoidManagerVersion)
$ReadmeData = $ReadmeData.Replace("[UserModName]", $UserPluginName)
$ReadmeData = $ReadmeData.Replace("[ModName]", $PluginName)

#Write README to Output folder
$ReadmeData | Out-File -FilePath "$OutputDir\README.md" -Encoding utf8

#Write 2nd README to Project Output folder for github
$ReadmeData | Out-File -FilePath $ProjectReadmeFileOutPath -Encoding utf8



## Changelog file
Write-Output "Copying CHANGELOG.md..."

$ChangelogData = Get-Content -Path $ChangelogFilePath
if(-Not $ChangelogData.StartsWith("## $PluginVersion"))
{
    Write-Warning "Changelog does not start with the current plugin version"
	if($ChangelogError)
	{
		Exit 3
	}
}

Copy-Item -Path $ChangelogFilePath -Destination $OutputDir



## icon file
Write-Output "Copying icon.png..."
if(Test-Path $IconFilePath)
{
    Copy-Item -Path $IconFilePath -Destination $OutputDir
}
else
{
	Write-Warning "icon.png does not exist in ReleaseFiles."
	if($IconError)
	{
		Exit 4
	}
}