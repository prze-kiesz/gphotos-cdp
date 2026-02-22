# 🌐 Chrome Remote Debugging - Quick Start

## Cel

Uruchom Chrome w Dockerze na serwerze i podłącz się do niego z przeglądarki na swoim komputerze.

---

## Szybki Start (3 minuty)

### Krok 1: Uruchom Chrome na serwerze

```bash
cd ~/workspace/gphotos-cdp

# Uruchom Chrome w trybie remote debugging
./chrome-debug.sh
```

### Krok 2: Połącz się z lokalnej przeglądarki

Na swoim komputerze (Windows/Mac/Linux):

1. **Otwórz Chrome lub Edge**
2. **Wejdź na:** `chrome://inspect/#devices`
3. **Kliknij "Configure..."** obok "Discover network targets"
4. **Dodaj:** `YOUR_SERVER_IP:9222` (zamień YOUR_SERVER_IP na IP serwera)
5. **Kliknij "Done"**
6. **Poczekaj chwilę** - pojawi się "Remote Target"
7. **Kliknij "inspect"** - otworzy się DevTools podłączony do Chrome na serwerze

---

## Diagram

```
┌─────────────────────┐         port 9222         ┌──────────────────┐
│  Twój Komputer      │ ◄──────────────────────► │   Server Docker   │
│                     │                           │                   │
│  Chrome DevTools    │      SSH tunnel lub       │  Chrome Headless  │
│  chrome://inspect   │      bezpośrednie TCP     │  (remote debug)   │
└─────────────────────┘                           └──────────────────┘
```

---

## Zaawansowane: SSH Tunnel (jeśli port 9222 jest zamknięty)

Jeśli nie możesz połączyć się bezpośrednio przez port 9222, użyj SSH tunnel:

```bash
# Na swoim komputerze
ssh -L 9222:localhost:9222 user@YOUR_SERVER_IP

# Pozostaw to okno otwarte, a w przeglądarce połącz się z localhost:9222
```

Potem w `chrome://inspect/#devices` dodaj: `localhost:9222`

---

## Sprawdzanie czy Chrome działa

### Na serwerze:

```bash
# Sprawdź czy kontener działa
docker ps | grep chrome-debug

# Sprawdź logi
docker-compose logs -f chrome-debug

# Test API
curl http://localhost:9222/json/version
```

Powinieneś zobaczyć JSON z informacjami o Chrome.

### Na swoim komputerze:

Otwórz w przeglądarce: `http://YOUR_SERVER_IP:9222/json`

Powinieneś zobaczyć listę otwartych kart w formacie JSON.

---

## Przykładowe użycie

### 1. Otwórz Google Photos

Po połączeniu przez DevTools, w konsoli wpisz:

```javascript
window.location.href = 'https://photos.google.com';
```

### 2. Logowanie

Możesz ręcznie zalogować się przez DevTools - wszystko jest zapisywane w `./chrome-profile`.

### 3. Testowanie selektorów

W konsoli DevTools możesz testować selektory używane przez gphotos-cdp:

```javascript
// Test czy znajduje przyciski
document.querySelectorAll('button[aria-label]');

// Test czy znajduje obrazki
document.querySelectorAll('img[src*="googleusercontent"]');
```

---

## Zarządzanie

### Uruchomienie

```bash
# Tylko Chrome debug
./chrome-debug.sh

# Lub ręcznie
docker-compose up -d chrome-debug
```

### Zatrzymanie

```bash
# Zatrzymaj Chrome
docker-compose stop chrome-debug

# Usuń kontener
docker-compose down chrome-debug
```

### Restart

```bash
docker-compose restart chrome-debug
```

### Logi

```bash
# Cała historia
docker-compose logs chrome-debug

# Na żywo (Ctrl+C aby wyjść)
docker-compose logs -f chrome-debug
```

---

## Troubleshooting

### Problem: "Port 9222 already in use"

**Rozwiązanie:**
```bash
# Znajdź proces
sudo lsof -i :9222

# Zatrzymaj stary kontener
docker-compose stop chrome-debug
docker-compose down
```

### Problem: "Connection refused"

**Rozwiązanie 1:** Sprawdź firewall
```bash
# Otwórz port 9222
sudo ufw allow 9222/tcp
```

**Rozwiązanie 2:** Użyj SSH tunnel
```bash
ssh -L 9222:localhost:9222 user@server
```

### Problem: "Remote Target nie pojawia się"

**Rozwiązanie:**
1. Sprawdź czy Chrome działa: `curl http://localhost:9222/json`
2. Sprawdź logi: `docker-compose logs chrome-debug`
3. Restart: `docker-compose restart chrome-debug`
4. Poczekaj 10-20 sekund po dodaniu w chrome://inspect

### Problem: "Cannot connect to Docker daemon"

**Rozwiązanie:**
```bash
# Sprawdź czy Docker działa
sudo systemctl status docker

# Uruchom Docker
sudo systemctl start docker
```

---

## Konfiguracja

### Zmiana portu

Edytuj [docker-compose.yml](docker-compose.yml):

```yaml
chrome-debug:
  ports:
    - "9999:9222"  # Zmień 9999 na dowolny port
```

### Zwiększenie pamięci

W [docker-compose.yml](docker-compose.yml):

```yaml
chrome-debug:
  shm_size: '4gb'  # Więcej shared memory
  deploy:
    resources:
      limits:
        memory: 4G  # Więcej RAM
```

---

## Bezpieczeństwo

⚠️ **UWAGA:** Port 9222 daje pełny dostęp do przeglądarki!

### Zalecenia:

1. **Używaj SSH tunnel** zamiast otwierać port publicznie
2. **Firewall:** Ogranicz dostęp tylko do zaufanych IP
3. **VPN/Tailscale:** Jeszcze lepsze rozwiązanie

### Przykład konfiguracji firewall:

```bash
# Zablokuj port 9222 dla wszystkich
sudo ufw deny 9222/tcp

# Pozwól tylko z Twojego IP
sudo ufw allow from YOUR_HOME_IP to any port 9222 proto tcp
```

---

## Kolejne kroki

Po połączeniu Chrome przez remote debugging:

1. ✅ Zaloguj się do Google Photos ręcznie przez DevTools
2. ✅ Sesja zapisze się w `./chrome-profile`
3. 🔜 Następnie zaimplementujemy automatyczne zarządzanie cookies
4. 🔜 Ostatecznie: automatyczne logowanie bez kopiowania profilu

---

## API Endpoints

Chrome DevTools Protocol dostępne endpointy:

- `http://localhost:9222/json` - Lista kart
- `http://localhost:9222/json/version` - Wersja Chrome
- `http://localhost:9222/json/protocol` - Protocol description
- `http://localhost:9222/devtools/inspector.html` - Web-based DevTools

---

## Przydatne komendy

```bash
# Status wszystkich kontenerów
docker-compose ps

# Użycie zasobów
docker stats chrome-debug

# Wejdź do kontenera (debugging)
docker exec -it chrome-debug bash

# Sprawdź czy Chrome działa wewnątrz kontenera
docker exec chrome-debug curl http://localhost:9222/json/version

# Wyczyść profile (UWAGA: usunie sesję!)
rm -rf chrome-profile/*

# Rebuild obrazu
docker-compose build chrome-debug
docker-compose up -d chrome-debug
```

---

## FAQ

**Q: Czy to bezpieczne?**
A: Tylko jeśli ograniczysz dostęp do portu 9222. Najlepiej używaj SSH tunnel.

**Q: Czy mogę używać tego jednocześnie z gphotos-cdp?**
A: Tak! To są oddzielne kontenery. Chrome-debug służy do testowania/logowania, gphotos-cdp do pobierania.

**Q: Czy sesja zostanie zachowana?**
A: Tak, wszystko zapisuje się w `./chrome-profile`.

**Q: Jak wyłączyć headless mode (żeby zobaczyć GUI)?**
A: To wymaga X11 forwarding lub VNC. Chrome-debug działa w headless, ale DevTools dają Ci pełną kontrolę.

**Q: Czy mogę otworzyć wiele kart?**
A: Tak, przez API lub DevTools możesz sterować wszystkimi aspektami przeglądarki.

---

## Przykłady użycia API

### Otwórz nową kartę

```bash
curl http://localhost:9222/json/new?https://photos.google.com
```

### Zamknij kartę

```bash
# Pobierz ID karty
curl http://localhost:9222/json

# Zamknij kartę (zamień ID)
curl -X DELETE http://localhost:9222/json/close/TAB_ID_HERE
```

### Aktywuj kartę

```bash
curl http://localhost:9222/json/activate/TAB_ID_HERE
```

---

**Gotowe!** Teraz możesz sterować Chrome na serwerze z przeglądarki na swoim komputerze 🎉
