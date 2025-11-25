#!/usr/bin/env bash
set -euo pipefail

# build python wheel using standard pyproject or setup.py
# Assumes code is present in /workspace
cd /workspace
python3 -m pip install --upgrade build
python3 -m build --wheel --no-isolation -o dist

# show results
ls -la dist || true
```

**How to use image locally**

* Development (interactive shell, mount source):

```bash
# build locally
docker build -t ghcr.io/<OWNER>/mlc-llm-dev:latest -f docker/Dockerfile .
# run interactive dev shell with source mounted
docker run --rm -it -v $(pwd):/workspace -e DEV=1 ghcr.io/<OWNER>/mlc-llm-dev:latest
