# Reverse Engineering — Reference

Manual operations, device setup, and advanced techniques.

---

## 1. Device Setup

### Enable developer mode
Settings → About phone → tap "Build number" 7 times → USB debugging ON.

Connect via USB → accept "Allow USB debugging" popup on device.

```bash
adb devices
# Expected: <serial>   device
# If unauthorized: re-accept the popup, or revoke and re-grant USB debugging
```

### adb path (if not in PATH)
```bash
# Typical location on Linux
alias adb=~/Android/Sdk/platform-tools/adb
```

---

## 2. Manual APK Extraction

```bash
# Resolve APK path on device
adb shell pm path com.example.app
# Output: package:/data/app/~~xxxx==/com.example.app-xxx==/base.apk

# Pull to local machine
adb pull /data/app/~~xxxx==/com.example.app-xxx==/base.apk ./com.example.app_base.apk
```

**Split APK** — if `pm path` returns multiple lines, only the first (`base.apk`) contains the main code. Additional splits are language/density packs and can be ignored for most analysis.

---

## 3. Manual Decompilation with jadx

```bash
# Build Docker image (only once)
docker build -t local/jadx -f scripts/Dockerfile.jadx scripts/

# Decompile
docker run --rm \
  -v "$(pwd)/com.example.app_base.apk":/input/app.apk:ro \
  -v "$(pwd)/jadx_out":/output \
  local/jadx \
  --deobf \
  --output-dir /output \
  /input/app.apk

# If running out of memory
docker run --rm --memory 4g \
  -v "$(pwd)/com.example.app_base.apk":/input/app.apk:ro \
  -v "$(pwd)/jadx_out":/output \
  local/jadx --deobf --output-dir /output /input/app.apk
```

---

## 4. Manual Analysis Queries

```bash
# Hardcoded secrets (paths + line numbers only — never print values)
grep -rn "API_KEY\|SECRET\|password\|Bearer\|token\|private_key" \
  jadx_out/sources/ --include="*.java" | grep -v "//\|test\|Test\|mock\|Mock"

# 32-char hex keys (potential AES keys)
grep -rEoh "[A-F0-9]{32}" jadx_out/sources/ --include="*.java" | sort -u

# Retrofit endpoints (grouped by HTTP method)
grep -rh "@GET\|@POST\|@PUT\|@DELETE\|@PATCH" \
  jadx_out/sources/ --include="*.java" | grep '"' | sort -u

# Room database files
grep -rl "@Entity\|@Query\|@Database" jadx_out/sources/ --include="*.java"

# Embedded assets
find jadx_out/resources/assets/ -type f | xargs du -sh 2>/dev/null
```

---

## 5. Checking android:debuggable

A production APK does **not** include `android:debuggable="true"` in `AndroidManifest.xml`.
Without this flag: `run-as`, Android Studio App Inspection, and Frida attach mode fail.

```bash
grep 'debuggable' jadx_out/resources/AndroidManifest.xml
# No output = release build (debugging blocked)
# android:debuggable="true" = debug build (full access)
```

---

## 6. Patching an APK to Enable Debugging (non-rooted device)

Use when you need `run-as` or App Inspection on a release APK.

```bash
# Requires: apktool, apksigner, keytool (install via package manager)

# 1. Disassemble
apktool d com.example.app_base.apk -o apktool_out

# 2. Edit AndroidManifest.xml — add to <application> tag:
#    android:debuggable="true"

# 3. Reassemble
apktool b apktool_out -o com.example.app_patched.apk

# 4. Generate a debug keystore (one-time)
keytool -genkeypair -v -keystore debug.keystore -alias androiddebugkey \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=Android Debug,O=Android,C=US"

# 5. Sign
apksigner sign --ks debug.keystore --ks-pass pass:android \
  --key-pass pass:android com.example.app_patched.apk

# 6. Install (uninstall original first if same package)
adb uninstall com.example.app
adb install com.example.app_patched.apk
```

> ⚠️ The patched APK uses a different signature — Google Play Integrity / SafetyNet checks will fail. The app may detect tampering via certificate pinning or root detection.

---

## 7. Frida (requires root or debuggable APK)

Frida attach mode fails on non-rooted devices with a release APK — SELinux blocks cross-uid `ptrace`.

```bash
# Download frida-server matching your frida-tools version and device arch (arm64 most common)
# https://github.com/frida/frida/releases

adb push frida-server /data/local/tmp/frida-server
adb shell chmod 755 /data/local/tmp/frida-server
adb shell "/data/local/tmp/frida-server &"
adb forward tcp:27042 tcp:27042

# Verify
frida-ps -H 127.0.0.1:27042
```

**Why attach fails on non-rooted + release APK:**
- `frida-server` runs as `shell` (different uid from the target app)
- SELinux denies `ptrace` cross-uid without root
- `frida attach` → `unable to access process with pid <X>`

**Alternative — Frida Gadget injection (no root needed):**
Inject `frida-gadget.so` directly into the APK using `objection` or manual smali patching:

```bash
# Using objection (wraps apktool + gadget injection automatically)
pip install objection
objection patchapk --source com.example.app_base.apk

# Install patched APK and connect
adb install com.example.app.objection.apk
frida -U -n Gadget -l your_script.js
```

> The Gadget approach bypasses SELinux restrictions because the library runs in the app's own process.

---

## 8. Upgrading jadx

Check the latest release: https://github.com/skylot/jadx/releases/latest

To upgrade, edit `scripts/Dockerfile.jadx` and update both values:

```dockerfile
ARG JADX_VERSION=x.y.z
ARG JADX_SHA256=<sha256 of jadx-x.y.z.zip from the release page>
```

The SHA256 digest is listed on the release page under the `jadx-x.y.z.zip` asset ("digest: sha256:...").

Then rebuild the image:

```bash
docker build -t local/jadx -f scripts/Dockerfile.jadx scripts/
# Verify
docker run --rm local/jadx --version
```

To force a specific version without editing the Dockerfile:

```bash
docker build --build-arg JADX_VERSION=1.5.5 \
             --build-arg JADX_SHA256=38a5766d3c8170c41566b4b13ea0ede2430e3008421af4927235c2880234d51a \
             -t local/jadx -f scripts/Dockerfile.jadx scripts/
```
