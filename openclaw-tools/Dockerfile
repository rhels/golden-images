# Golden image: OpenClaw + Atlassian CLI (acli)
# Base image pinned to upstream OpenClaw runtime
FROM ghcr.io/openclaw/openclaw:latest

ARG ACLI_VERSION=1.3.13

# The OpenClaw base image runs as a non-root user.
# Switch to root for package installation, then drop back.
USER root

# Install Atlassian CLI (acli)
# Ref: https://developer.atlassian.com/cloud/acli/
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://acli.atlassian.com/install.sh" -o /tmp/acli-install.sh; \
    chmod +x /tmp/acli-install.sh; \
    /tmp/acli-install.sh -b /usr/local/bin; \
    rm -f /tmp/acli-install.sh; \
    (acli --version || acli -v || acli --help | head -20)

# Return to the default user (if present). Many OpenClaw images use uid 1000.
USER 1000

# Default command
CMD ["openclaw", "--help"]
