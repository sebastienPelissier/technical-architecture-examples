---
name: apk-extractor
description: Extract and decompile Android APKs from a connected device using adb and Docker-based jadx. Triggers when the user wants to: extract an APK by package name, decompile it to readable Java source, or analyze an app for hardcoded secrets, API endpoints, Room database schemas, or embedded assets. No local Java or jadx installation needed.
---

# APK Extractor & Decompiler

Extract an APK from a connected Android device and decompile it with jadx in Docker.

## Prerequisites

- `adb` in PATH (or pass full path as 3rd script argument)
- Docker daemon running
- Android device connected via USB, USB debugging enabled and **authorized** (`adb devices` shows `device`, not `unauthorized`)

## Run

```bash
./scripts/extract_and_decompile.sh <package> [output_dir] [adb_path]

# Minimal
./scripts/extract_and_decompile.sh com.example.app

# With custom paths
./scripts/extract_and_decompile.sh com.example.app ./out ~/Android/Sdk/platform-tools/adb
```

The script handles everything end to end:

1. Verify adb, Docker, and device status
2. Resolve APK path via `adb shell pm path <package>` — never hardcoded
3. Pull `<package>_base.apk` to output dir (warns if split APK detected)
4. Build `local/jadx` from `scripts/Dockerfile.jadx` if image not present
5. Decompile with `--deobf` → `<output_dir>/jadx_out/`
6. Grep for secrets, Retrofit endpoints, Room entities, embedded assets
7. Write `<output_dir>/findings.md`

## Agent Behavior Rules

**Secrets** — never print values, report file path + line number only.

**Production APK** — warn explicitly if `android:debuggable` is absent from manifest. `run-as`, App Inspection, and Frida attach mode will not work without root.

**Safety** — never push, publish, or transmit the APK or decompiled sources to any external service. Never re-sign or patch the APK unless the user explicitly asks.

**Failures** — if decompilation fails, report jadx stderr and suggest increasing Docker memory (`--memory 4g`). Never silently retry.

## Advanced / Manual Operations

Device setup, manual extraction, APK patching, Frida:
→ [`references/reverse_engineering.md`](references/reverse_engineering.md)
