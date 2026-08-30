<div align="center">
  <img src="banner.png" alt="TachyonVM Banner" width="100%" />

  # TachyonVM
  
  **A high-performance, custom OpenJDK 25 build aggressively tuned for low-latency Minecraft servers.**
  
  <p>
    <img src="https://img.shields.io/badge/OpenJDK-25-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" />
    <img src="https://img.shields.io/badge/Language-C%2B%2B-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" />
    <img src="https://img.shields.io/badge/Optimized_For-Paper%20%7C%20Purpur%20%7C%20Folia-6B46C1?style=for-the-badge" />
    <img src="https://img.shields.io/badge/Target-Low%20Latency-00C853?style=for-the-badge" />
  </p>
</div>

---

TachyonVM is a custom fork of OpenJDK 25 optimized specifically for high-load Minecraft servers (Paper, Purpur, Folia).
Instead of relying on massive startup flags (like Aikar's flags), I modified the **HotSpot C++ source code** directly to embed aggressive performance tweaks and GC optimizations at compile-time.

---

## ⚡ Core HotSpot Optimizations

| Parameter | Standard OpenJDK | TachyonVM (Hardcoded) | Performance Impact |
| :--- | :--- | :--- | :--- |
| **`LoopUnrollLimit`** | `Default (~50)` | `100` | Significantly accelerates chunk generation and pathfinding loops. |
| **`InlineSmallCode`** | `Default (~2000)` | `4000` | Inlines critical method calls aggressively, reducing call stack overhead. |
| **`G1ReservePercent`** | `10%` | `15%` | Prevents to-space exhaustion lag spikes during heavy world load. |
| **`MaxGCPauseMillis`** | `200ms` | `50ms` | Keeps GC pauses negligible to completely eliminate rubberbanding. |
| **`Headless Mode`** | `Disabled` | `--enable-headless-only` | Strips unused graphical/UI code to free up valuable RAM for server tasks. |

---

## 🚀 Build Instructions

### Linux (Native CPU Tuning)
Compiled with `-march=native -O3` to leverage your CPU's exact instruction set:
```bash
dos2unix build25.sh
bash build25.sh
```

### Windows (Automated GitHub Actions)
Pre-compiled Windows builds are handled via CI:
1. Go to the **Actions** tab.
2. Run **"Build TachyonVM (Windows)"**.
3. Download the release artifact.

---

## ⚙️ Recommended Startup Script

> [!IMPORTANT]
> **Do not use Aikar's flags** with this build — they will conflict with the hardcoded HotSpot modifications. 
> You also need `-DPaper.IgnoreJavaVersion=true` since this runtime is based on JDK 25.

### `start.bat` (Windows) / `start.sh` (Linux)
```bat
@echo off
title server
set fileName="server.jar"
set /A memory=8144

:start
"C:\Program Files\TachyonVM-Server\bin\java.exe" -DPaper.IgnoreJavaVersion=true -Xms%memory%M -Xmx%memory%M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseG1GC -XX:+PerfDisableSharedMem --add-modules jdk.incubator.vector -jar %fileName% --nogui

echo Restarting in 5 seconds...
timeout 5
goto :start
```
