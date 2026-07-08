#!/bin/bash
set -e

UPSTREAM_REPO="https://github.com/openjdk/jdk.git"
UPSTREAM_BRANCH="jdk25"
WORK_DIR="jdk25-src"

echo "========================================"
echo "  Building TachyonVM (Windows JDK 25)   "
echo "========================================"

if [ ! -d "$WORK_DIR" ]; then
    echo "=> Cloning upstream OpenJDK 25..."
    git clone -c core.autocrlf=false --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" "$WORK_DIR"
else
    echo "=> Upstream already cloned. Resetting..."
    cd "$WORK_DIR"
    git reset --hard HEAD
    cd ..
fi

cd "$WORK_DIR"

echo "   -> Injecting EXTREME G1GC optimizations for Minecraft..."
sed -i 's/MaxGCPauseMillis, 200/MaxGCPauseMillis, 50/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i 's/G1NewSizePercent, 5/G1NewSizePercent, 35/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1ReservePercent, [0-9]+/G1ReservePercent, 15/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1HeapWastePercent, [0-9]+/G1HeapWastePercent, 2/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1MixedGCCountTarget, [0-9]+/G1MixedGCCountTarget, 4/g' src/hotspot/share/gc/g1/g1_globals.hpp

echo "   -> Injecting EXTREME C2 Compiler optimizations for Minecraft..."
sed -i 's/MaxInlineLevel, 15/MaxInlineLevel, 25/g' src/hotspot/share/opto/c2_globals.hpp
sed -i 's/MaxRecursiveInlineLevel, 1/MaxRecursiveInlineLevel, 3/g' src/hotspot/share/opto/c2_globals.hpp
sed -i -E 's/InlineSmallCode, [0-9]+/InlineSmallCode, 4000/g' src/hotspot/share/opto/c2_globals.hpp
sed -i -E 's/LoopUnrollLimit, [0-9]+/LoopUnrollLimit, 100/g' src/hotspot/share/opto/c2_globals.hpp

echo "=> Configuring build for Windows (MSVC)..."
# CYGWIN path conversion for the Boot JDK downloaded by GitHub Actions
CYG_BOOT_JDK=$(cygpath -u "$BOOT_JDK")

bash configure \
    --with-boot-jdk="$CYG_BOOT_JDK" \
    --with-toolchain-type=microsoft \
    --with-jvm-features=zgc,shenandoahgc \
    --disable-warnings-as-errors \
    --with-debug-level=release \
    --with-vendor-name="TachyonVM" \
    --with-vendor-version-string="Asus-Edition" \
    --with-version-pre="tachyon" \
    --with-version-opt="custom" \
    --enable-headless-only

echo "=> Compiling TachyonVM JDK 25 for Windows..."
make images

echo "========================================"
echo "=> Windows Build complete!"
