#!/bin/bash
set -e

# Configuration (Using LTS JDK 21 for extreme stability and compatibility)
UPSTREAM_REPO="https://github.com/openjdk/jdk21u.git"
UPSTREAM_BRANCH="master"
WORK_DIR="jdk-src"

echo "========================================"
echo "      Building TachyonVM (LTS 21)       "
echo "========================================"

if [ ! -d "$WORK_DIR" ]; then
    echo "=> Cloning upstream OpenJDK 21 (this might take a while)..."
    git clone --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" "$WORK_DIR"
else
    echo "=> Upstream already cloned. Resetting..."
    cd "$WORK_DIR"
    git reset --hard HEAD
    git clean -fdx
    cd ..
fi

echo "=> Applying TachyonVM patches..."
cd "$WORK_DIR"
if [ -d "../patches" ] && [ "$(ls -A ../patches/*.patch 2>/dev/null)" ]; then
    for patch in ../patches/*.patch; do
        echo "   -> Applying $(basename "$patch")"
        # Use dos2unix on the patch file to prevent CRLF issues on Linux
        dos2unix "$patch" || true
        git apply --ignore-whitespace --whitespace=nowarn "$patch" || {
            echo "Failed to apply $patch via git apply. Attempting fallback sed injections..."
            # Fallback sed injections if patch format mismatches slightly due to version differences
            sed -i 's/product(uintx, MaxGCPauseMillis, 200/product(uintx, MaxGCPauseMillis, 50/' src/hotspot/share/gc/g1/g1_globals.hpp
            sed -i 's/product(uintx, G1NewSizePercent, 5/product(uintx, G1NewSizePercent, 35/' src/hotspot/share/gc/g1/g1_globals.hpp
            sed -i 's/product(intx, MaxInlineLevel, 15/product(intx, MaxInlineLevel, 25/' src/hotspot/share/opto/c2_globals.hpp
        }
    done
else
    echo "   -> No patches found in ../patches/"
fi

echo "=> Configuring build..."
bash configure \
    --with-jvm-features=zgc,shenandoah \
    --enable-cds=yes \
    --with-native-debug-symbols=none \
    --with-debug-level=release

echo "=> Compiling TachyonVM..."
make images

echo "========================================"
echo "=> Build complete!"
echo "=> JDK image is located in: $WORK_DIR/build/*/images/jdk"
