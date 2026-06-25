#!/bin/bash
set -e

# Configuration
UPSTREAM_REPO="https://github.com/openjdk/jdk.git"
UPSTREAM_BRANCH="master"
WORK_DIR="jdk-src"

echo "========================================"
echo "      Building ServerJDK                "
echo "========================================"

if [ ! -d "$WORK_DIR" ]; then
    echo "=> Cloning upstream OpenJDK (this might take a while)..."
    git clone --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" "$WORK_DIR"
else
    echo "=> Upstream already cloned. Resetting..."
    cd "$WORK_DIR"
    git reset --hard HEAD
    git clean -fdx
    cd ..
fi

echo "=> Applying ServerJDK patches..."
cd "$WORK_DIR"
if [ -d "../patches" ] && [ "$(ls -A ../patches/*.patch 2>/dev/null)" ]; then
    for patch in ../patches/*.patch; do
        echo "   -> Applying $(basename "$patch")"
        git apply "$patch"
    done
else
    echo "   -> No patches found in ../patches/"
fi

echo "=> Configuring build..."
# Typical optimizations for server builds
bash configure \
    --with-jvm-features=zgc,shenandoah \
    --enable-cds=yes \
    --with-native-debug-symbols=none \
    --with-debug-level=release

echo "=> Compiling ServerJDK..."
make images

echo "========================================"
echo "=> Build complete!"
echo "=> JDK image is located in: $WORK_DIR/build/*/images/jdk"
