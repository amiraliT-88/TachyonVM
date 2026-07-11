# TachyonVM

TachyonVM is a custom fork of OpenJDK 25 optimized specifically for Minecraft servers (Paper, Purpur, Folia).
Instead of using standard JVMs like GraalVM or Temurin, I modified the HotSpot C++ source code to include performance tweaks by default.

## Changes

I didn't want to rely on massive startup flags (like Aikar's flags) anymore, so I applied the changes directly in the JVM:

- **C2 Compiler**: 
  - `LoopUnrollLimit` = 100 for better chunk generation and pathfinding loops.
  - `InlineSmallCode` = 4000 to merge method calls more aggressively.
- **G1GC**: 
  - `G1ReservePercent` = 15% (hardcoded) to prevent to-space exhaustion lag spikes.
  - `MaxGCPauseMillis` = 50 to keep pauses minimal and avoid rubberbanding.
- **Headless**: Compiled with `--enable-headless-only` to save memory since servers don't need UI.

## Build Instructions

### Linux
Compiled with `-march=native -O3` to use your CPU's exact instructions.
```bash
dos2unix build25.sh
bash build25.sh
```

### Windows
Windows builds are done via GitHub Actions:
1. Go to the Actions tab.
2. Run "Build TachyonVM (Windows)".
3. Download the artifact when it's done.

## Startup Flags

Do not use Aikar's flags with this build, they will conflict with the hardcoded edits I made.
You also need `-DPaper.IgnoreJavaVersion=true` because this is based on JDK 25.

Use this `start.bat` (Windows) or `start.sh` (Linux):
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
