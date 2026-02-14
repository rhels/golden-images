# openclaw-tools (Golden Image)

A minimal “golden image” for running OpenClaw bots with common platform tooling installed.

## Image

- `ghcr.io/rhels/openclaw-tools:latest`

## What’s included

- Base: `ghcr.io/openclaw/openclaw:latest`
- Atlassian CLI (`acli`) (installed from Atlassian official distribution)

## Usage

Run interactively:

```bash
docker run --rm -it ghcr.io/rhels/openclaw-tools:latest openclaw --help
```

Verify `acli`:

```bash
docker run --rm -it ghcr.io/rhels/openclaw-tools:latest acli version
```

## Extending

Create a new Dockerfile:

```Dockerfile
FROM ghcr.io/rhels/openclaw-tools:latest
# add more tools here
```

Then build and push your derived image.

## Security notes

- Do **not** bake credentials into images.
- Use Vault / External Secrets / CI secrets injection.
