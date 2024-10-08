# VCMT's Doc Builder
This project helps fill in version data and zip files used/required for a Thunderstore release.
- CHANGELOG.md
  - Verifies a changelog has an entry of the corrosponding version. Can be configured to throw an error if the version is not found.
- README.md
  - Uses a README template to fill in data entries such as game version, mod version, required dependencies, etc.
  - It is recommended to fill in proper description details for the readme, as the Description has a 250 character limit.
- manifest.json
  - Generates a new manifest file using information from the PluginInfo.config file.
- icon.png
  - Can be configured to fail build if the icon.png file is not found.
- MyPluginInfo.cs
  - Generates a class 'MyPluginInfo' with const entries for corrosponding configured values.
- Assembly Info
  - Fills in data in your .csproj file corrosponding to filled in config details such as the file name, version, and description.

Originally intended as a way to help me keep version information up to date for the 30+ mods managed by Void Crew Modding Team, this package utilizes a powershell
script to fill data from 1 config file into the various locations required for proper documentation on thunderstore. It saves me (you) much time
verifying all versions and descriptions match, just to publish a release and find out the file version doesn't match the intended release version.

This project was inspired by BepInEx's PluginInfoProps package.


# Usage

Import this package into your project through NuGet. NuGet Package Manager is built in to Visual Studio, and can be used to find and include
the package into your project.


1) On Build, the script will create a folder 'ReleaseFiles' in your Project Directory, if it does not exist With the PluginInfo.config and
README.md files. The script will then stop the build process

2) Customize the README.md to your liking and fill in the PluginInfo.config file with your Plugin's information.

3) On the next build 'MyPluginInfo.cs' will be generated using your configured information in the form of consts, then fail. Utilize these consts where applicable.

4) On the next build, your files will be filled in and copied to your output directory. Depending on configuration, it will fail if missing 
an icon.png file or the CHANGELOG.md does not contain '## [PluginVersion]' where [PluginVersion] matches the current plugin version.

# Errors

On failure, the script will fail to run and an error will be provided in the VS error list.

2 common errors you may see in Visual studio, which are caused by building while the .config file is open:
- "XML document must contain a root level element."
- "Invalid token 'Text' at root level of document."  

# Generated Text
The following text was filled in using the template found at VCMTemplte/DefaultFiles/README_Template.md


---------------------

[![](https://img.shields.io/badge/-Void_Crew_Modding_Team-111111?style=just-the-label&logo=github&labelColor=24292f)](https://github.com/Void-Crew-Modding-Team)
![](https://img.shields.io/badge/Game%20Version-0.27.0-111111?style=flat&labelColor=24292f&color=111111)
[![](https://img.shields.io/discord/1180651062550593536.svg?&logo=discord&logoColor=ffffff&style=flat&label=Discord&labelColor=24292f&color=111111)](https://discord.gg/g2u5wpbMGu "Void Crew Modding Discord")

# VCMTemplate

Version 1.0.0  
For Game Version 0.27.0  
Developed by VCMT  
Requires  BepInEx-BepInExPack-5.4.2100, VoidCrewModdingTeam-VoidManager-1.1.8


---------------------

### 💡 Function(s)

- function 1
- function 2

### 🎮 Client Usage

- Some blob about how to use the mod

### 👥 Multiplayer Functionality

- ✅ All
  - All players must have this mod installed.

---------------------

## 🔧 Install Instructions - **Install following the normal BepInEx procedure.**

Ensure that you have [BepInEx 5](https://thunderstore.io/c/void-crew/p/BepInEx/BepInExPack/) (stable version 5 **MONO**) and [VoidManager](https://thunderstore.io/c/void-crew/p/VoidCrewModdingTeam/VoidManager/) installed.

#### ✔️ Mod installation - **Unzip the contents into the BepInEx plugin directory**

Drag and drop `VCMTemplate.dll` into `Void Crew\BepInEx\plugins`
