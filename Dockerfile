# syntax=docker/dockerfile:1

# Node.js and Playwright browsers for Esfahanahan CI.
#
# Simorgh used to install these inside its CI image on the GitLab runners.
# That build is slow, and Chrome for Testing is downloaded from
# storage.googleapis.com, which answers those runners with 403
# "not available in your location". This image is built on GitHub-hosted
# runners, where that download works, and published to GHCR.
#
# The install is the one Simorgh used before copying Chromium out of
# mcr.microsoft.com/playwright: full Debian bookworm, OS libraries, then
# Chromium, Firefox, and WebKit. The global npm package is removed
# afterwards. The project installs @playwright/test itself.
# PLAYWRIGHT_VERSION must match that dependency.
#
# NODE_IMAGE is the same digest Simorgh pins as NODE_BOOKWORM_IMAGE.

ARG NODE_IMAGE=node:24.22.1-bookworm@sha256:6449e19d8184d84062525b6a7524def03146c2cb04a7f08b076680d0e8e4240a
ARG PLAYWRIGHT_VERSION=1.62.1

FROM ${NODE_IMAGE}

ARG PLAYWRIGHT_VERSION

ENV PLAYWRIGHT_BROWSERS_PATH=/var/cache/ms-playwright
ENV NODE_USE_ENV_PROXY=1

RUN PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install -g "playwright@${PLAYWRIGHT_VERSION}" \
    && playwright --version 2>&1 | grep -qx "Version ${PLAYWRIGHT_VERSION}" \
    && playwright install-deps chromium firefox webkit \
    && playwright install chromium firefox webkit \
    && npm uninstall -g playwright \
    && rm -rf /root/.npm \
    && chmod -R a+rX "${PLAYWRIGHT_BROWSERS_PATH}" \
    && ls -d "${PLAYWRIGHT_BROWSERS_PATH}"/chromium-* >/dev/null \
    && ls -d "${PLAYWRIGHT_BROWSERS_PATH}"/firefox-* >/dev/null \
    && ls -d "${PLAYWRIGHT_BROWSERS_PATH}"/webkit-* >/dev/null

LABEL org.opencontainers.image.source="https://github.com/esfahanahan/playwright" \
      org.opencontainers.image.description="Node.js bookworm with Playwright browsers for Esfahanahan CI"
