#!/bin/bash
# Remote Chrome authentication helper for servers without GUI
# This script runs Chrome with remote debugging enabled

set -e

REMOTE_PORT=9222
LOCAL_PORT=9222

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║    🌐 Remote Chrome Authentication - Headless Server         ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Ten skrypt uruchomi Chrome z remote debugging."
echo "Będziesz mógł zalogować się przez lokalną przeglądarkę!"
echo ""

# Create directories
mkdir -p chrome-profile photos

# Build if needed
if ! docker images | grep -q "gphotos-cdp-gphotos-cdp"; then
    echo "🔨 Buduję Docker image..."
    docker-compose build
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📡 KROK 1: Uruchamiam Chrome z remote debugging..."
echo ""
echo "Chrome będzie dostępny na porcie $REMOTE_PORT"
echo ""

# Start Chrome with remote debugging in Docker container
# We'll use gphotos-cdp itself with special flags
docker run -d \
    --name gphotos-auth \
    --rm \
    -p ${REMOTE_PORT}:${REMOTE_PORT} \
    -v "$(pwd)/chrome-profile:/data/profile" \
    -v "$(pwd)/photos:/data/photos" \
    gphotos-cdp-gphotos-cdp \
    /usr/bin/chromium \
        --remote-debugging-address=0.0.0.0 \
        --remote-debugging-port=${REMOTE_PORT} \
        --user-data-dir=/data/profile \
        --no-first-run \
        --no-default-browser-check \
        --disable-dev-shm-usage \
        --no-sandbox \
        https://photos.google.com

sleep 3

# Check if container is running
if ! docker ps | grep -q gphotos-auth; then
    echo "❌ Błąd: Nie udało się uruchomić Chrome"
    exit 1
fi

echo "✅ Chrome uruchomiony!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📡 KROK 2: Połącz się z Chrome z lokalnej maszyny"
echo ""
echo "Na swojej LOKALNEJ maszynie (w nowym terminalu) uruchom:"
echo ""
echo "  ssh -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} $(whoami)@$(hostname)"
echo ""
echo "Jeśli to nie działa, użyj pełnego DNS/IP:"
echo ""
echo "  ssh -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} $(whoami)@<IP_SERWERA>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 KROK 3: Otwórz w lokalnej przeglądarce"
echo ""
echo "Po utworzeniu SSH tunnelu otwórz w przeglądarce:"
echo ""
echo "  http://localhost:${LOCAL_PORT}"
echo ""
echo "Zobaczysz listę zakładek Chrome. Kliknij w link do Google Photos."
echo "Zaloguj się do swojego konta Google."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ KROK 4: Zatrzymanie po zalogowaniu"
echo ""
echo "Po zalogowaniu się do Google Photos:"
echo "1. Wróć tutaj"
echo "2. Naciśnij Enter aby zatrzymać Chrome"
echo ""
echo "Profile zostanie zapisany w chrome-profile/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Naciśnij Enter po zalogowaniu się przez przeglądarkę... " 

# Stop container
echo ""
echo "Zatrzymuję Chrome..."
docker stop gphotos-auth 2>/dev/null || true

# Check if profile was created
if [ -d "chrome-profile/Default" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🎉 Autoryzacja zakończona pomyślnie!"
    echo ""
    echo "Profile zapisany w: chrome-profile/"
    echo ""
    echo "Teraz możesz uruchomić learning mode:"
    echo ""
    echo "  make learn"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
else
    echo ""
    echo "⚠️  Uwaga: chrome-profile/Default nie został utworzony"
    echo ""
    echo "Możliwe przyczyny:"
    echo "- Nie udało się zalogować"
    echo "- Za szybko zatrzymano Chrome"
    echo ""
    echo "Spróbuj ponownie i upewnij się, że:"
    echo "1. SSH tunnel jest aktywny"
    echo "2. Zalogowałeś się do Google Photos"
    echo "3. Poczekałeś kilka sekund przed zatrzymaniem"
    echo ""
fi
