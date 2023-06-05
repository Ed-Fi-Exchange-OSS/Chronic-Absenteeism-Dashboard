# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

############################################################

# Author: Douglas Loyo, Sr. Solutions Architect @ MSDF

# Description: Module contains a collection of IO utility functions.

# Note: This powershell has to be ran with Elevated Permissions (As Administrator) and in a x64 environment.

############################################################

Function Install-QuickStartPrerequisites() {
    Write-Host "Installing Quick Start Prerequisites"
    Install-Chocolatey
    Install-NugetPackageProvider
    Install-AzurePackageProvider
    Install-MsSQLServerExpress
    Install-SQLServerModule
}

Function Install-OdsDbsS3V520PopultedTemplate()
{
    Write-Host "     Downloading database"
    $outputpath = "$global:pathToBinaries\"
    $package = Save-Package -Name EdFi.Suite3.Ods.Populated.Template -RequiredVersion "5.3.297" -Source EdFi@Release -LiteralPath $outputpath

    Write-Host "     Unziping database"
    $nugetFile = "$outputpath\$($package.name).$($package.version).nupkg"
    $zipFile = "$outputpath\$($package.name).$($package.version).zip"
    # Delete the file if it exits as Rename wont work.
    if(Test-Path $zipFile) { Remove-Item $zipFile}
    Rename-Item -Path $nugetFile -NewName $zipFile -Force
    Expand-Archive -LiteralPath $zipFile  -DestinationPath "$global:pathToWorkingDir\Db" -Force

    Write-Host "     Restoring database"
    $backupLocation = "$global:pathToWorkingDir\Db\"
    $db = @{
        src = "EdFi.Ods.Populated.Template"
        dest = $global:populatedTemplateDatabaseName
    }
    $dataFileDestination = Get-MsSQLDataFileDestination
    $logFileDestination = Get-MsSQLLogFileDestination

    Restore-Database  $db $db.dest $backupLocation $dataFileDestination $logFileDestination
}