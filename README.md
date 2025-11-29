# Docker GitHub Actions Runner

This image extends `myoung34/github-runner` and provides:

* **Build-time UID/GID reassignment** for the `runner` user.

  > **Note:** The UID/GID is currently hardcoded via build arguments (default: 3000:988). You can override these at build time if needed.
* **Secure token loading** is handled by directly patching the upstream entrypoint.

---

## 🚀 Usage

### 1. Build the image

```bash
docker build -t myrunner:latest .
```

### 2. Run the container

```bash
docker run -d \
  -e REPO_URL="https://github.com/your/repo" \
  -e ACCESS_TOKEN_FILE="/run/secrets/gh_token" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --secret source=gh_token,target=/run/secrets/gh_token \
  myrunner:latest
```

---

## 🛠 Files Included

### `Dockerfile`

* Sets the runner UID/GID at build time.
* Patches the upstream `/entrypoint.sh` to handle `ACCESS_TOKEN_FILE`.
* Fixes ownership of `/home/runner` for the new UID/GID.

> **Note:** No wrapper script is used; everything is handled directly in the Dockerfile.

---

## 🔐 Token Handling

Instead of hard-coding a GitHub token, mount it as a Docker secret:

```bash
ACCESS_TOKEN_FILE=/run/secrets/gh_token
```

The patched entrypoint detects this file at runtime and exports `ACCESS_TOKEN` automatically.

---

## Sample Docker Compose Template

```yaml
version: "3.8"

services:
  github-runner:
    image: ghcr.io/<your-org>/custom-github-runner:latest
    container_name: github-runner
    deploy:
      placement:
        constraints:
          - node.role == manager
    volumes:
      # Required if your workflows need Docker access
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      # Timezone for the container
      TZ: <Your/Timezone>
      # Runner scope: "org" or "repo"
      RUNNER_SCOPE: "<org-or-repo>"
      # Organization or repository name
      ORG_NAME: "<org-name>"
      REPO_NAME: "<repo-name-if-applicable>"
      # Runner display name
      RUNNER_NAME: "<runner-name>"
      # Comma-separated labels for this runner
      RUNNER_LABELS: "<label1,label2,...>"
      # Path to the mounted GitHub PAT secret
      ACCESS_TOKEN_FILE: "/run/secrets/github_pat"
      # Optional: run as root (true/false)
      RUN_AS_ROOT: "false"
    secrets:
      - github_pat

secrets:
  github_pat:
    external: true
```
