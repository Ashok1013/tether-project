FROM ubuntu:22.04

ARG USER=dev
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git python3 python3-pip python3-dev \
    cmake ninja-build build-essential \
    curl wget unzip zip \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

WORKDIR /workspace
USER ${USER}

# Install Python packaging tools
RUN python3 -m pip install --upgrade pip setuptools wheel

# Copy our helper script
COPY docker/build_native.sh /usr/local/bin/build_native.sh
RUN chmod +x /usr/local/bin/build_native.sh

ENTRYPOINT ["/usr/local/bin/build_native.sh"]
