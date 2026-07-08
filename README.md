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
