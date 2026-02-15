# openclaw-tools (Golden Image)

Full-featured golden image for running OpenClaw bots with platform engineering CLI tools.

## Image

```
ghcr.io/rhels/openclaw-tools:latest
```

Multi-arch: `linux/amd64` and `linux/arm64`.

## Tool Inventory

| Tool | Purpose |
|------|---------|
| `acli` | Atlassian CLI (Jira, Confluence) |
| `oc` | OpenShift CLI |
| `kubectl` | Kubernetes CLI (bundled with oc) |
| `vault` | HashiCorp Vault CLI |
| `helm` | Kubernetes package manager |
| `argocd` | Argo CD CLI |
| `jq` | JSON processor |
| `yq` | YAML processor |
| `trivy` | Vulnerability scanner |
| `gitleaks` | Secret scanner |
| `python3` + `pip` | Python runtime |
| `cloudflared` | Cloudflare Tunnel client |
| `git` | Version control |
| `curl` | HTTP client |

## Usage

```bash
# Run interactively
docker run --rm -it ghcr.io/rhels/openclaw-tools:latest bash

# Verify tools
docker run --rm ghcr.io/rhels/openclaw-tools:latest kubectl version --client
```

## Extending

```Dockerfile
FROM ghcr.io/rhels/openclaw-tools:latest
# add more tools here
```

## Version Pinning

All tool versions are controlled via `ARG` in the Dockerfile. Update and rebuild to upgrade.

## Security Notes

- Do **not** bake credentials into images.
- Use Vault / External Secrets / CI secrets injection.
- Run `trivy image ghcr.io/rhels/openclaw-tools:latest` to scan this image.
