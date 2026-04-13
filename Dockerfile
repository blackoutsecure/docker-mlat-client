# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE_REGISTRY=ghcr.io
ARG BASE_IMAGE_NAME=linuxserver/baseimage-alpine
ARG BASE_IMAGE_VARIANT=3.22
ARG BASE_IMAGE=${BASE_IMAGE_REGISTRY}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VARIANT}
ARG BUILD_OUTPUT_DIR=/out
ARG MLAT_CLIENT_REPO_URL=https://github.com/wiedehopf/mlat-client
ARG MLAT_CLIENT_REPO_BRANCH=master
ARG VCS_URL=https://github.com/blackoutsecure/docker-mlat-client

FROM ${BASE_IMAGE} AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_OUTPUT_DIR
ARG MLAT_CLIENT_REPO_URL
ARG MLAT_CLIENT_REPO_BRANCH
ARG VCS_URL

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        git \
        python3 \
        python3-dev \
        py3-pip \
        py3-setuptools

WORKDIR /src
RUN git clone \
        --branch ${MLAT_CLIENT_REPO_BRANCH} --single-branch --depth 1 \
        ${MLAT_CLIENT_REPO_URL} . && \
    BUILD_DATE="$(git log -1 --format=%cI)" && \
    VERSION="$(cat version 2>/dev/null || git describe --tags --always --dirty 2>/dev/null || echo unknown)" && \
    VCS_REF="$(git rev-parse HEAD)" && \
    printf 'BUILD_DATE=%s\nVERSION=%s\nVCS_REF=%s\nVCS_URL=%s\n' \
        "${BUILD_DATE}" "${VERSION}" "${VCS_REF}" "${VCS_URL}" \
        > /tmp/mlat-client-build-metadata.env && \
    rm -rf .git

ARG VENV_DIR=/opt/mlat-client/venv

RUN python3 -m venv "${VENV_DIR}" && \
    . "${VENV_DIR}/bin/activate" && \
    pip install --no-cache-dir setuptools && \
    python3 -c "import asyncore" 2>/dev/null || pip install --no-cache-dir pyasyncore && \
    pip install --no-cache-dir . && \
    deactivate && \
    mkdir -p "${BUILD_OUTPUT_DIR}" && \
    cp -a "${VENV_DIR}" "${BUILD_OUTPUT_DIR}/venv" && \
    mkdir -p "${BUILD_OUTPUT_DIR}/usr/local/bin" && \
    printf '#!/bin/sh\nexec /opt/mlat-client/venv/bin/mlat-client "$@"\n' \
        > "${BUILD_OUTPUT_DIR}/usr/local/bin/mlat-client" && \
    chmod 0755 "${BUILD_OUTPUT_DIR}/usr/local/bin/mlat-client" && \
    mkdir -p "${BUILD_OUTPUT_DIR}/usr/local/share/mlat-client" && \
    install -D -m 0644 /tmp/mlat-client-build-metadata.env \
        "${BUILD_OUTPUT_DIR}/usr/local/share/mlat-client/build-metadata.env"

FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG VCS_URL

LABEL build_version="Linuxserver.io version:- unknown Build-date:- unknown"
LABEL maintainer="Blackout Secure - https://blackoutsecure.com/"
LABEL org.opencontainers.image.title="docker-mlat-client" \
    org.opencontainers.image.description="LinuxServer.io–style containerized client forwarding Mode S messages for aircraft multilateration" \
    org.opencontainers.image.url="${VCS_URL}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.revision="unknown" \
    org.opencontainers.image.created="unknown" \
    org.opencontainers.image.version="unknown" \
    org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV HOME="/config" \
    MLAT_CLIENT_USER="root"

RUN apk add --no-cache \
        python3

COPY --link --from=builder /out/venv/ /opt/mlat-client/venv/
COPY --link --from=builder /out/usr/local/ /usr/local/
COPY --link root/ /

RUN if [ -f /usr/local/share/mlat-client/build-metadata.env ]; then \
        . /usr/local/share/mlat-client/build-metadata.env; \
    fi && \
    echo "Linuxserver.io version:- ${VERSION:-unknown} Build-date:- ${BUILD_DATE:-unknown} Revision:- ${VCS_REF:-unknown}" > /build_version && \
    find /etc/s6-overlay/s6-rc.d -type f \( -name run -o -name finish -o -name check \) -exec chmod 0755 {} + && \
    # Disable the base image's verbose cron service — this container has no cron jobs
    rm -rf /etc/s6-overlay/s6-rc.d/svc-cron /etc/s6-overlay/s6-rc.d/user/contents.d/svc-cron && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

VOLUME ["/config"]
