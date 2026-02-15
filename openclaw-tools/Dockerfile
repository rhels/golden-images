# Golden image: OpenClaw + full platform CLI toolset
# Base image pinned to upstream OpenClaw runtime
FROM ghcr.io/openclaw/openclaw:latest

# Tool versions (update these to pin upgrades)
ARG ACLI_VERSION=1.3.13
ARG OC_VERSION=4.15.0
ARG VAULT_VERSION=1.15.6
ARG HELM_VERSION=3.14.2
ARG ARGOCD_VERSION=2.10.2
ARG YQ_VERSION=4.42.1
ARG TRIVY_VERSION=0.59.1
ARG GITLEAKS_VERSION=8.18.2
ARG CLOUDFLARED_VERSION=2024.2.1

USER root

# Install OS packages: jq, python3, pip, git, curl, unzip, ca-certs
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl unzip git jq python3 python3-pip python3-venv; \
    rm -rf /var/lib/apt/lists/*

# Detect architecture helper
# All tool installs in a single layer to minimize image size
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
        amd64) GOARCH=amd64; OCARCH=x86_64; TRIVYARCH=64bit ;; \
        arm64) GOARCH=arm64; OCARCH=aarch64; TRIVYARCH=ARM64 ;; \
        *) echo "Unsupported arch: ${ARCH}" && exit 1 ;; \
    esac; \
    \
    # --- acli (Atlassian CLI) --- \
    curl -fsSL "https://acli.atlassian.com/install.sh" -o /tmp/acli-install.sh; \
    chmod +x /tmp/acli-install.sh; \
    /tmp/acli-install.sh -b /usr/local/bin; \
    rm -f /tmp/acli-install.sh; \
    \
    # --- oc (OpenShift CLI) + kubectl bundled --- \
    curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/${OCARCH}/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz" \
        | tar -xz -C /usr/local/bin oc kubectl; \
    chmod +x /usr/local/bin/oc /usr/local/bin/kubectl; \
    \
    # --- vault (HashiCorp) --- \
    curl -fsSL "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${GOARCH}.zip" \
        -o /tmp/vault.zip; \
    unzip -o /tmp/vault.zip -d /usr/local/bin; \
    rm /tmp/vault.zip; \
    \
    # --- helm --- \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${GOARCH}.tar.gz" \
        | tar -xz --strip-components=1 -C /usr/local/bin "linux-${GOARCH}/helm"; \
    \
    # --- argocd CLI --- \
    curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-${GOARCH}" \
        -o /usr/local/bin/argocd; \
    chmod +x /usr/local/bin/argocd; \
    \
    # --- yq --- \
    curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${GOARCH}" \
        -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq; \
    \
    # --- trivy (vulnerability scanner) --- \
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVYARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin trivy; \
    \
    # --- gitleaks (secret scanner) --- \
    curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GOARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin gitleaks; \
    \
    # --- cloudflared --- \
    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${GOARCH}" \
        -o /usr/local/bin/cloudflared; \
    chmod +x /usr/local/bin/cloudflared; \
    \
    # --- Verify installs --- \
    oc version --client || true; \
    kubectl version --client || true; \
    vault version || true; \
    helm version --short || true; \
    argocd version --client --short || true; \
    jq --version; \
    yq --version; \
    trivy --version || true; \
    gitleaks version || true; \
    python3 --version; \
    cloudflared --version || true; \
    (acli --version || acli -v || acli --help | head -5) || true

# Return to the default non-root user
USER 1000

CMD ["openclaw", "--help"]
