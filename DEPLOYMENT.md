# Deployment Scenarios

Different ways to deploy gphotos-cdp depending on your infrastructure.

## 1. Single Server (Simplest)

Best for: Personal use, single-server setup

```bash
# Clone and install
git clone <your-repo>
cd gphotos-cdp
./install.sh

# Authenticate
./setup-auth.sh

# Start
make up
```

**Pros:** Simple, easy to maintain
**Cons:** No redundancy, requires manual updates

---

## 2. Systemd Service (Auto-start)

Best for: Always-on server, automatic syncing

```bash
# Deploy to /opt
sudo cp -r $(pwd) /opt/gphotos-cdp
cd /opt/gphotos-cdp

# Install service
sudo cp systemd/*.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now gphotos-cdp.timer

# Check status
sudo systemctl status gphotos-cdp.timer
systemctl list-timers
```

**Pros:** Automatic startup, scheduled runs
**Cons:** Requires root access for setup

See [systemd/README.md](systemd/README.md) for details.

---

## 3. Docker Swarm (Multi-node)

Best for: Multiple servers, high availability

```yaml
# docker-compose.swarm.yml
version: '3.8'
services:
  gphotos-cdp:
    image: ghcr.io/YOUR_USERNAME/gphotos-cdp:latest
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
    volumes:
      - gphotos-data:/data/photos
      - gphotos-profile:/data/profile
    configs:
      - source: gphotos-env
        target: /app/.env

volumes:
  gphotos-data:
    driver: local
  gphotos-profile:
    driver: local

configs:
  gphotos-env:
    external: true
```

Deploy:
```bash
docker swarm init
docker config create gphotos-env .env
docker stack deploy -c docker-compose.swarm.yml gphotos
```

**Pros:** High availability, easy scaling
**Cons:** More complex setup

---

## 4. Kubernetes (Enterprise)

Best for: Large organizations, existing K8s infrastructure

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gphotos-cdp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gphotos-cdp
  template:
    metadata:
      labels:
        app: gphotos-cdp
    spec:
      containers:
      - name: gphotos-cdp
        image: ghcr.io/YOUR_USERNAME/gphotos-cdp:latest
        env:
        - name: WORKERS
          value: "2"
        - name: LOGLEVEL
          value: "info"
        volumeMounts:
        - name: photos
          mountPath: /data/photos
        - name: profile
          mountPath: /data/profile
        resources:
          limits:
            memory: "4Gi"
            cpu: "2"
          requests:
            memory: "2Gi"
            cpu: "1"
      volumes:
      - name: photos
        persistentVolumeClaim:
          claimName: gphotos-photos-pvc
      - name: profile
        persistentVolumeClaim:
          claimName: gphotos-profile-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gphotos-photos-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gphotos-profile-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Deploy:
```bash
kubectl apply -f k8s/
```

**Pros:** Enterprise-grade, automated management
**Cons:** Complex, overkill for personal use

---

## 5. Cloud Platforms

### AWS ECS

```bash
# Use pre-built image
aws ecs create-cluster --cluster-name gphotos
# Define task definition with ghcr.io image
# Create service with EFS volumes
```

### Google Cloud Run

```bash
gcloud run deploy gphotos-cdp \
  --image ghcr.io/YOUR_USERNAME/gphotos-cdp:latest \
  --platform managed \
  --memory 4Gi
```

### Azure Container Instances

```bash
az container create \
  --resource-group myResourceGroup \
  --name gphotos-cdp \
  --image ghcr.io/YOUR_USERNAME/gphotos-cdp:latest \
  --memory 4 \
  --cpu 2
```

---

## 6. NAS Devices

### Synology DSM

1. Enable Docker in Package Center
2. Upload docker-compose.yml
3. Use Container Manager to deploy
4. Set up Task Scheduler for authentication

### QNAP Container Station

1. Install Container Station
2. Import docker-compose.yml
3. Configure volumes to NAS shares
4. Create scheduled tasks

---

## Comparison Matrix

| Scenario | Complexity | Availability | Auto-updates | Best For |
|----------|-----------|--------------|--------------|----------|
| Single Server | ⭐ | Low | Manual | Testing, personal |
| Systemd | ⭐⭐ | Medium | Manual | Home server |
| Docker Swarm | ⭐⭐⭐ | High | Auto | Small clusters |
| Kubernetes | ⭐⭐⭐⭐⭐ | Very High | Auto | Enterprise |
| Cloud | ⭐⭐⭐ | High | Auto | Managed service |
| NAS | ⭐⭐ | Medium | Manual | Home/small office |

---

## Monitoring & Alerts

### Healthcheck Integration

```bash
# Cron job to check health
*/15 * * * * /opt/gphotos-cdp/healthcheck.sh || mail -s "gphotos-cdp failed" admin@example.com
```

### Prometheus Monitoring

```yaml
# docker-compose.monitoring.yml
services:
  gphotos-cdp:
    # ... existing config
    labels:
      - "prometheus-job=gphotos-cdp"
  
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - 8080:8080
```

### Log Aggregation

```yaml
# docker-compose.logging.yml
services:
  gphotos-cdp:
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: gphotos-cdp
```

---

## Backup Strategies

### 1. Rsync to Remote

```bash
# Cron job
0 2 * * * rsync -avz /opt/gphotos-cdp/photos/ backup-server:/backups/gphotos/
```

### 2. Rclone to Cloud

```bash
# Sync to S3/Google Drive/etc
rclone sync /opt/gphotos-cdp/photos/ remote:gphotos-backup
```

### 3. Docker Volume Backup

```bash
docker run --rm \
  -v gphotos-cdp_photos:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/photos-backup.tar.gz /data
```

---

## Security Considerations

1. **Profile Security**: Encrypt `chrome-profile/` volume
2. **Network Isolation**: Use private Docker networks
3. **Secrets Management**: Use Docker secrets or vault
4. **Read-only Filesystem**: Mount code as read-only
5. **Non-root User**: Already configured (UID 1000)
6. **Resource Limits**: Set CPU/memory limits
7. **Automated Updates**: Use Watchtower or similar

```yaml
# Watchtower for auto-updates
services:
  watchtower:
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 86400  # Check daily
```
