param(
    [Parameter(Mandatory = $true)][string]$ApiBaseUrl,
    [string]$Version = '1.0.0',
    [int]$BuildNumber = 1
)
$ErrorActionPreference = 'Stop'
$taskApiUri = [Uri]$ApiBaseUrl
if ($taskApiUri.Scheme -ne 'https' -or -not $taskApiUri.AbsolutePath.TrimEnd('/').EndsWith('/api/v1')) {
    throw 'Fournir une URL HTTPS se terminant par /api/v1.'
}
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskProperties = Join-Path $taskRoot 'mobile/android/key.properties'
if (-not (Test-Path -LiteralPath $taskProperties)) { throw 'Créer la configuration de signature suivant docs/APK.md.' }
Push-Location (Join-Path $taskRoot 'mobile')
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dépendances Flutter en échec.' }
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Analyse Flutter en échec.' }
    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Tests Flutter en échec.' }
    flutter build apk --release "--dart-define=API_BASE_URL=$ApiBaseUrl" "--build-name=$Version" "--build-number=$BuildNumber"
    if ($LASTEXITCODE -ne 0) { throw 'Compilation Android en échec.' }
    $taskApk = Join-Path $taskRoot 'mobile/build/app/outputs/flutter-apk/app-release.apk'
    Get-FileHash -Algorithm SHA256 -LiteralPath $taskApk
    Write-Output "APK signé : $taskApk"
} finally { Pop-Location }
