# Contributing to `rhels/golden-images`

Golden container images — standardized base images with pre-installed tooling (e.g., `openclaw-tools`).

## Workflow

### 1) Create a branch
Branch naming: `<type>/<ticket>-<short-desc>`
Types: docs, feature, fix, infra, security

### 2) Commit message format
```
<TICKET>: <imperative summary>

- Why the change is needed
- How to test
```

### 3) Open a Pull Request
- Target: `main`
- Keep PRs < 300 lines where possible
- Include: what changed, how to validate

### 4) Review & Merge
- 1 reviewer approval required
- All CI checks must pass
- Squash merge for small changes

## Testing Requirements

- `podman build -f <Dockerfile> .` (or `docker build`) must succeed
- Verify installed tools are available and at expected versions
- Test the built image runs without errors: `podman run --rm <image> <smoke-test-cmd>`

## Linting & Validation

- `hadolint` — all Dockerfiles
- `shellcheck` — any embedded or referenced shell scripts
- Pin base image versions (no floating `latest` tags)

## Security Rules
- Never commit secrets, tokens, passwords, or private keys
- Use Vault or environment variables for sensitive values
- Rotate immediately if a secret is accidentally committed
- Scan images with `trivy` or equivalent before publishing
- Use minimal base images and remove unnecessary packages
