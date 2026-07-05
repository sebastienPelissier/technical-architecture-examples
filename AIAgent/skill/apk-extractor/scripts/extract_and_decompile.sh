#!/usr/bin/env bash
# =============================================================================
# extract_and_decompile.sh
# APK Extractor — extract from connected Android device and decompile with jadx
#
# Usage:
#   ./extract_and_decompile.sh <package_name> [output_dir] [adb_path]
#
# Examples:
#   ./extract_and_decompile.sh com.example.app
#   ./extract_and_decompile.sh com.example.app ./output ~/Android/Sdk/platform-tools/adb
# =============================================================================

set -euo pipefail

# ── Parameters ────────────────────────────────────────────────────────────────
PACKAGE="${1:-}"
OUTPUT_DIR="${2:-./apk_output}"
ADB="${3:-adb}"
JADX_IMAGE="local/jadx"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_section() {
    echo -e "\n${BLUE}══════════════════════════════════════${NC}"
    echo -e "${BLUE} $*${NC}"
    echo -e "${BLUE}══════════════════════════════════════${NC}"
}

# ── Argument check ────────────────────────────────────────────────────────────
if [[ -z "$PACKAGE" ]]; then
    log_error "Usage: $0 <package_name> [output_dir] [adb_path]"
    log_error "Example: $0 com.example.app ./output"
    exit 1
fi

APK_OUTPUT="${OUTPUT_DIR}/${PACKAGE}_base.apk"
JADX_OUTPUT="${OUTPUT_DIR}/jadx_out"
FINDINGS="${OUTPUT_DIR}/findings.md"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 1 — Prerequisites
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 1 — Checking prerequisites"

# adb
if ! command -v "$ADB" &>/dev/null; then
    log_error "adb not found at '$ADB'. Pass the full path as 3rd argument."
    exit 1
fi
log_ok "adb: $("$ADB" version | head -1)"

# Docker
if ! docker info &>/dev/null; then
    log_error "Docker is not running or not accessible."
    exit 1
fi
log_ok "Docker: $(docker version --format '{{.Server.Version}}' 2>/dev/null)"

# Device — single call, parse both status and id from the same output
log_info "Checking device..."
DEVICES_OUTPUT=$("$ADB" devices | tail -n +2 | grep -v "^$")

if [[ -z "$DEVICES_OUTPUT" ]]; then
    log_error "No Android device detected. Connect your phone via USB."
    exit 1
fi

DEVICE_STATUS=$(echo "$DEVICES_OUTPUT" | awk '{print $2}' | head -1)
DEVICE_ID=$(echo "$DEVICES_OUTPUT" | awk '{print $1}' | head -1)

if [[ "$DEVICE_STATUS" == "unauthorized" ]]; then
    log_error "Device unauthorized. Accept the 'Allow USB debugging' popup on the device."
    exit 1
elif [[ "$DEVICE_STATUS" != "device" ]]; then
    log_error "Unexpected device state: '$DEVICE_STATUS'"
    exit 1
fi

ANDROID_VERSION=$("$ADB" -s "$DEVICE_ID" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
DEVICE_MODEL=$("$ADB" -s "$DEVICE_ID" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
log_ok "Device: $DEVICE_MODEL (Android $ANDROID_VERSION) — $DEVICE_ID"

mkdir -p "$OUTPUT_DIR"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 2 — Resolve APK path
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 2 — Resolving APK path"

log_info "Looking up '$PACKAGE' on device..."
APK_PATHS=$("$ADB" -s "$DEVICE_ID" shell pm path "$PACKAGE" 2>/dev/null | tr -d '\r') || true

if [[ -z "$APK_PATHS" ]]; then
    log_error "Package '$PACKAGE' not found on device."
    exit 1
fi

PATH_COUNT=$(echo "$APK_PATHS" | grep -c "^package:" || true)
if [[ "$PATH_COUNT" -gt 1 ]]; then
    log_warn "Split APK detected ($PATH_COUNT parts). Pulling base.apk only."
fi

# Extract path and guard against empty result
APK_DEVICE_PATH=$(echo "$APK_PATHS" | grep "^package:" | head -1 | sed 's/^package://')
if [[ -z "$APK_DEVICE_PATH" ]]; then
    log_error "Could not parse APK path from: $APK_PATHS"
    exit 1
fi
log_ok "APK path: $APK_DEVICE_PATH"

# ══════════════════════════════════════════════════════════════════════════════
# STEP 3 — Pull APK
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 3 — Pulling APK"

pull_apk() {
    if ! "$ADB" -s "$DEVICE_ID" pull "$APK_DEVICE_PATH" "$APK_OUTPUT"; then
        log_error "adb pull failed. Check device permissions or available disk space."
        exit 1
    fi
    log_ok "APK saved: $APK_OUTPUT ($(du -sh "$APK_OUTPUT" | awk '{print $1}'))"
}

if [[ -f "$APK_OUTPUT" ]]; then
    log_warn "File already exists: $APK_OUTPUT"
    read -r -p "  Overwrite? [y/N] " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        pull_apk
    else
        log_info "Skipping pull. Using existing file."
    fi
else
    pull_apk
fi

# ══════════════════════════════════════════════════════════════════════════════
# STEP 4 — Build jadx Docker image if needed
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 4 — jadx Docker image"

if docker image inspect "$JADX_IMAGE" &>/dev/null; then
    log_ok "Image '$JADX_IMAGE' already present."
else
    DOCKERFILE="${SCRIPT_DIR}/Dockerfile.jadx"
    if [[ ! -f "$DOCKERFILE" ]]; then
        log_error "Dockerfile.jadx not found: $DOCKERFILE"
        exit 1
    fi
    log_info "Building '$JADX_IMAGE'..."
    docker build -t "$JADX_IMAGE" -f "$DOCKERFILE" "$SCRIPT_DIR"
    log_ok "Image '$JADX_IMAGE' built."
fi

# ══════════════════════════════════════════════════════════════════════════════
# STEP 5 — Decompile
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 5 — Decompiling with jadx"

run_jadx() {
    log_info "Decompiling (may take 1-2 min)..."

    # Capture exit code — set -e does not trigger inside a pipeline
    local jadx_exit=0
    docker run --rm \
        -v "$(realpath "$APK_OUTPUT")":/input/app.apk:ro \
        -v "$(realpath "$JADX_OUTPUT")":/output \
        "$JADX_IMAGE" \
        --deobf \
        --output-dir /output \
        /input/app.apk 2>&1 | tee /tmp/jadx_output.log | tail -5 \
        || jadx_exit=$?

    if [[ $jadx_exit -ne 0 ]]; then
        log_error "jadx failed (exit $jadx_exit). Last output:"
        tail -20 /tmp/jadx_output.log >&2
        log_error "Tip: try increasing Docker memory with --memory 4g in the docker run command."
        exit 1
    fi

    local file_count
    file_count=$(find "$JADX_OUTPUT" -name "*.java" 2>/dev/null | wc -l)
    if [[ "$file_count" -eq 0 ]]; then
        log_warn "Decompilation produced 0 Java files — jadx may have failed silently. Check /tmp/jadx_output.log."
    else
        log_ok "Decompilation complete: $file_count Java files"
    fi
}

# realpath requires the directory to exist
mkdir -p "$JADX_OUTPUT"

if [[ -n "$(ls -A "$JADX_OUTPUT" 2>/dev/null)" ]]; then
    log_warn "jadx_out already exists and is not empty: $JADX_OUTPUT"
    read -r -p "  Re-run decompilation? [y/N] " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm -rf "$JADX_OUTPUT"
        mkdir -p "$JADX_OUTPUT"
        run_jadx
    else
        log_info "Skipping decompilation. Using existing sources."
    fi
else
    run_jadx
fi

# ══════════════════════════════════════════════════════════════════════════════
# STEP 6 — Analysis
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 6 — Analyzing sources"

MANIFEST="${JADX_OUTPUT}/resources/AndroidManifest.xml"

if [[ ! -f "$MANIFEST" ]]; then
    log_warn "AndroidManifest.xml not found — analysis will be partial."
fi

APP_VERSION=$(grep -o 'versionName="[^"]*"' "$MANIFEST" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "unknown")
MIN_SDK=$(grep -o 'minSdkVersion="[^"]*"' "$MANIFEST" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "?")
TARGET_SDK=$(grep -o 'targetSdkVersion="[^"]*"' "$MANIFEST" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "?")
IS_DEBUGGABLE=$(grep -c 'debuggable="true"' "$MANIFEST" 2>/dev/null || echo "0")

# Secrets: file:line only — never include line content
# grep -rn returns "file:line:content" — we strip content with cut
SECRETS=$(grep -rn "ENCRYPTION_KEY\|API_KEY\|SECRET\|Bearer\|private_key\|PASSWORD" \
    "${JADX_OUTPUT}/sources/" --include="*.java" 2>/dev/null \
    | grep -v "//\|test\|Test\|mock\|Mock" \
    | cut -d':' -f1,2 \
    | head -20 || true)

# Hex keys: lowercase + uppercase, deduplicated
HEX_KEYS=$(grep -rEoh "[A-Fa-f0-9]{32}" \
    "${JADX_OUTPUT}/sources/" --include="*.java" 2>/dev/null \
    | sort -u | head -10 || true)

# Retrofit endpoints
ENDPOINTS=$(grep -rh "@GET\|@POST\|@PUT\|@DELETE\|@PATCH" \
    "${JADX_OUTPUT}/sources/" --include="*.java" 2>/dev/null \
    | grep '"' | sort -u | head -40 || true)

# Room files
ROOM_FILES=$(grep -rl "@Entity\|@Query\|@Database" \
    "${JADX_OUTPUT}/sources/" --include="*.java" 2>/dev/null \
    | sed "s|${JADX_OUTPUT}/sources/||g" | head -20 || true)

# Assets
ASSETS=$(find "${JADX_OUTPUT}/resources/assets/" -type f 2>/dev/null \
    | while read -r f; do echo "$(du -sh "$f" | awk '{print $1}')  $f"; done || true)

# ══════════════════════════════════════════════════════════════════════════════
# STEP 7 — Generate findings.md
# ══════════════════════════════════════════════════════════════════════════════
log_section "Step 7 — Generating findings.md"

# Resolve debuggable label once to avoid subshell inside heredoc
if [[ "${IS_DEBUGGABLE}" -gt 0 ]]; then
    DEBUGGABLE_LABEL="⚠️  YES — App Inspection / run-as available"
    DEBUGGABLE_NOTE="- ⚠️ **Debuggable app**: Android Studio App Inspection and \`run-as\` are available"
else
    DEBUGGABLE_LABEL="❌ No — release APK, sandbox access blocked without root"
    DEBUGGABLE_NOTE="- ℹ️ Non-debuggable (release): \`run-as\` and App Inspection will not work"
fi

cat > "$FINDINGS" << EOF
# APK Analysis Findings

**Package**: \`${PACKAGE}\`
**Version**: ${APP_VERSION}
**Device**: ${DEVICE_MODEL} (Android ${ANDROID_VERSION})
**Date**: $(date '+%Y-%m-%d %H:%M')

---

## App Info

| Property | Value |
|----------|-------|
| Package | \`${PACKAGE}\` |
| Version | ${APP_VERSION} |
| minSdkVersion | ${MIN_SDK} |
| targetSdkVersion | ${TARGET_SDK} |
| Debuggable | ${DEBUGGABLE_LABEL} |

---

## Secrets Detected

> ⚠️ Values not shown — file paths and line numbers only

\`\`\`
${SECRETS:-None found}
\`\`\`

### 32-char hex keys (potential AES keys)

\`\`\`
${HEX_KEYS:-None found}
\`\`\`

---

## API Endpoints (Retrofit)

\`\`\`
${ENDPOINTS:-None found}
\`\`\`

---

## Room Database

\`\`\`
${ROOM_FILES:-None found}
\`\`\`

---

## Embedded Assets

\`\`\`
${ASSETS:-None found}
\`\`\`

---

## Security Notes

${DEBUGGABLE_NOTE}
- To access internal data without root: patch the APK with \`android:debuggable="true"\` and re-sign (see references/reverse_engineering.md)
EOF

log_ok "findings.md written: $FINDINGS"

# ══════════════════════════════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════════════════════════════
log_section "Done"
echo ""
echo "  APK      : $APK_OUTPUT"
echo "  Sources  : $JADX_OUTPUT"
echo "  Findings : $FINDINGS"
echo ""
log_ok "All output in: $OUTPUT_DIR"
