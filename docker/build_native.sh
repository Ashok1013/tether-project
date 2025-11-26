#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo ">>> build_native.sh: Starting native build (inside container) ..."
echo "Working dir: $(pwd)"
echo "User: $(id -un) uid=$(id -u) gid=$(id -g)"

# Ensure workspace exists and is writable
WORKSPACE="/workspace"
ARTIFACT_DIR="${WORKSPACE}/build_artifacts"

mkdir -p "${ARTIFACT_DIR}"
chmod 0775 "${ARTIFACT_DIR}" || true

# Update submodules if any
if [ -f .gitmodules ]; then
  echo ">>> Updating git submodules..."
  git submodule update --init --recursive || true
fi

# Ensure cmake exists
if ! command -v cmake >/dev/null 2>&1; then
  echo "ERROR: cmake not found in PATH. Install cmake in Dockerfile."
  exit 2
fi

# Create and enter build dir
BUILD_DIR="${WORKSPACE}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Run project-specific CMake helper if exists (common in mlc-llm)
if [ -f "${WORKSPACE}/cmake/gen_cmake_config.py" ]; then
  echo ">>> Running gen_cmake_config.py..."
  python3 "${WORKSPACE}/cmake/gen_cmake_config.py"
fi

echo ">>> Running cmake configure..."
cmake .. -DCMAKE_BUILD_TYPE=Release

echo ">>> Building (cmake --build) ..."
# Use cmake --build for portability; use parallel jobs if available
if command -v nproc >/dev/null 2>&1; then
  JOBS="$(nproc)"
else
  JOBS=2
fi
cmake --build . --config Release -- -j "${JOBS}"

echo ">>> Build finished. Collecting artifacts..."

# Heuristics: copy any .so, .dll, .a, .lib, .dylib, and executables in build tree
find . -type f \( -name "*.so" -o -name "*.a" -o -name "*.dylib" -o -name "*.dll" -o -name "*.lib" -o -perm -111 \) -print | \
  while read -r file; do
    dst="${ARTIFACT_DIR}/$(basename "${file}")"
    echo "  copying ${file} -> ${dst}"
    cp -av --parents "${file}" "${ARTIFACT_DIR}" || cp -v "${file}" "${ARTIFACT_DIR}" || true
  done

# Also copy any produced "dist" or "python" extension modules if present
if [ -d "${WORKSPACE}/python" ]; then
  # Example: copy built extension modules inside python package (if cmake puts them there)
  find "${WORKSPACE}/python" -type f -name "*.so" -print | while read -r so; do
    echo "  copying python extension ${so} -> ${ARTIFACT_DIR}"
    cp -v "${so}" "${ARTIFACT_DIR}" || true
  done
fi

# Ensure artifact ownership/perm (in case build ran as root previously)
chmod -R a+rX "${ARTIFACT_DIR}" || true

echo ">>> Native build completed. Artifacts at: ${ARTIFACT_DIR}"
ls -la "${ARTIFACT_DIR}" || true

# Keep process running small time so logs are flushed (optional)
sleep 0.2

exit 0
