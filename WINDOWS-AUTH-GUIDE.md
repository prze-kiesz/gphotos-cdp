# 🪟 Logowanie do Google Photos - Instrukcja dla Windows

## Szybki Start (5 minut)

### Krok 1: Zaloguj się do Google Photos na Windows

1. Otwórz **Chrome** lub **Edge** na swoim Windows
2. Wejdź na: https://photos.google.com
3. Zaloguj się do swojego konta Google
4. Poczekaj aż strona się załaduje (zobaczysz swoje zdjęcia)
5. **Zostaw przeglądarkę otwartą** (nie wylogowuj się!)

---

### Krok 2: Znajdź Chrome Profile

Otwórz **PowerShell** (Windows + R, wpisz `powershell`, Enter) i wykonaj:

```powershell
# Przejdź do folderu Desktop
cd $env:USERPROFILE\Desktop

# Utwórz folder na profile
New-Item -ItemType Directory -Force -Path chrome-profile\Default

# Skopiuj potrzebne pliki z Chrome
$ChromeProfile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"

# Kopiuj cookies i session
Copy-Item "$ChromeProfile\Cookies" -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$ChromeProfile\Network" -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$ChromeProfile\Local Storage" -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$ChromeProfile\Session Storage" -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$ChromeProfile\IndexedDB" -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✅ Profile skopiowany do Desktop\chrome-profile"
```

**Alternatywa:** Jeśli używasz **Edge** zamiast Chrome:
```powershell
$ChromeProfile = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
# ... reszta tak samo
```

---

### Krok 3: Zapakuj folder

W PowerShell:

```powershell
# Zapakuj do ZIP (Windows ma wbudowaną kompresję)
Compress-Archive -Path "chrome-profile" -DestinationPath "chrome-profile.zip" -Force

Write-Host "✅ Utworzono chrome-profile.zip na Desktop"
```

---

### Krok 4: Wyślij na serwer

#### Opcja A: SCP przez PowerShell (jeśli masz OpenSSH)

```powershell
# Zamień 'przemek' i 'twoj-serwer' na swoje dane
scp chrome-profile.zip przemek@twoj-serwer:~/workspace/gphotos-cdp/
```

#### Opcja B: WinSCP (jeśli masz zainstalowane)

1. Otwórz **WinSCP**
2. Połącz się z serwerem
3. Przeciągnij `chrome-profile.zip` z Desktop na serwer do folderu `~/workspace/gphotos-cdp/`

#### Opcja C: Przez WSL (jeśli masz WSL)

```bash
# W WSL terminal
cd /mnt/c/Users/TWOJ_USERNAME/Desktop
scp chrome-profile.zip przemek@twoj-serwer:~/workspace/gphotos-cdp/
```

---

### Krok 5: Rozpakuj na serwerze

Wróć do sesji SSH na serwerze i wykonaj:

```bash
cd ~/workspace/gphotos-cdp

# Rozpakuj ZIP
unzip -o chrome-profile.zip

# Sprawdź czy się udało
ls -la chrome-profile/Default/

# Jeśli widzisz pliki (Cookies, Network, etc.) - sukces! ✅
```

---

### Krok 6: Testuj!

```bash
# Uruchom learning mode
make learn
```

---

## 🎯 Kompletny Skrypt PowerShell

Zapisz to jako `copy-chrome-profile.ps1` na Desktop:

```powershell
# Script to copy Chrome profile for gphotos-cdp
# Usage: Right-click -> Run with PowerShell

Write-Host "╔═══════════════════════════════════════════════════════╗"
Write-Host "║  Chrome Profile Export for gphotos-cdp               ║"
Write-Host "╚═══════════════════════════════════════════════════════╝"
Write-Host ""

# Przejdź do Desktop
Set-Location "$env:USERPROFILE\Desktop"

# Usuń stary folder jeśli istnieje
if (Test-Path "chrome-profile") {
    Remove-Item "chrome-profile" -Recurse -Force
}

# Utwórz strukturę
New-Item -ItemType Directory -Force -Path "chrome-profile\Default" | Out-Null

# Znajdź Chrome profile
$ChromeProfile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
if (-not (Test-Path $ChromeProfile)) {
    $ChromeProfile = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    Write-Host "📌 Używam Edge profile"
} else {
    Write-Host "📌 Używam Chrome profile"
}

if (-not (Test-Path $ChromeProfile)) {
    Write-Host "❌ Nie znaleziono Chrome/Edge profile!"
    Write-Host "   Sprawdź czy masz zainstalowanego Chrome lub Edge"
    pause
    exit 1
}

Write-Host "📂 Kopiuję pliki z: $ChromeProfile"
Write-Host ""

# Kopiuj ważne foldery
$folders = @("Cookies", "Network", "Local Storage", "Session Storage", "IndexedDB", "WebStorage")
foreach ($folder in $folders) {
    $source = Join-Path $ChromeProfile $folder
    if (Test-Path $source) {
        Write-Host "   ✓ Kopiuję: $folder"
        Copy-Item $source -Destination "chrome-profile\Default\" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Kopiuj pojedyncze pliki
$files = @("Cookies", "Cookies-journal", "Preferences", "Secure Preferences")
foreach ($file in $files) {
    $source = Join-Path $ChromeProfile $file
    if (Test-Path $source) {
        Write-Host "   ✓ Kopiuję: $file"
        Copy-Item $source -Destination "chrome-profile\Default\" -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "✅ Profile skopiowany!"
Write-Host ""

# Zapakuj
Write-Host "📦 Pakuję do ZIP..."
if (Test-Path "chrome-profile.zip") {
    Remove-Item "chrome-profile.zip" -Force
}
Compress-Archive -Path "chrome-profile" -DestinationPath "chrome-profile.zip" -Force

$zipSize = (Get-Item "chrome-profile.zip").Length / 1MB
Write-Host "✅ Utworzono: chrome-profile.zip ($([math]::Round($zipSize, 2)) MB)"
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""
Write-Host "📤 NASTĘPNY KROK:"
Write-Host ""
Write-Host "   Wyślij plik na serwer:"
Write-Host "   scp chrome-profile.zip user@serwer:~/workspace/gphotos-cdp/"
Write-Host ""
Write-Host "   Lub użyj WinSCP / FileZilla"
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

pause
```

---

## 🚨 Rozwiązywanie Problemów

### Problem: "Access Denied" podczas kopiowania

**Rozwiązanie:** Zamknij Chrome/Edge całkowicie przed uruchomieniem skryptu:
- Kliknij PPM na ikonie Chrome w zasobniku systemowym → Exit
- Lub w Task Managerze zakończ wszystkie procesy Chrome/Edge

### Problem: "Chrome profile nie działa na serwerze"

**Rozwiązanie:** Upewnij się że:
1. Jesteś zalogowany do Google Photos w przeglądarce
2. Skopiowałeś folder całkowicie (zejrzyj czy masz pliki w chrome-profile/Default/)
3. Na serwerze folder nazywa się dokładnie `chrome-profile` (nie `chrome-profile.zip`)

### Problem: "Nie mogę wysłać pliku przez SCP"

**Rozwiązanie:** Użyj WinSCP (darmowy):
1. Pobierz: https://winscp.net/
2. Zainstaluj
3. Połącz się z serwerem
4. Przeciągnij `chrome-profile.zip` z Desktop na serwer

---

## ✅ Weryfikacja

Po rozpakowaniu na serwerze, sprawdź:

```bash
# Powinno pokazać: Cookies, Network, Local Storage, etc.
ls chrome-profile/Default/

# Sprawdź rozmiar (powinno być kilka MB minimum)
du -sh chrome-profile/

# Test: Uruchom learning mode
make learn
```

---

**Gotowe!** Teraz możesz używać learning mode na serwerze z Twoim profilem Google! 🎉
