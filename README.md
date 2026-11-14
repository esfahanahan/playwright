# Playwright CI image

Node.js 24.22.1 bookworm with Playwright 1.62.1 browsers and their OS libraries, for Esfahanahan CI.

GitLab runners get HTTP 403 from `storage.googleapis.com` when Playwright downloads Chrome for Testing, and installing the browsers inside the Simorgh pipeline takes hours. This repository builds the image on a GitHub-hosted runner and publishes it to GHCR.

Simorgh pins:

```text
ghcr.io/esfahanahan/playwright:1.62.1-node24.22.1
```

Browsers are installed at `/var/cache/ms-playwright`. The `playwright` npm package is not left in the image. The consuming project installs `@playwright/test` at the same version.

## Publish

Push to `master` (or run the **Publish Playwright image** workflow by hand). The workflow reads `PLAYWRIGHT_VERSION` and `NODE_IMAGE` from the `Dockerfile` and tags `ghcr.io/esfahanahan/playwright:<playwright>-node<node>`.

A new Playwright or Node version means changing those `ARG` defaults, pushing, then updating the pin in Simorgh (`.gitlab/ci/common.yml`, `PLAYWRIGHT_IMAGE` and `PLAYWRIGHT_VERSION`, kept in step with `package.json`).

The image is linux/amd64 only. It contains no secrets. The package has to be public so the GitLab runners can pull it without a token.
