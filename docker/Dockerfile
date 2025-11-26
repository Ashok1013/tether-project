# docker/Dockerfile — stable + always refresh build_native.sh

FROM ubuntu:22.04

ARG USER=dev
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------
# Base tools
# ---------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    cmake ninja-build build-essential \
    curl wget unzip zip \
    && rm -rf /var/lib/apt/lists/*

# Optional non-root user (but we keep running as root in CI)
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

WORKDIR /workspace

RUN python3 -m pip install --upgrade pip setuptools wheel

# ---------------------------------------------------------
# Cache-busting trick → forces Docker to rebuild this layer
# whenever build_native.sh changes
# ---------------------------------------------------------
ADD docker/build_native.sh /tmp/build_native.sh
RUN install -m 755 /tmp/build_native.sh /usr/local/bin/build_native.sh && rm /tmp/build_native.sh

# (IMPORTANT)
# DO NOT switch to non-root—CI bind mounts /workspace as root-only
# USER ${USER}

ENV HOME=/root

ENTRYPOINT ["/usr/local/bin/build_native.sh"]
# rebuild
# rebuild
