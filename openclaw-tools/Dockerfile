# Golden image: OpenClaw + Atlassian CLI (acli)
# Base image pinned to upstream OpenClaw runtime
FROM ghcr.io/openclaw/openclaw:latest

ARG ACLI_VERSION=1.3.13

# Install Atlassian CLI (acli)
# Ref: https://developer.atlassian.com/cloud/acli/
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL -o /tmp/acli.zip "https://acli.atlassian.com/linux/latest"; \
    unzip -q /tmp/acli.zip -d /opt/acli; \
    ln -sf /opt/acli/acli /usr/local/bin/acli; \
    rm -f /tmp/acli.zip; \
    acli version

# Default command
CMD ["openclaw", "--help"]
