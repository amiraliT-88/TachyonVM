# TachyonVM ⚡

TachyonVM is a high-performance, downstream fork of OpenJDK specifically tuned for heavy server workloads, particularly Minecraft servers (Paper, Purpur, Fabric) and high-throughput networking applications.

## Why TachyonVM?
Default JDK distributions (like Eclipse Temurin, Oracle JDK, or standard OpenJDK) are built to be general-purpose. They balance footprint, startup time, and throughput for a wide variety of applications, from GUI tools to embedded devices.

TachyonVM strips away generic heuristics. It enforces aggressive Garbage Collection (GC) behavior and JIT compiler optimizations directly at the HotSpot C++ level. This dramatically reduces latency spikes and CPU overhead for server applications that generate massive amounts of short-lived objects.

### Core Modifications
* **Aggressive C2 Inlining**: Increased `MaxInlineLevel` and `InlineSmallCode` thresholds. Deeply nested game loops and physics engines compile to native machine code much more effectively.
* **GC Tuning (G1 & ZGC)**: Hardcoded pause-time goals and young-generation scaling to handle millions of short-lived objects (e.g., Voxel `BlockPos` structures) per second without choking the main thread.
* **Math Intrinsics**: Forced AVX/AVX2 hardware utilization for trigonometric functions used heavily in spatial algorithms, collision detection, and chunk generation.

## Building from Source

### Prerequisites
* Linux (Debian/Ubuntu/Arch) or WSL2 on Windows
* GCC/Clang Toolchain, `make`, `autoconf`, `unzip`, `zip`
* A Boot JDK (JDK 23 or 24)

### Build Instructions
```bash
git clone https://github.com/amiraliT-88/TachyonVM.git
cd TachyonVM
chmod +x build.sh
./build.sh
```

This script will automatically pull the upstream OpenJDK 24 repository, apply the TachyonVM HotSpot patches cleanly, and compile the JVM. The resulting JDK image can be used as a drop-in replacement for your server startup scripts.
