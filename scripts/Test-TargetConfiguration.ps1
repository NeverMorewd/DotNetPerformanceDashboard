[CmdletBinding()]
param(
    [Parameter()]
    [string] $Path = "performance-target.json",

    [Parameter()]
    [switch] $WriteGitHubOutput
)

$ErrorActionPreference = "Stop"
$configurationPath = (Resolve-Path -LiteralPath $Path).Path
$configuration = Get-Content -LiteralPath $configurationPath -Raw | ConvertFrom-Json

function Assert-Condition {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw $Message }
}

function Assert-RelativePath {
    param([string] $Value, [string] $Name)
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($Value)) "$Name is required."
    Assert-Condition (-not [IO.Path]::IsPathRooted($Value)) "$Name must be relative."
    $segments = $Value.Replace('\', '/').Split('/', [StringSplitOptions]::RemoveEmptyEntries)
    Assert-Condition (-not ($segments -contains '..')) "$Name cannot traverse outside the target repository."
}

Assert-Condition ($configuration.target.repository -match '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') "target.repository must use owner/name format."
Assert-Condition (-not [string]::IsNullOrWhiteSpace($configuration.target.ref)) "target.ref is required."
Assert-RelativePath $configuration.target.projectPath "target.projectPath"
Assert-Condition (-not [string]::IsNullOrWhiteSpace($configuration.target.reportLabel)) "target.reportLabel is required."

$allowedPlatforms = @('Windows', 'Linux', 'macOS')
$configuredPlatforms = @($configuration.platforms.PSObject.Properties.Name)
Assert-Condition ($configuredPlatforms.Count -gt 0) "At least one platform is required."
foreach ($platform in $configuredPlatforms) {
    Assert-Condition ($allowedPlatforms -contains $platform) "Unsupported platform: $platform."
    $settings = $configuration.platforms.$platform
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($settings.runtimeIdentifier)) "platforms.$platform.runtimeIdentifier is required."
    Assert-RelativePath $settings.executablePath "platforms.$platform.executablePath"
}

foreach ($platform in @($configuration.schedule.platforms)) {
    Assert-Condition ($configuredPlatforms -contains $platform) "Scheduled platform $platform is not configured."
}

$ranges = @(
    @('warmupSeconds', 0, 3600),
    @('measurementSeconds', 5, 86400),
    @('sampleIntervalMilliseconds', 100, 60000),
    @('cooldownSeconds', 0, 600),
    @('iterations', 1, 20),
    @('counterDurationSeconds', 5, 3600),
    @('traceDurationSeconds', 5, 3600),
    @('artifactRetentionDays', 1, 90)
)
foreach ($range in $ranges) {
    $value = $configuration.measurement.($range[0])
    Assert-Condition ($value -is [int] -or $value -is [long]) "measurement.$($range[0]) must be an integer."
    Assert-Condition ($value -ge $range[1] -and $value -le $range[2]) "measurement.$($range[0]) must be from $($range[1]) to $($range[2])."
}

$normalized = $configuration | ConvertTo-Json -Depth 20 -Compress
if ($WriteGitHubOutput) {
    Assert-Condition (-not [string]::IsNullOrWhiteSpace($env:GITHUB_OUTPUT)) "GITHUB_OUTPUT is unavailable."
    Add-Content -LiteralPath $env:GITHUB_OUTPUT -Value "configuration=$normalized" -Encoding utf8
}

Write-Host "Configuration is valid for: $($configuredPlatforms -join ', ')."
