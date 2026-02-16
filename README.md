# Golden Images 🐳

Golden container images for OpenClaw bot tooling. Pre-built images with platform engineering tools, published to `ghcr.io/rhels/`.

## Why This Repo Exists

OpenClaw bots need consistent, pre-configured container images with tools like Atlassian CLI, GitHub CLI, and kubectl. These golden images provide a standard base so every bot starts with the same toolset — no manual setup, no drift.

## Available Images

| Image | Registry | Description |
|-------|----------|-------------|
| `openclaw-tools` | `ghcr.io/rhels/openclaw-tools:latest` | OpenClaw base + Atlassian CLI (`acli` v1.3.13) |

## Repository Structure

```
.
├── README.md
├── openclaw-tools/
│   ├── Dockerfile          # Image definition
│   └── README.md           # Image-specific docs
└── .github/
    └── workflows/
        ├── build-push.yml  # Build, push to GHCR on main
        └── ci.yml          # PR validation
```

## Prerequisites

- Docker (or Podman) for local builds
- GitHub access to `ghcr.io/rhels` for pulling/pushing

## Getting Started

### Pull the image

```bash
docker pull ghcr.io/rhels/openclaw-tools:latest
```

### Build locally

```bash
cd openclaw-tools
docker build -t openclaw-tools:local .
```

### Run

```bash
docker run --rm -it ghcr.io/rhels/openclaw-tools:latest bash
```

## CI/CD Pipeline

On push to `main` (when `openclaw-tools/**` changes):

1. **Checkout** → code
2. **QEMU + Buildx** → multi-arch support
3. **Login** → GHCR via `GITHUB_TOKEN`
4. **Build & Push** → `ghcr.io/rhels/openclaw-tools:latest`

## Adding a New Image

1. Create a new directory: `my-image/`
2. Add a `Dockerfile` and `README.md`
3. Add a GitHub Actions workflow in `.github/workflows/`
4. Follow the `openclaw-tools` pattern for consistency

## What's Inside `openclaw-tools`

Built on `ghcr.io/openclaw/openclaw:latest`:
- **Atlassian CLI (`acli`)** v1.3.13 — Jira & Confluence automation
- **curl**, **unzip**, **ca-certificates** — standard utilities

## License

Internal use — RHELS Platform Engineering team.
