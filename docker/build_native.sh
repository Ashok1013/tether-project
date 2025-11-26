#!/usr/bin/env bash
set -euo pipefail

echo ">>> build_native.sh: Starting native build (inside container) ..."
echo "Working dir: $(pwd)"
echo "User: $(id -un) uid=$(id -u) gid=$(id -g)"

WORKSPACE="/workspace"
ARTIFACT_DIR="${WORKSPACE}/build_artifacts"
BUILD_DIR="${WORKSPACE}/build"

# 1. FIX GIT SAFE DIRECTORY PROBLEM
git config --global --add safe.directory "${WORKSPACE}"

# Create artifacts folder
mkdir -p "${ARTIFACT_DIR}"

cd "${WORKSPACE}"

echo ">>> Updating git submodules..."
git submodule update --init --recursive || true

echo ">>> Running gen_cmake_config.py (NON-INTERACTIVE)..."

# 2. FIX INTERACTIVE PROMPT (avoid EOFError)
export TVM_SOURCE_DIR=/workspace/3rdparty/tvm
yes "" | python3 cmake/gen_cmake_config.py || true

echo ">>> Configuring CMake..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

cmake .. -DCMAKE_BUILD_TYPE=Release

echo ">>> Building native libs..."
cmake --build . --config Release -- -j"$(nproc)"

echo ">>> Copying artifacts to build_artifacts/ ..."
cp -r "${BUILD_DIR}"/* "${ARTIFACT_DIR}/" || true

echo ">>> Build complete. Artifacts:"
ls -la "${ARTIFACT_DIR}"
