# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

############################################################
 
# Authors: 
#    Emilio Baez,  Sr. Solutions Architect @ MSDF
#    Douglas Loyo, Sr. Solutions Architect @ MSDF
 
# Description: Install script that downloads the repo zip en loads necesarry modules.

############################################################
#Requires -Version 5
#Requires -RunAsAdministrator

Import-Module "$PSScriptRoot\modules\IO" -Force
Import-Module "$PSScriptRoot\modules\Chocolatey" -Force
Import-Module "$PSScriptRoot\modules\Software" -Force
Import-Module "$PSScriptRoot\modules\MsSQLServer" -Force
Import-Module "$PSScriptRoot\modules\Ed-Fi-AMT" -Force
Import-Module "$PSScriptRoot\modules\PowerBi" -Force
Import-Module "$PSScriptRoot\modules\Ed-Fi-TimeTravel" -Force

Import-Module "$PSScriptRoot\modules\installQuickStart" -Force

# TODO: Remove once we have finished development...
# 0) Ensure the working directories exists
$global:pathToWorkingDir = "C:\Ed-Fi\QuickStarts\PowerBIChronicAbsenteeism"
$global:pathToBinaries = "$global:pathToWorkingDir\Bin"
$global:pathToAssets = "$PSScriptRoot\.."
Write-Host "Step: Ensuring working path is accessible. ($global:pathToWorkingDir)"
New-Item -ItemType Directory -Force -Path $global:pathToBinaries

# The name with which to restore the populated template with.
$global:populatedTemplateDatabaseName = "Ed-Fi_v5.3.0_ODS_ChronicAbsenteeismQuickStart"
$connStrToODS = "server=.;database=$global:populatedTemplateDatabaseName;integrated security=sspi;"

# *** Starting The Install *** #
Write-HostInfo "Installing Chronic Absenteeism Quick Start."

Write-HostStep "Step 0: Ensuring all Prerequisites are installed."
Install-QuickStartPrerequisites

Write-HostStep "Step 1: Installing ODS S3 V5.3 Populated Template."
Install-OdsDbsS3V520PopultedTemplate

Write-HostStep "Step 2: Installing Analyitcs Middle Tier v2.7.0."
Install-EdFiAMT $connStrToODS

Write-HostStep "Step 3: Adding Demo data to the database"
$pathToDemoFiles = "$global:pathToAssets\Database\MsSQL\Data"
Invoke-SQLFilesOnDb $pathToDemoFiles $connStrToODS

Write-HostStep "Step 4: Applying required data structures (views)"
$pathToStructureFiles = "$global:pathToAssets\Database\MsSQL\Structure"
Invoke-SQLFilesOnDb $pathToStructureFiles $connStrToODS

Write-HostStep "Step 5: Maturing the data with the Ed-Fi Time Travel Script."
#Install-EdFiTimeTravel $connStrToODS

# 6) Instal PowerBi and the CHRAB Quick Start
Write-HostStep "Step: Installing Power Bi Dashboard."
Install-PowerBi
Open-PowerBiTemplate "$global:pathToAssets\ChronicAbsenteeismDashboard.pbix"

$finalMessage = @"

*************************************************************************************
*                                                                                   *
*    The Ed-fi CHRAB - Chronic Absenteeism Quick Start installation is complete.    *
*    Please continue in PowerBi Desktop (which should open in a few seconds.)       *
*                                                                                   *
*                                                                                   *
*************************************************************************************
"@

Write-Host $finalMessage
