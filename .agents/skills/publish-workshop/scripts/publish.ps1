param (
    [string]$WorkshopId = "3785083246",
    [string]$AppId = "1942280",
    [string]$SteamUser = "rauldmartin",
    [string]$ChangeNote = "v1.0.1: Fix startup crash by adding compatible_game_version for ModLoader v6 and ensuring root mods-unpacked package structure",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

$workspaceRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path
$manifestPath = "$workspaceRoot\mods-unpacked\rauldzmartin-AspectRatio1610\manifest.json"
$previewPath = "$workspaceRoot\preview.jpg"
$distDir = "$workspaceRoot\dist"
$contentDir = "$distDir\content"
$zipName = "rauldzmartin-AspectRatio1610-1.0.0.zip"
$zipPath = "$contentDir\$zipName"
$vdfPath = "$distDir\workshop_item.vdf"

Write-Host "=== Brotato Mod Workshop Publisher ===" -ForegroundColor Cyan
Write-Host "Target Workshop ID: $WorkshopId" -ForegroundColor Yellow

# 1. Validate manifest.json
if (-not (Test-Path $manifestPath)) {
    Write-Error "manifest.json not found at $manifestPath"
    exit 1
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
if (-not $manifest.extra.godot.compatible_game_version -or $manifest.extra.godot.compatible_game_version.Count -eq 0) {
    Write-Error "manifest.json is missing 'compatible_game_version' in extra.godot!"
    exit 1
}
Write-Host "✓ manifest.json validated (Game version: $($manifest.extra.godot.compatible_game_version -join ', '))" -ForegroundColor Green

# 2. Prepare dist directory
if (Test-Path $distDir) {
    Remove-Item $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $contentDir -Force | Out-Null

# 3. Create zip package
Write-Host "Packaging mod..." -ForegroundColor Cyan
Compress-Archive -Path "$workspaceRoot\mods-unpacked" -DestinationPath $zipPath -CompressionLevel Optimal -Force
Copy-Item $zipPath -Destination "$workspaceRoot\$zipName" -Force
Write-Host "✓ Package created: $zipName" -ForegroundColor Green

# 4. Generate VDF file
$vdfContentDir = $contentDir -replace '\\', '\\'
$vdfPreview = $previewPath -replace '\\', '\\'

$descriptionFile = "$workspaceRoot\description.md"
$itemDescription = ""
if (Test-Path $descriptionFile) {
    $descRaw = Get-Content $descriptionFile -Raw
    if ($descRaw -match '(?ms)```bbcode\s*\r?\n(.*?)\r?\n```') {
        $itemDescription = $matches[1] -replace '\\', '\\' -replace '"', '\"'
    }
}

$descField = ""
if (-not [string]::IsNullOrWhiteSpace($itemDescription)) {
    $descField = "`t`"description`"`t`"$itemDescription`""
}

$vdfContent = @"
"workshopitem"
{
	"appid"				"$AppId"
	"publishedfileid"	"$WorkshopId"
	"contentfolder"		"$vdfContentDir"
	"previewfile"		"$vdfPreview"
	"visibility"		"0"
	"title"				"AspectRatio1610 (Steam Deck & 16:10 Fullscreen)"
$descField
	"changenote"		"$ChangeNote"
}
"@

Set-Content -Path $vdfPath -Value $vdfContent -Encoding UTF8
Write-Host "✓ VDF descriptor generated at $vdfPath" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`n[DryRun mode] Skipping SteamCMD upload." -ForegroundColor Yellow
    exit 0
}

# 5. Locate or install SteamCMD
$steamcmdExe = (Get-Command steamcmd.exe -ErrorAction SilentlyContinue).Source

if (-not $steamcmdExe) {
    $localSteamCmdDir = "$env:LOCALAPPDATA\SteamCMD"
    $localSteamCmd = "$localSteamCmdDir\steamcmd.exe"

    if (Test-Path $localSteamCmd) {
        $steamcmdExe = $localSteamCmd
    } else {
        Write-Host "SteamCMD not found. Downloading official SteamCMD portable..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $localSteamCmdDir -Force | Out-Null
        $tempZip = "$localSteamCmdDir\steamcmd.zip"
        Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $tempZip
        Expand-Archive -Path $tempZip -DestinationPath $localSteamCmdDir -Force
        Remove-Item $tempZip -Force
        $steamcmdExe = $localSteamCmd
        Write-Host "✓ SteamCMD downloaded to $steamcmdExe" -ForegroundColor Green
    }
}

Write-Host "`nUsing SteamCMD: $steamcmdExe" -ForegroundColor Cyan

# 6. Execute Upload
if ([string]::IsNullOrWhiteSpace($SteamUser)) {
    $autoUser = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "AutoLoginUser" -ErrorAction SilentlyContinue).AutoLoginUser
    if (-not [string]::IsNullOrWhiteSpace($autoUser)) {
        $SteamUser = $autoUser
    } else {
        $SteamUser = "rauldmartin"
    }
}

Write-Host "`nIniciando subida a Steam Workshop (Item ID: $WorkshopId)..." -ForegroundColor Cyan
& $steamcmdExe +login $SteamUser +workshop_build_item "$vdfPath" +quit

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ ¡Mod actualizado con éxito en Steam Workshop!" -ForegroundColor Green
    Write-Host "URL: https://steamcommunity.com/sharedfiles/filedetails/?id=$WorkshopId" -ForegroundColor Cyan
} else {
    Write-Host "`nAdvertencia: SteamCMD finalizó con código $LASTEXITCODE. Verifique los logs si hubo algún error de autenticación o Steam Guard." -ForegroundColor Yellow
}

# 7. Automated GitHub Release Creation & Asset Upload
try {
    $versionTag = "v$($manifest.version_number)"
    Write-Host "`n=== Creando / Sincronizando Release en GitHub ($versionTag) ===" -ForegroundColor Cyan
    
    # Get token from Git Credential Manager
    $credInput = "protocol=https`nhost=github.com`n`n"
    $credOutput = $credInput | git credential fill
    $ghToken = ($credOutput | Where-Object { $_ -match '^password=(.+)$' } | ForEach-Object { $matches[1] })

    if (-not [string]::IsNullOrWhiteSpace($ghToken)) {
        $ghHeaders = @{
            "Authorization" = "Bearer $ghToken"
            "Accept" = "application/vnd.github+json"
            "User-Agent" = "Brotato-Release-Automation"
        }

        # Check if release exists
        $repoApi = "https://api.github.com/repos/rauldzmartin/Brotato-AspectRatio1610"
        $existingRelease = $null
        try {
            $existingRelease = Invoke-RestMethod -Uri "$repoApi/releases/tags/$versionTag" -Method Get -Headers $ghHeaders -ErrorAction SilentlyContinue
        } catch {}

        if (-not $existingRelease) {
            $relBody = @{
                tag_name = $versionTag
                target_commitish = "main"
                name = "${versionTag}: AspectRatio1610 (Steam Deck & 16:10 Fullscreen)"
                body = "### Changes in ${versionTag}`n`n$ChangeNote`n`n### Installation:`n- **Steam Workshop:** [Subscribe on Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=$WorkshopId)`n- **Manual:** Extract `${zipName}` into your Brotato `mods-unpacked/` directory."
                draft = $false
                prerelease = $false
            } | ConvertTo-Json

            $releaseObj = Invoke-RestMethod -Uri "$repoApi/releases" -Method Post -Headers $ghHeaders -Body $relBody -ContentType "application/json"
            Write-Host "✓ GitHub Release creada: $($releaseObj.html_url)" -ForegroundColor Green

            # Upload zip asset
            $zipBytes = [System.IO.File]::ReadAllBytes($zipPath)
            $uploadUri = "$($releaseObj.upload_url -replace '\{\?name,label\}', '')?name=$zipName"
            $uploadHeaders = @{
                "Authorization" = "Bearer $ghToken"
                "Accept" = "application/vnd.github+json"
                "Content-Type" = "application/zip"
                "User-Agent" = "Brotato-Release-Automation"
            }
            $assetObj = Invoke-RestMethod -Uri $uploadUri -Method Post -Headers $uploadHeaders -Body $zipBytes
            Write-Host "✓ Zip subido a GitHub Release: $($assetObj.browser_download_url)" -ForegroundColor Green
        } else {
            Write-Host "✓ GitHub Release ya existe para ${versionTag}: $($existingRelease.html_url)" -ForegroundColor Green
        }
    } else {
        Write-Host "Nota: No se pudo obtener el token de Git para crear la release en GitHub de forma automática." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Aviso: Error durante la creación de la release en GitHub: $_" -ForegroundColor Yellow
}

