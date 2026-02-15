# =============================================================================
# Golden Image: OpenClaw + Atlassian CLI + Platform CLI Tools
# Ticket: B-077
# =============================================================================

# -- Version matrix (pin everything) -----------------------------------------
ARG ACLI_VERSION=1.3.13
ARG OC_VERSION=4.15.6
ARG KUBECTL_VERSION=1.29.3
ARG VAULT_VERSION=1.15.6
ARG HELM_VERSION=3.14.3
ARG ARGOCD_VERSION=2.10.4
ARG JQ_VERSION=1.7.1
ARG YQ_VERSION=4.42.1
ARG TRIVY_VERSION=0.50.1

# =============================================================================
# Stage 1: Download and extract all CLI binaries
# =============================================================================
FROM debian:bookworm-slim AS downloader

ARG OC_VERSION
ARG KUBECTL_VERSION
ARG VAULT_VERSION
ARG HELM_VERSION
ARG ARGOCD_VERSION
ARG JQ_VERSION
ARG YQ_VERSION
ARG TRIVY_VERSION

RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip tar gzip; \
    mkdir -p /out; \
    # --- oc (includes kubectl but we pin kubectl separately) ---
    curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz" \
      | tar -xz -C /out oc; \
    # --- kubectl ---
    curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /out/kubectl; \
    # --- vault ---
    curl -fsSL "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" -o /tmp/vault.zip; \
    unzip -o /tmp/vault.zip -d /out vault; \
    # --- helm ---
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
      | tar -xz -C /out --strip-components=1 linux-amd64/helm; \
    # --- argocd ---
    curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64" -o /out/argocd; \
    # --- jq ---
    curl -fsSL "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64" -o /out/jq; \
    # --- yq ---
    curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64" -o /out/yq; \
    # --- trivy ---
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      | tar -xz -C /out trivy; \
    # --- make everything executable ---
    chmod 755 /out/*; \
    # --- cleanup ---
    rm -rf /tmp/* /var/lib/apt/lists/*

# =============================================================================
# Stage 2: Final runtime image
# =============================================================================
FROM ghcr.io/openclaw/openclaw:latest

ARG ACLI_VERSION

USER root

# Install acli + minimal deps (single layer)
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://acli.atlassian.com/install.sh" -o /tmp/acli-install.sh; \
    chmod +x /tmp/acli-install.sh; \
    /tmp/acli-install.sh -b /usr/local/bin; \
    rm -f /tmp/acli-install.sh

# Copy all platform CLI binaries from downloader (single layer)
COPY --from=downloader /out/ /usr/local/bin/

# Copy smoke test script
COPY scripts/smoke-test.sh /usr/local/bin/smoke-test.sh
RUN chmod +x /usr/local/bin/smoke-test.sh

# Drop back to non-root
USER 1000

CMD ["openclaw", "--help"]
