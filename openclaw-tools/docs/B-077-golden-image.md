# B-077: Golden Image Update — Platform CLI Tools

**Author:** Tesla (Platform Engineering)
**Date:** 2026-02-15
**Image:** `ghcr.io/rhels/openclaw-tools`
**Branch:** `infra/B-077-golden-image`

---

## 1. Current Baseline

The existing golden image (`openclaw-tools/Dockerfile`) provides:

| Layer | Detail |
|-------|--------|
| Base | `ghcr.io/openclaw/openclaw:latest` (Debian-based, uid 1000) |
| Runtime | OpenClaw CLI (pre-installed in base) |
| Tooling | Atlassian CLI (acli) v1.3.13 |
| Extras | ca-certificates, curl, unzip (apt) |

Image is built on push to `main` via GitHub Actions and pushed to GHCR as `:latest` only.

---

## 2. Tools to Add

| Tool | Version | Source |
|------|---------|--------|
| `oc` (OpenShift CLI) | 4.15.6 | [mirror.openshift.com](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.15.6/) |
| `kubectl` | 1.29.3 | [dl.k8s.io](https://dl.k8s.io/release/v1.29.3/bin/linux/amd64/kubectl) |
| `vault` | 1.15.6 | [releases.hashicorp.com](https://releases.hashicorp.com/vault/1.15.6/) |
| `helm` | 3.14.3 | [get.helm.sh](https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz) |
| `argocd` | 2.10.4 | [github.com/argoproj](https://github.com/argoproj/argo-cd/releases/download/v2.10.4/argocd-linux-amd64) |
| `jq` | 1.7.1 | [github.com/jqlang](https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64) |
| `yq` | 4.42.1 | [github.com/mikefarah](https://github.com/mikefarah/yq/releases/download/v4.42.1/yq_linux_amd64) |
| `trivy` | 0.50.1 | [github.com/aquasecurity](https://github.com/aquasecurity/trivy/releases/download/v0.50.1/trivy_0.50.1_Linux-64bit.tar.gz) |

### Version Pinning Strategy

- All versions are **exact semver** — no `:latest`, no floating tags.
- Versions defined as Dockerfile `ARG`s for easy bumps via Renovate or Dependabot.
- Update cadence: monthly review, patch on CVE.

---

## 3. Dockerfile Design

### Approach

- **Multi-stage build**: Stage 1 (`downloader`) fetches and extracts all binaries.
  Stage 2 copies them into the runtime image in a single `COPY` layer.
- **Single `RUN` in downloader** to minimize layers and allow full cache cleanup.
- **No package manager in final image** beyond what the base provides — all new tools are static binaries.

### Key decisions

| Decision | Rationale |
|----------|-----------|
| Keep Debian base (from upstream OpenClaw) | Upstream compatibility; switching to Alpine would break OpenClaw |
| Multi-stage download | Keeps curl/tar/unzip out of the final image layer delta |
| `chmod 755` all binaries | Consistent permissions, scannable |
| `/usr/local/bin` target | On PATH, standard for add-on binaries |

See the updated `openclaw-tools/Dockerfile` for the implementation.

---

## 4. GitHub Actions Workflow Updates

Changes to `.github/workflows/build-push.yml`:

1. **Tagging strategy** — push three tags per build:
   - `ghcr.io/rhels/openclaw-tools:<semver>` (e.g. `1.2.0`)
   - `ghcr.io/rhels/openclaw-tools:sha-<short-sha>`
   - `ghcr.io/rhels/openclaw-tools:latest`
2. **Trivy scan step** — scan the built image before push; fail on CRITICAL/HIGH.
3. **Smoke test step** — run the smoke script inside the image.
4. **Multi-platform** — linux/amd64 (arm64 optional, gated on tool availability).

### Updated workflow additions

```yaml
      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/rhels/openclaw-tools
          tags: |
            type=semver,pattern={{version}}
            type=sha,prefix=sha-
            type=raw,value=latest

      - name: Build (load for scan)
        uses: docker/build-push-action@v6
        with:
          context: ./openclaw-tools
          load: true
          tags: openclaw-tools:ci

      - name: Smoke test
        run: docker run --rm openclaw-tools:ci /usr/local/bin/smoke-test.sh

      - name: Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: openclaw-tools:ci
          severity: CRITICAL,HIGH
          exit-code: 1

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./openclaw-tools
          push: true
          tags: ${{ steps.meta.outputs.tags }}
```

---

## 5. Image Size Optimization

| Technique | Impact |
|-----------|--------|
| Multi-stage: download in throwaway stage | Eliminates curl/wget/tar from layer history |
| `rm -rf /tmp/*` in downloader | No leftover archives |
| No apt-get in final stage for new tools | Zero additional deb packages |
| Static binaries only | No shared-lib deps to pull in |
| Single COPY layer for all 8 binaries | Minimal layer overhead |

**Estimated size delta:** ~250 MB added (dominated by `oc` ~120 MB, `vault` ~45 MB, `trivy` ~45 MB). Acceptable for a platform engineering toolbox.

---

## 6. Security Scanning

- **CI gate:** Trivy scans the image on every PR and push to `main`. Fails on CRITICAL or HIGH.
- **Runtime:** `trivy` is included in the image itself so teams can scan workloads from inside pipelines.
- **SBOM:** Future enhancement — add `--format cyclonedx` output as build artifact.

---

## 7. Smoke Test Script

Located at `openclaw-tools/scripts/smoke-test.sh`. Runs inside the container:

```bash
#!/usr/bin/env bash
set -euo pipefail
failures=0
for cmd in openclaw acli oc kubectl vault helm argocd jq yq trivy; do
  if command -v "$cmd" &>/dev/null; then
    printf "✅ %-12s %s\n" "$cmd" "$($cmd version 2>/dev/null || $cmd --version 2>/dev/null || echo 'ok')"
  else
    printf "❌ %-12s NOT FOUND\n" "$cmd"
    failures=$((failures + 1))
  fi
done
exit $failures
```

---

## 8. Tagging Strategy

| Tag | Example | When |
|-----|---------|------|
| semver | `1.2.0` | On release (manual or tag-triggered) |
| sha | `sha-a1b2c3d` | Every push to main |
| `latest` | `latest` | Every push to main |

Consumers should pin to semver in production. `latest` is for dev/CI convenience only.

---

## 9. Rollout Plan

1. Merge `infra/B-077-golden-image` → `main`
2. CI builds, scans, pushes new image
3. Notify dependent teams (Slack `#platform-eng`)
4. Update downstream Dockerfiles/Helm values referencing the image
5. Monitor image pull metrics in GHCR for 48h

---

## 10. Rollback

Revert the merge commit on `main`. CI will rebuild from the previous Dockerfile state. All tags except `latest` are immutable, so pinned consumers are unaffected.
