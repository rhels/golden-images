# Container Image Governance Policy

## Image Sourcing Priority

When selecting base images for any workload, follow this strict priority hierarchy:

| Priority | Source | Registry | Rationale |
|----------|--------|----------|-----------|
| 1 (highest) | **Licensed vendor image** | Vendor-specific | We have a commercial relationship; vendor provides support, SLAs, and CVE triage |
| 2 | **Red Hat certified image** | `registry.access.redhat.com` | Fewer CVEs, tested on OpenShift, centralized security triage |
| 3 | **Docker Hub library** | `docker.io/library/` | Docker official images — maintained by Docker and upstream projects |
| 4 | **Docker Hub certified** | `docker.io/` (certified badge) | Vendor-maintained on Docker Hub with Docker review |
| 5 | **Docker Hub hardened** | `docker.io/` (hardened badge) | Docker security team has reviewed and hardened the image |
| 6 (never) | **Community / random** | Any | Never use unvetted community images — they may be vibrant today but unmaintained tomorrow |

### Examples

- **Jenkins:** Use CloudBees Jenkins (Priority 1 — we have a license), not Docker Hub `jenkins/jenkins`
- **Java runtime:** Use `registry.access.redhat.com/ubi9/openjdk-21-runtime` (Priority 2), not `eclipse-temurin`
- **PostgreSQL:** Use Red Hat certified or Bitnami (approved), not random `postgres-alpine` variants

## Image Nomination Process

Developers can request new images to be added to the approved catalog:

1. **Request** — Developer submits via Backstage: "I want this image maintained in our registry"
2. **Review** — Platform team evaluates against the priority hierarchy above
3. **Scan** — Image is scanned with Trivy for HIGH/CRITICAL vulnerabilities
4. **Approve** — Image is added to `inventory.yaml` and the golden registry (`ghcr.io/rhels/`)
5. **Maintain** — Weekly vulnerability scanning ensures ongoing compliance

Unapproved images are blocked by Kyverno `ClusterPolicy` at admission time.

## Approved Registries

These registries are allowed by Kyverno policy:

```yaml
- registry.access.redhat.com/  # Red Hat certified images (no auth required)
- registry.redhat.io/           # Red Hat subscription images (auth required)
- ghcr.io/rhels/                # Our golden registry (scanned, approved)
- quay.io/                      # Specific approved images only
- docker.io/bitnami/            # Specific approved images only
```

All other registries are **denied by default**.

## Helm Chart Governance

The same priority hierarchy applies to Helm charts:

1. Licensed vendor chart (e.g., CloudBees Helm chart)
2. Red Hat-provided operator / Helm chart
3. Bitnami / well-maintained open-source charts
4. Community charts (require nomination + review)

Charts consumed as dependencies in `Chart.yaml` must reference approved OCI registries or the platform team's chart repository.

## Scanning and Compliance

- **Weekly scans:** All images in `inventory.yaml` are scanned every Monday at 6am UTC
- **Severity threshold:** HIGH and CRITICAL (unfixed CVEs are flagged but tracked separately)
- **Auto-PR:** When a newer base image version is available, an automated PR is created
- **SARIF upload:** Scan results are published to GitHub Code Scanning for visibility
- **Issue tracking:** Vulnerabilities that require action generate GitHub issues automatically

## Developer Responsibility

Developers who consume golden path templates inherit the approved base images automatically.
If a developer needs a different base image:

1. Check `inventory.yaml` first — the image may already be approved
2. If not, submit a nomination via Backstage
3. Never pull directly from unapproved registries — Kyverno will reject the deployment

## Inner Source

The golden images catalog is open for contribution. Developers can:

- Propose additions to `inventory.yaml` via pull request
- Report issues with existing images via GitHub Issues
- Contribute scanning improvements to the weekly scan workflow
- Share learnings about image optimizations in the platform knowledge base
