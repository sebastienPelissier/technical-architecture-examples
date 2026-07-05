# Reverse Engineering — Référence

Opérations manuelles, setup device, et techniques avancées.

---

## 1. Setup du device

### Activer le mode développeur
Paramètres → À propos du téléphone → taper 7x sur "Numéro de build" → Débogage USB activé.

Connecter via USB → accepter la popup "Autoriser le débogage USB" sur le device.

```bash
adb devices
# Attendu : <serial>   device
# Si unauthorized : ré-accepter la popup, ou révoquer et ré-autoriser le débogage USB
```

### Chemin adb (si pas dans le PATH)
```bash
# Emplacement typique sur Linux
alias adb=~/Android/Sdk/platform-tools/adb
```

---

## 2. Extraction manuelle de l'APK

```bash
# Résoudre le chemin de l'APK sur le device
adb shell pm path com.example.app
# Résultat : package:/data/app/~~xxxx==/com.example.app-xxx==/base.apk

# Tirer sur la machine locale
adb pull /data/app/~~xxxx==/com.example.app-xxx==/base.apk ./com.example.app_base.apk
```

**APK splitté** — si `pm path` retourne plusieurs lignes, seul le premier (`base.apk`) contient le code principal. Les splits supplémentaires sont des packs langue/densité, ignorables pour l'analyse.

---

## 3. Décompilation manuelle avec jadx

```bash
# Construire l'image Docker (une seule fois)
docker build -t local/jadx -f scripts/Dockerfile.jadx scripts/

# Décompiler
docker run --rm \
  -v "$(pwd)/com.example.app_base.apk":/input/app.apk:ro \
  -v "$(pwd)/jadx_out":/output \
  local/jadx \
  --deobf \
  --output-dir /output \
  /input/app.apk

# Si manque de mémoire
docker run --rm --memory 4g \
  -v "$(pwd)/com.example.app_base.apk":/input/app.apk:ro \
  -v "$(pwd)/jadx_out":/output \
  local/jadx --deobf --output-dir /output /input/app.apk
```

---

## 4. Requêtes d'analyse manuelle

```bash
# Secrets hardcodés (chemins + numéros de ligne uniquement — ne jamais afficher les valeurs)
grep -rn "API_KEY\|SECRET\|password\|Bearer\|token\|private_key" \
  jadx_out/sources/ --include="*.java" | grep -v "//\|test\|Test\|mock\|Mock"

# Clés hex 32 chars (clés AES potentielles)
grep -rEoh "[A-F0-9]{32}" jadx_out/sources/ --include="*.java" | sort -u

# Endpoints Retrofit (groupés par méthode HTTP)
grep -rh "@GET\|@POST\|@PUT\|@DELETE\|@PATCH" \
  jadx_out/sources/ --include="*.java" | grep '"' | sort -u

# Fichiers Room (base de données)
grep -rl "@Entity\|@Query\|@Database" jadx_out/sources/ --include="*.java"

# Assets embarqués
find jadx_out/resources/assets/ -type f | xargs du -sh 2>/dev/null
```

---

## 5. Vérifier android:debuggable

Un APK de production **ne contient pas** `android:debuggable="true"` dans `AndroidManifest.xml`.
Sans ce flag : `run-as`, Android Studio App Inspection, et Frida en mode attach échouent.

```bash
grep 'debuggable' jadx_out/resources/AndroidManifest.xml
# Pas de résultat = build release (débogage bloqué)
# android:debuggable="true" = build debug (accès complet)
```

---

## 6. Patcher un APK pour activer le débogage (sans root)

Utile quand on a besoin de `run-as` ou App Inspection sur un APK release.

```bash
# Prérequis : apktool, apksigner, keytool (via gestionnaire de paquets)

# 1. Désassembler
apktool d com.example.app_base.apk -o apktool_out

# 2. Éditer AndroidManifest.xml — ajouter dans la balise <application> :
#    android:debuggable="true"

# 3. Réassembler
apktool b apktool_out -o com.example.app_patched.apk

# 4. Générer un keystore de debug (une seule fois)
keytool -genkeypair -v -keystore debug.keystore -alias androiddebugkey \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=Android Debug,O=Android,C=US"

# 5. Signer
apksigner sign --ks debug.keystore --ks-pass pass:android \
  --key-pass pass:android com.example.app_patched.apk

# 6. Installer (désinstaller l'original d'abord si même package)
adb uninstall com.example.app
adb install com.example.app_patched.apk
```

> ⚠️ L'APK patché utilise une signature différente — les vérifications Google Play Integrity / SafetyNet échoueront. L'app peut détecter la modification via certificate pinning ou root detection.

---

## 7. Frida (nécessite root ou APK debuggable)

Frida en mode attach échoue sur device non rooté avec APK release — SELinux bloque `ptrace` cross-uid.

```bash
# Télécharger frida-server correspondant à la version frida-tools et l'archi du device (arm64 le plus courant)
# https://github.com/frida/frida/releases

adb push frida-server /data/local/tmp/frida-server
adb shell chmod 755 /data/local/tmp/frida-server
adb shell "/data/local/tmp/frida-server &"
adb forward tcp:27042 tcp:27042

# Vérifier
frida-ps -H 127.0.0.1:27042
```

**Pourquoi l'attach échoue sur device non rooté + APK release :**
- `frida-server` tourne en tant que `shell` (uid différent de l'app cible)
- SELinux refuse `ptrace` cross-uid sans root
- `frida attach` → `unable to access process with pid <X>`

**Alternative — Injection Frida Gadget (sans root) :**
Injecter `frida-gadget.so` directement dans l'APK via `objection` ou patch smali manuel :

```bash
# Avec objection (automatise apktool + injection gadget)
pip install objection
objection patchapk --source com.example.app_base.apk

# Installer l'APK patché et se connecter
adb install com.example.app.objection.apk
frida -U -n Gadget -l votre_script.js
```

> L'approche Gadget contourne les restrictions SELinux car la librairie s'exécute dans le process de l'app elle-même.

---

## 8. Mettre à jour jadx

Vérifier la dernière version : https://github.com/skylot/jadx/releases/latest

Pour mettre à jour, éditer `scripts/Dockerfile.jadx` et modifier les deux valeurs :

```dockerfile
ARG JADX_VERSION=x.y.z
ARG JADX_SHA256=<sha256 du fichier jadx-x.y.z.zip sur la page de release>
```

Le digest SHA256 est affiché sur la page de release sous l'asset `jadx-x.y.z.zip` ("digest: sha256:...").

Puis reconstruire l'image :

```bash
docker build -t local/jadx -f scripts/Dockerfile.jadx scripts/
# Vérifier
docker run --rm local/jadx --version
```

Pour forcer une version spécifique sans éditer le Dockerfile :

```bash
docker build --build-arg JADX_VERSION=1.5.5 \
             --build-arg JADX_SHA256=38a5766d3c8170c41566b4b13ea0ede2430e3008421af4927235c2880234d51a \
             -t local/jadx -f scripts/Dockerfile.jadx scripts/
```
