# golden-images

Golden container images used by the RHELS platform team.

## Images

### openclaw-tools → `ghcr.io/rhels/openclaw-tools:latest`

Full platform engineering toolset on top of OpenClaw base. Includes:

| Category | Tools |
|----------|-------|
| Kubernetes | `oc`, `kubectl`, `helm`, `argocd` |
| Security | `vault`, `trivy`, `gitleaks` |
| Data processing | `jq`, `yq`, `python3` |
| Infrastructure | `cloudflared`, `git`, `curl` |
| Atlassian | `acli` |

## Repo Layout

```
openclaw-tools/     # Dockerfile + README
.github/workflows/  # CI: build & push to GHCR
```
