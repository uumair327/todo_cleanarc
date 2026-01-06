# Color validation script for Windows PowerShell
# This script provides a convenient way to run color validation
# with common configurations for different environments.

param(
    [switch]$IncludeTests,
    [switch]$Json,
    [switch]$NoFail,
    [string]$Output = "",
    [string]$Root = ".",
    [switch]$Verbose,
    [switch]$CI,
    [switch]$Dev,
    [switch]$PreCommit,
    [switch]$Help
)

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to show help
function Show-Help {
    Write-Host @"
Color Validation Script

Usage: .\validate_colors.ps1 [options]

Options:
    -IncludeTests          Include test files in validation
    -Json                  Output results in JSON format
    -NoFail                Don't fail on violations (warning mode)
    -Output <file>         Write results to file
    -Root <path>           Root path to scan (default: current directory)
    -Verbose               Verbose output
    -Help                  Show this help message

Presets:
    -CI                    CI/CD mode (JSON output, fail on violations)
    -Dev                   Development mode (text output, no fail)
    -PreCommit             Pre-commit mode (text output, fail on violations)

Examples:
    .\validate_colors.ps1                                    # Basic validation
    .\validate_colors.ps1 -CI -Output violations.json       # CI/CD pipeline
    .\validate_colors.ps1 -Dev -IncludeTests               # Development with tests
    .\validate_colors.ps1 -PreCommit                        # Pre-commit hook
"@
}

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Apply presets
if ($CI) {
    $Json = $true
    $NoFail = $false
}

if ($Dev) {
    $Json = $false
    $NoFail = $true
    $IncludeTests = $true
}

if ($PreCommit) {
    $Json = $false
    $NoFail = $false
}

# Build dart command arguments
$DartArgs = @()

if ($IncludeTests) {
    $DartArgs += "--include-tests"
}

if ($Json) {
    $DartArgs += "--json"
}

if ($NoFail) {
    $DartArgs += "--no-fail"
}

if ($Output) {
    $DartArgs += "--output", $Output
}

if ($Root -ne ".") {
    $DartArgs += "--root", $Root
}

# Check if Dart is available
try {
    $null = Get-Command dart -ErrorAction Stop
} catch {
    Write-ColorOutput "Error: Dart is not installed or not in PATH" "Red"
    exit 1
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DartScript = Join-Path $ScriptDir "validate_colors.dart"

# Check if the Dart script exists
if (-not (Test-Path $DartScript)) {
    Write-ColorOutput "Error: Dart validation script not found at $DartScript" "Red"
    exit 1
}

# Print configuration if verbose
if ($Verbose) {
    Write-ColorOutput "Configuration:" "Blue"
    Write-Host "  Root path: $Root"
    Write-Host "  Include tests: $IncludeTests"
    Write-Host "  JSON output: $Json"
    Write-Host "  Fail on violations: $(-not $NoFail)"
    Write-Host "  Output file: $(if ($Output) { $Output } else { 'stdout' })"
    Write-Host "  Dart args: $($DartArgs -join ' ')"
    Write-Host
}

# Run the validation
Write-ColorOutput "Running color validation..." "Blue"

try {
    $process = Start-Process -FilePath "dart" -ArgumentList (@($DartScript) + $DartArgs) -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        if (-not $Json) {
            Write-ColorOutput "Color validation completed successfully!" "Green"
        }
        exit 0
    } else {
        if (-not $Json) {
            if ($process.ExitCode -eq 1) {
                Write-ColorOutput "Color validation failed - hardcoded colors found!" "Red"
            } else {
                Write-ColorOutput "Color validation error (exit code: $($process.ExitCode))" "Red"
            }
        }
        exit $process.ExitCode
    }
} catch {
    Write-ColorOutput "Error running color validation: $($_.Exception.Message)" "Red"
    exit 2
}