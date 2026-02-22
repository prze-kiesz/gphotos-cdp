# Chrome Remote Debugging

Connect to Chrome running in Docker from your local browser.

## Quick Start

### 1. Start Chrome on server

```bash
make chrome-debug
```

### 2. Connect from your browser

1. Open Chrome on your computer
2. Go to `chrome://inspect/#devices`
3. Click **Configure...** → Add `YOUR_SERVER_IP:9222`
4. Wait for "Remote Target" to appear
5. Click **inspect**

### 3. Login to Google Photos

```bash
# Open Google Photos
curl -X PUT http://localhost:9222/json/new?https://photos.google.com
```

Then login through DevTools. Session saves to `./chrome-profile`.

## SSH Tunnel (if port blocked)

```bash
ssh -L 9222:localhost:9222 user@server
```

Then connect to `localhost:9222` in chrome://inspect.

## Commands

```bash
make chrome-debug        # Start
make chrome-debug-stop   # Stop
make chrome-debug-logs   # View logs
```

## Troubleshooting

**Port already in use:**
```bash
docker-compose stop chrome-debug
```

**Can't connect:**
```bash
# Check if running
curl http://localhost:9222/json/version
```

