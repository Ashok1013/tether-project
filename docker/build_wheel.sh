#!/usr/bin/env bash
set -euo pipefail


# build python wheel using standard pyproject or setup.py
# Assumes code is present in /workspace
cd /workspace
python3 -m pip install --upgrade build
python3 -m build --wheel --no-isolation -o dist


# show results
ls -la dist || true