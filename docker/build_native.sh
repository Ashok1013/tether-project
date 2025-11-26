#!/usr/bin/env bash
set -euo pipefail

echo ">>> build_native.sh: Starting native build (inside container) ..."
echo "Working dir: $(pwd)"
echo "User: $(id -un) uid=$(id -u) gid=$(id -g)"

# FIX 1: Mark workspace safe for git
git config --global --add safe.directory /workspace

WORKSPACE="/workspace"
ARTIFACT_DIR="${WORKSPACE}/build_artifacts"
BUILD_DIR="${WORKSPACE}/build"

mkdir -p "${ARTIFACT_DIR}"

cd "${WORKSPACE}"

echo ">>> Updating git submodules..."
git submodule update --init --recursive || true

echo ">>> Running gen_cmake_config.py..."
export TVM_SOURCE_DIR=/workspace/3rdparty/tvm
yes "" | python3 cmake/gen_cmake_config.py

echo ">>> Configuring CMake..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake .. -DCMAKE_BUILD_TYPE=Release

echo ">>> Building..."
cmake --build . --config Release -- -j"$(nproc)"

echo ">>> Copying built artifacts..."
cp -r * "${ARTIFACT_DIR}/" || true

echo ">>> Build complete. Artifacts stored in build_artifacts/"
ls -la "${ARTIFACT_DIR}"
