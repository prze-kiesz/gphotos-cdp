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
Write-Host "📂 Folder roboczy: $env:USERPROFILE\Desktop" -ForegroundColor Yellow
Write-Host ""

# Check if user is logged in to Google Photos
Write-Host "⚠️  WAŻNE: Przed kontynuowaniem:" -ForegroundColor Yellow
Write-Host "   1. Otwórz Chrome lub Edge" -ForegroundColor White
Write-Host "   2. Zaloguj się do https://photos.google.com" -ForegroundColor White
Write-Host "   3. Poczekaj aż strona się załaduje" -ForegroundColor White
Write-Host "   4. Wróć tutaj i naciśnij Enter" -ForegroundColor White
Write-Host ""
Read-Host "Naciśnij Enter gdy będziesz zalogowany"
Write-Host ""

# Remove old folder if exists
if (Test-Path "chrome-profile") {
    Write-Host "🗑️  Usuwam stary folder chrome-profile..." -ForegroundColor Gray
    Remove-Item "chrome-profile" -Recurse -Force
}

# Create directory structure
Write-Host "📁 Tworzę strukturę folderów..." -ForegroundColor Green
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
    Write-Host "❌ BŁĄD: Nie znaleziono profilu Chrome ani Edge!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Sprawdź czy masz zainstalowanego:" -ForegroundColor Yellow
    Write-Host "  - Google Chrome (https://www.google.com/chrome/)" -ForegroundColor White
    Write-Host "  - Microsoft Edge (wbudowany w Windows 10/11)" -ForegroundColor White
    Write-Host ""
    Read-Host "Naciśnij Enter aby zakończyć"
    exit 1
}

Write-Host "✅ Znaleziono profil: $BrowserName" -ForegroundColor Green
Write-Host "   Lokalizacja: $ChromeProfile" -ForegroundColor Gray
Write-Host ""

# Close browser warning
Write-Host "⚠️  UWAGA: Teraz zamknij całkowicie $BrowserName" -ForegroundColor Yellow
Write-Host "   (w zasobniku systemowym kliknij PPM → Exit)" -ForegroundColor White
Write-Host ""
Read-Host "Naciśnij Enter gdy zamkniesz przeglądarkę"
Write-Host ""

# Copy important folders
Write-Host "📋 Kopiuję dane profilu..." -ForegroundColor Green
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
            Write-Host "     ⚠ Nie udało się skopiować (może być zablokowany)" -ForegroundColor Yellow
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
            Write-Host "     ⚠ Nie udało się skopiować" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
if ($copiedCount -eq 0) {
    Write-Host "❌ BŁĄD: Nie skopiowano żadnych plików!" -ForegroundColor Red
    Write-Host "   $BrowserName może być wciąż uruchomiony." -ForegroundColor Yellow
    Write-Host "   Zamknij przeglądarkę całkowicie i spróbuj ponownie." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Naciśnij Enter aby zakończyć"
    exit 1
}

Write-Host "✅ Skopiowano $copiedCount elementów!" -ForegroundColor Green
Write-Host ""

# Create ZIP file
Write-Host "📦 Pakuję do pliku ZIP..." -ForegroundColor Green
if (Test-Path "chrome-profile.zip") {
    Remove-Item "chrome-profile.zip" -Force
}

try {
    Compress-Archive -Path "chrome-profile" -DestinationPath "chrome-profile.zip" -Force
    $zipSize = (Get-Item "chrome-profile.zip").Length / 1MB
    Write-Host "✅ Utworzono: chrome-profile.zip ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
} catch {
    Write-Host "❌ Nie udało się utworzyć pliku ZIP!" -ForegroundColor Red
    Write-Host "   Błąd: $_" -ForegroundColor Yellow
    Read-Host "Naciśnij Enter aby zakończyć"
    exit 1
}

# Success message
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 SUKCES! Profil został wyeksportowany!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Lokalizacja: $env:USERPROFILE\Desktop\chrome-profile.zip" -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📤 NASTĘPNY KROK: Wyślij plik na serwer" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Metoda 1: SCP (przez PowerShell)" -ForegroundColor White
Write-Host "   ---------------------------------" -ForegroundColor Gray
Write-Host "   scp chrome-profile.zip uzytkownik@serwer:~/workspace/gphotos-cdp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Metoda 2: WinSCP (graficznie)" -ForegroundColor White
Write-Host "   -----------------------------" -ForegroundColor Gray
Write-Host "   1. Pobierz WinSCP: https://winscp.net/" -ForegroundColor Cyan
Write-Host "   2. Połącz się z serwerem" -ForegroundColor Cyan
Write-Host "   3. Przeciągnij chrome-profile.zip do ~/workspace/gphotos-cdp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 NA SERWERZE (po przesłaniu pliku):" -ForegroundColor Yellow
Write-Host ""
Write-Host "   cd ~/workspace/gphotos-cdp" -ForegroundColor Cyan
Write-Host "   unzip -o chrome-profile.zip" -ForegroundColor Cyan
Write-Host "   make learn" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Open Explorer at Desktop
Write-Host "💡 Otwierasz folder Desktop w Explorerze..." -ForegroundColor Gray
Start-Process explorer.exe -ArgumentList "$env:USERPROFILE\Desktop"

Write-Host ""
Read-Host "Naciśnij Enter aby zakończyć"
