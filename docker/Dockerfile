# Use Ubuntu LTS as baseline for wide compat & apt packages
FROM ubuntu:22.04

ARG USER=dev
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates git curl wget python3 python3-venv python3-pip build-essential \
    cmake ninja-build gcc g++ pkg-config libffi-dev libssl-dev \
    ca-certificates sudo unzip zip rsync procps \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} || true \
  && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
  && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
  && chmod 0440 /etc/sudoers.d/${USER}

WORKDIR /home/${USER}/workspace
ENV HOME=/home/${USER}

# FIXED PATHS HERE ↓↓↓
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/build_wheel.sh /usr/local/bin/build_wheel.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/build_wheel.sh

RUN python3 -m pip install --no-cache-dir pip setuptools wheel cibuildwheel==2.* twine pytest

USER ${USER}

ENV DEV=0

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]

HEALTHCHECK --interval=60s --timeout=3s CMD python3 -c "import sys; sys.exit(0)"
