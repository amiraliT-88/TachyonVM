#!/bin/bash
set -e

# Configuration (Strictly JDK 24)
UPSTREAM_REPO="https://github.com/openjdk/jdk24u.git"
UPSTREAM_BRANCH="master"
WORK_DIR="jdk-src"

echo "building tachyonvm jdk24..."

if [ ! -d "$WORK_DIR" ]; then
    echo "=> Cloning upstream OpenJDK 24 (this might take a while)..."
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

echo "   -> applying c2 compiler tweaks..."
sed -i 's/MaxInlineLevel, 15/MaxInlineLevel, 25/g' src/hotspot/share/opto/c2_globals.hpp
sed -i 's/MaxRecursiveInlineLevel, 1/MaxRecursiveInlineLevel, 3/g' src/hotspot/share/opto/c2_globals.hpp

echo "   -> fixing gcc 15 compat..."
sed -i 's/static inline unsigned int uabs(int n)/\/\/ static inline unsigned int uabs(int n)/g' src/hotspot/share/utilities/globalDefinitions.hpp

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
    --with-boot-jdk=/home/asus/ServerJDK/bootjdk \
    --with-jvm-features=zgc,shenandoahgc \
    --disable-warnings-as-errors \
    --with-source-date="2026-01-01T00:00:00Z" \
    --enable-cds=yes \
    --with-native-debug-symbols=none \
    --with-debug-level=release \
    --with-vendor-name="TachyonVM" \
    --with-vendor-version-string="Asus-Edition" \
    --with-version-pre="tachyon" \
    --with-version-opt="custom"

echo "=> Compiling TachyonVM..."
make images

echo "done!"
echo "image: $WORK_DIR/build/*/images/jdk"
