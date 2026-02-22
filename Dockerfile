# Build stage
FROM golang:1.23-bookworm AS builder

WORKDIR /build

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY *.go ./
COPY locales.yaml ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gphotos-cdp .

# Build with all Go files including learning.go
RUN ls -la *.go

# Runtime stage
FROM debian:bookworm-slim

# Install Chromium and dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    ca-certificates \
    curl \
    socat \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash gphotos && \
    mkdir -p /data/photos /data/profile /home/gphotos/.config /home/gphotos/.cache && \
    chown -R gphotos:gphotos /data /home/gphotos

# Copy binary and locales from builder
COPY --from=builder /build/gphotos-cdp /usr/local/bin/
COPY --from=builder /build/locales.yaml /usr/local/bin/

# Set proper permissions
RUN chmod +x /usr/local/bin/gphotos-cdp

# Switch to non-root user
USER gphotos
WORKDIR /home/gphotos

# Set environment variables
ENV CHROME_PATH=/usr/bin/chromium
ENV XDG_CONFIG_HOME=/home/gphotos/.config
ENV XDG_CACHE_HOME=/home/gphotos/.cache

# Default command (can be overridden in docker-compose)
CMD ["gphotos-cdp", "-profile", "/data/profile", "-dldir", "/data/photos", "-headless", "-workers", "2"]
