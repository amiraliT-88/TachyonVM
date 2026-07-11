# ⚡ TachyonVM

TachyonVM is a hyper-optimized, downstream fork of OpenJDK 25 specifically engineered for heavy server workloads, with a strict focus on **Minecraft server performance (Paper, Purpur, Folia)**. 

While generic JVMs (like GraalVM or Temurin) are built to run anywhere, TachyonVM modifies the raw C++ source code of the HotSpot Virtual Machine to default to the absolute most aggressive performance constraints.

## 🚀 Why TachyonVM?

Instead of relying on massive startup flags (like Aikar's flags) to fix JVM behavior, TachyonVM fundamentally rewrites the engine's default DNA:

- **Extreme C2 JIT Compiler Tuning**: 
  - `LoopUnrollLimit` increased to 100: Radically reduces CPU branching during heavy Minecraft game loops (chunk generation, pathfinding).
  - `InlineSmallCode` increased to 4000: Forces the JVM to aggressively merge method calls for maximum single-thread TPS throughput.
- **Aggressive G1GC Tuning**: 
  - `G1ReservePercent` hardcoded to 15%: Creates a massive safety net in RAM to permanently eliminate lag spikes (to-space exhaustion).
  - `G1HeapWastePercent` reduced to 2% for stricter memory management.
- **True Headless Environment**: Compiled with `--enable-headless-only`. TachyonVM physically cannot render graphical interfaces (AWT/Swing), making the `-nogui` flag obsolete and saving precious CPU/RAM.

## 📦 Building from Source

TachyonVM is built differently for Linux and Windows to maximize hardware utilization.

### 🐧 Linux (Hardware-Native Build)
For Linux, TachyonVM is compiled directly against your CPU architecture (`-march=native -O3`). This guarantees the binary utilizes the exact vector instructions (AVX2/AVX-512) your hardware supports.
```bash
dos2unix build25.sh
bash build25.sh
```

### 🪟 Windows (Cloud Build)
We use GitHub Actions to automate the massive Windows compilation process. 
1. Go to the **Actions** tab in this repository.
2. Select **Build TachyonVM (Windows)**.
3. Click **Run workflow**. 
4. Download the `TachyonVM-Win64.zip` artifact when complete.

## 🎮 Recommended Minecraft Startup Flags

Since TachyonVM (Server Edition) handles aggressive C2 Compiler and G1GC optimizations natively at the source level, your server startup script should be exceptionally clean.

**Do NOT use massive flag lists like Aikar's flags** (they will conflict with our source-level DNA edits). Also, because TachyonVM is based on JDK 25, you must include `-DPaper.IgnoreJavaVersion=true` to prevent Paper/Purpur from blocking the startup.

Use the following `start.bat` (Windows) or `start.sh` (Linux) for maximum performance:

```bat
@echo off
title Minecraft Server
set fileName="server.jar"
set /A memory=8144

:start
"C:\Program Files\TachyonVM-Server\bin\java.exe" -DPaper.IgnoreJavaVersion=true -Xms%memory%M -Xmx%memory%M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseG1GC -XX:+PerfDisableSharedMem --add-modules jdk.incubator.vector -jar %fileName% --nogui

echo Restarting in 5 seconds...
echo Press CTRL + C to cancel.
timeout 5
goto :start
```
