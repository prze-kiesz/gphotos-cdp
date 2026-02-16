# Systemd Service Setup

This directory contains systemd unit files for running gphotos-cdp as a system service with automatic scheduling.

## Installation

### 1. Deploy to /opt

```bash
# Copy project to /opt
sudo cp -r /path/to/gphotos-cdp /opt/gphotos-cdp
cd /opt/gphotos-cdp

# Set proper ownership
sudo chown -R $USER:$USER /opt/gphotos-cdp

# Create .env file
cp .env.example .env
# Edit .env as needed
```

### 2. Authenticate

```bash
cd /opt/gphotos-cdp
./setup-auth.sh
```

### 3. Install Systemd Units

```bash
# Copy service and timer files
sudo cp systemd/gphotos-cdp.service /etc/systemd/system/
sudo cp systemd/gphotos-cdp.timer /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable gphotos-cdp.service
sudo systemctl start gphotos-cdp.service

# Enable and start the timer (for scheduled runs)
sudo systemctl enable gphotos-cdp.timer
sudo systemctl start gphotos-cdp.timer
```

## Usage

### Check Status

```bash
# Check service status
sudo systemctl status gphotos-cdp.service

# Check timer status
sudo systemctl status gphotos-cdp.timer

# List next scheduled runs
sudo systemctl list-timers gphotos-cdp.timer
```

### View Logs

```bash
# View service logs
sudo journalctl -u gphotos-cdp.service -f

# View container logs
cd /opt/gphotos-cdp && docker-compose logs -f
```

### Manual Run

```bash
# Trigger manual sync
sudo systemctl start gphotos-cdp.service

# Or run directly
cd /opt/gphotos-cdp && docker-compose up --abort-on-container-exit
```

### Stop/Disable

```bash
# Stop timer
sudo systemctl stop gphotos-cdp.timer
sudo systemctl disable gphotos-cdp.timer

# Stop service
sudo systemctl stop gphotos-cdp.service
sudo systemctl disable gphotos-cdp.service
```

## Configuration

Edit `/opt/gphotos-cdp/.env` to change settings:

```bash
cd /opt/gphotos-cdp
nano .env

# After changes, restart
sudo systemctl restart gphotos-cdp.service
```

Edit timer schedule by modifying:
```bash
sudo nano /etc/systemd/system/gphotos-cdp.timer
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart gphotos-cdp.timer
```

## Schedule Examples

### Every 6 hours (default)
```ini
OnCalendar=*-*-* 00,06,12,18:00:00
```

### Every 2 hours
```ini
OnCalendar=*-*-* */2:00:00
```

### Daily at 2 AM
```ini
OnCalendar=*-*-* 02:00:00
```

### Every Monday at 3 AM
```ini
OnCalendar=Mon *-*-* 03:00:00
```

## Troubleshooting

### Check Timer Schedule
```bash
systemctl list-timers --all
```

### Service Won't Start
```bash
# Check docker is running
sudo systemctl status docker

# Check logs
sudo journalctl -u gphotos-cdp.service -n 50 --no-pager
```

### Re-authenticate
```bash
cd /opt/gphotos-cdp
sudo systemctl stop gphotos-cdp.service
rm -rf chrome-profile/*
./setup-auth.sh
sudo systemctl start gphotos-cdp.service
```
