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

echo "=> Applying TachyonVM Source Modifications..."
cd "$WORK_DIR"

# Injecting performance values directly into the C++ source code headers
echo "   -> Injecting G1GC optimizations..."
sed -i 's/MaxGCPauseMillis, 200/MaxGCPauseMillis, 50/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i 's/G1NewSizePercent, 5/G1NewSizePercent, 35/g' src/hotspot/share/gc/g1/g1_globals.hpp

echo "   -> Injecting C2 Compiler optimizations..."
sed -i 's/MaxInlineLevel, 15/MaxInlineLevel, 25/g' src/hotspot/share/opto/c2_globals.hpp
sed -i 's/MaxRecursiveInlineLevel, 1/MaxRecursiveInlineLevel, 3/g' src/hotspot/share/opto/c2_globals.hpp

echo "=> Configuring build..."
bash configure \
    --with-jvm-features=zgc,shenandoahgc \
    --enable-cds=yes \
    --with-native-debug-symbols=none \
    --with-debug-level=release

echo "=> Compiling TachyonVM..."
make images

echo "========================================"
echo "=> Build complete!"
echo "=> JDK image is located in: $WORK_DIR/build/*/images/jdk"
