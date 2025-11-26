#!/bin/bash
set -e

echo ">>> Building native MLCLLM libs"

cd /workspace

# Init submodules (needed for MLCLLM)
git submodule update --init --recursive || true

mkdir -p build && cd build

python3 ../cmake/gen_cmake_config.py
cmake .. 
make -j$(nproc)

# Copy output libs to shared artifact location
mkdir -p /workspace/build_artifacts
cp -r * /workspace/build_artifacts/

echo ">>> Native build completed"
