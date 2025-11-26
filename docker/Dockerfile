# docker/Dockerfile — defensive, robust copy + install of build_native.sh

FROM ubuntu:22.04

ARG USER=dev
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools as root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-dev \
    cmake ninja-build build-essential \
    curl wget unzip zip \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (optional for local dev)
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

# Workdir and python packaging tools (running as root)
WORKDIR /workspace
RUN python3 -m pip install --upgrade pip setuptools wheel

# Defensive copy: stage to /tmp then install with correct mode
COPY docker/build_native.sh /tmp/build_native.sh
RUN install -m 755 /tmp/build_native.sh /usr/local/bin/build_native.sh && rm /tmp/build_native.sh

# (Do NOT switch to non-root user here — CI mounts /workspace as root-only)
# USER ${USER}   # <-- removed on purpose

ENV HOME=/root

# Entrypoint runs the native build script
ENTRYPOINT ["/usr/local/bin/build_native.sh"]

echo "# rebuild" >> docker/Dockerfile
