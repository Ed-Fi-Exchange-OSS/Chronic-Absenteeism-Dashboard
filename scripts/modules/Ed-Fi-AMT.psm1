# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

############################################################

# Author: Douglas Loyo, Sr. Solutions Architect @ MSDF

# Description: Module contains functions that support the install of AMT - Analyitcs Middle Tier.

############################################################

function Install-EdFiAMT($connStr) {
    Write-Host "     Downloading AMT"
    $url = "https://github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Analytics-Middle-Tier/releases/download/2.7/EdFi.AnalyticsMiddleTier-win10.x64-2.7.zip"
    $outputpath = "$global:pathToBinaries\EdFi.AnalyticsMiddleTier-win10.x64-2.7.zip"
    Invoke-DownloadFile $url $outputpath

    Write-Host "     Unziping AMT"
    $unzipPath = "$global:pathToWorkingDir\AMT"
    Expand-Archive -LiteralPath $outputpath -DestinationPath $unzipPath -Force

    $pathToAMTInstaller = "$unzipPath\EdFi.AnalyticsMiddleTier.Console.exe"
    #$connStr = "server=.;database=$global:populatedTemplateDatabaseName;integrated security=sspi;"
    $params = "-c '$connStr' -o Indexes RLS EWS CHRAB"
    Write-Host $params
    Invoke-Expression -Command "$pathToAMTInstaller $params"
}