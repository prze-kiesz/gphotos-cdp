# Chrome Profile Export Script for gphotos-cdp
# Save this as: copy-chrome-profile.ps1
# Right-click and select "Run with PowerShell"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "║     Chrome Profile Export for gphotos-cdp                    ║" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Change to Desktop
Set-Location "$env:USERPROFILE\Desktop"
Write-Host "Working directory: $env:USERPROFILE\Desktop" -ForegroundColor Yellow
Write-Host ""

# Check if user is logged in to Google Photos
Write-Host "WARNING: Before continuing:" -ForegroundColor Yellow
Write-Host "   1. Open Chrome or Edge" -ForegroundColor White
Write-Host "   2. Login to https://photos.google.com" -ForegroundColor White
Write-Host "   3. Wait for the page to load" -ForegroundColor White
Write-Host "   4. Come back here and press Enter" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter when you are logged in"
Write-Host ""

# Remove old folder if exists
if (Test-Path "chrome-profile") {
    Write-Host "Removing old chrome-profile folder..." -ForegroundColor Gray
    Remove-Item "chrome-profile" -Recurse -Force
}

# Create directory structure
Write-Host "Creating folder structure..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path "chrome-profile\Default" | Out-Null

# Find Chrome/Edge profile
$ChromeProfile = ""
$BrowserName = ""

if (Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default") {
    $ChromeProfile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
    $BrowserName = "Chrome"
} elseif (Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default") {
    $ChromeProfile = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    $BrowserName = "Edge"
} else {
    Write-Host ""
    Write-Host "ERROR: Chrome/Edge profile not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install one of:" -ForegroundColor Yellow
    Write-Host "  - Google Chrome (https://www.google.com/chrome/)" -ForegroundColor White
    Write-Host "  - Microsoft Edge (built-in Windows 10/11)" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found profile: $BrowserName" -ForegroundColor Green
Write-Host "   Location: $ChromeProfile" -ForegroundColor Gray
Write-Host ""

# Close browser warning
Write-Host "WARNING: Now close $BrowserName completely" -ForegroundColor Yellow
Write-Host "   (Right-click in system tray -> Exit)" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter when browser is closed"
Write-Host ""

# Copy important folders
Write-Host "Copying profile data..." -ForegroundColor Green
Write-Host ""

$folders = @("Network", "Local Storage", "Session Storage", "IndexedDB", "WebStorage", "GPUCache")
$copiedCount = 0

foreach ($folder in $folders) {
    $source = Join-Path $ChromeProfile $folder
    if (Test-Path $source) {
        Write-Host "   ✓ $folder" -ForegroundColor Gray
        try {
            Copy-Item $source -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
            $copiedCount++
        } catch {
            Write-Host "     WARNING: Could not copy (may be locked)" -ForegroundColor Yellow
        }
    }
}

# Copy individual files (most important!)
$files = @("Cookies", "Cookies-journal", "Preferences", "Secure Preferences", "Login Data", "Web Data")
foreach ($file in $files) {
    $source = Join-Path $ChromeProfile $file
    if (Test-Path $source) {
        Write-Host "   ✓ $file" -ForegroundColor Gray
        try {
            Copy-Item $source -Destination "chrome-profile\Default\" -Force -ErrorAction SilentlyContinue
            $copiedCount++
        } catch {
            Write-Host "     WARNING: Could not copy" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
if ($copiedCount -eq 0) {
    Write-Host "ERROR: No files were copied!" -ForegroundColor Red
    Write-Host "   $BrowserName may still be running." -ForegroundColor Yellow
    Write-Host "   Close the browser completely and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Successfully copied $copiedCount items!" -ForegroundColor Green
Write-Host ""

# Create ZIP file
Write-Host "Creating ZIP file..." -ForegroundColor Green
if (Test-Path "chrome-profile.zip") {
    Remove-Item "chrome-profile.zip" -Force
}

try {
    Compress-Archive -Path "chrome-profile" -DestinationPath "chrome-profile.zip" -Force
    $zipSize = (Get-Item "chrome-profile.zip").Length / 1MB
    Write-Host "Created: chrome-profile.zip ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Could not create ZIP file!" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Success message
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUCCESS! Profile exported!" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $env:USERPROFILE\Desktop\chrome-profile.zip" -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEP: Upload file to server" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Method 1: SCP (via PowerShell)" -ForegroundColor White
Write-Host "   -------------------------------" -ForegroundColor Gray
Write-Host "   scp chrome-profile.zip user@server:~/workspace/gphotos-cdp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Method 2: WinSCP (GUI)" -ForegroundColor White
Write-Host "   ----------------------" -ForegroundColor Gray
Write-Host "   1. Download WinSCP: https://winscp.net/" -ForegroundColor Cyan
Write-Host "   2. Connect to server" -ForegroundColor Cyan
Write-Host "   3. Drag chrome-profile.zip to ~/workspace/gphotos-cdp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "ON SERVER (after upload):" -ForegroundColor Yellow
Write-Host ""
Write-Host "   cd ~/workspace/gphotos-cdp" -ForegroundColor Cyan
Write-Host "   unzip -o chrome-profile.zip" -ForegroundColor Cyan
Write-Host "   make learn" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Open Explorer at Desktop
Write-Host "Opening Desktop folder in Explorer..." -ForegroundColor Gray
Start-Process explorer.exe -ArgumentList "$env:USERPROFILE\Desktop"

Write-Host ""
Read-Host "Press Enter to exit"
