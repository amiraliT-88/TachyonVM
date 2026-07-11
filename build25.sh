#!/bin/bash
set -e

# Configuration (Strictly JDK 25)
UPSTREAM_REPO="https://github.com/openjdk/jdk.git"
UPSTREAM_BRANCH="jdk25"
WORK_DIR="jdk25-src"
BOOT_JDK="/home/asus/ServerJDK/jdk-src/build/linux-x86_64-server-release/images/jdk"

echo "building tachyonvm jdk25..."

if [ ! -d "$WORK_DIR" ]; then
    echo "=> Cloning upstream OpenJDK 25 (this might take a while)..."
    git clone --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" "$WORK_DIR"
else
    echo "=> Upstream already cloned. Resetting..."
    cd "$WORK_DIR"
    git reset --hard HEAD
    # git clean -fdx
    cd ..
fi

echo "patching hotspot..."
cd "$WORK_DIR"

# Injecting performance values directly into the C++ source code headers
echo "   -> applying g1gc tweaks..."
sed -i 's/MaxGCPauseMillis, 200/MaxGCPauseMillis, 50/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i 's/G1NewSizePercent, 5/G1NewSizePercent, 35/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1ReservePercent, [0-9]+/G1ReservePercent, 15/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1HeapWastePercent, [0-9]+/G1HeapWastePercent, 2/g' src/hotspot/share/gc/g1/g1_globals.hpp
sed -i -E 's/G1MixedGCCountTarget, [0-9]+/G1MixedGCCountTarget, 4/g' src/hotspot/share/gc/g1/g1_globals.hpp

echo "   -> applying c2 compiler tweaks..."
sed -i 's/MaxInlineLevel, 15/MaxInlineLevel, 25/g' src/hotspot/share/opto/c2_globals.hpp
sed -i 's/MaxRecursiveInlineLevel, 1/MaxRecursiveInlineLevel, 3/g' src/hotspot/share/opto/c2_globals.hpp
sed -i -E 's/InlineSmallCode, [0-9]+/InlineSmallCode, 4000/g' src/hotspot/share/opto/c2_globals.hpp
sed -i -E 's/LoopUnrollLimit, [0-9]+/LoopUnrollLimit, 100/g' src/hotspot/share/opto/c2_globals.hpp

echo "   -> fixing gcc 15 compat..."
# Sometimes JDK 25 fixes this, but it's safe to run sed just in case
sed -i 's/static inline unsigned int uabs(int n)/\/\/ static inline unsigned int uabs(int n)/g' src/hotspot/share/utilities/globalDefinitions.hpp || true

echo "=> Configuring build..."
mkdir -p /home/asus/ServerJDK/bin
echo '#!/bin/bash' > /home/asus/ServerJDK/bin/date
echo 'if [[ "$1" == "--version" ]]; then echo "GNU"; else /usr/bin/date "$@"; fi' >> /home/asus/ServerJDK/bin/date
chmod +x /home/asus/ServerJDK/bin/date
export PATH=/home/asus/ServerJDK/bin:$PATH

bash configure \
    --build=x86_64-unknown-linux-gnu \
    --host=x86_64-unknown-linux-gnu \
    --target=x86_64-unknown-linux-gnu \
    --with-boot-jdk="$BOOT_JDK" \
    --with-jvm-features=zgc,shenandoahgc \
    --disable-warnings-as-errors \
    --with-source-date="2026-01-01T00:00:00Z" \
    --enable-cds=yes \
    --with-native-debug-symbols=none \
    --with-debug-level=release \
    --with-vendor-name="TachyonVM" \
    --with-vendor-version-string="Asus-Edition" \
    --with-version-pre="tachyon" \
    --with-version-opt="custom" \
    --with-extra-cflags="-march=native -mtune=native -O3" \
    --with-extra-cxxflags="-march=native -mtune=native -O3" \
    --with-extra-ldflags="-O3" \
    --enable-headless-only

echo "=> Compiling TachyonVM JDK 25..."
make images

echo "done!"
echo "image: $WORK_DIR/build/*/images/jdk"
