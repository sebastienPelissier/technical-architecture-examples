---
name: apk-extractor
description: Extraire et décompiler des APK Android depuis un device connecté avec adb et jadx via Docker. Déclencher quand l'utilisateur veut : extraire un APK par nom de package, décompiler en source Java lisible, ou analyser une app (secrets hardcodés, endpoints API, schémas Room, assets embarqués). Aucune installation locale de Java ou jadx requise.
---

# APK Extractor & Décompilateur

Extraire un APK depuis un device Android connecté et le décompiler avec jadx dans Docker.

## Prérequis

- `adb` dans le PATH (ou passer le chemin complet en 3ème argument du script)
- Docker daemon lancé
- Device Android connecté en USB, débogage USB activé et **autorisé** (`adb devices` affiche `device`, pas `unauthorized`)

## Lancer

```bash
./scripts/extract_and_decompile.sh <package> [output_dir] [adb_path]

# Minimal
./scripts/extract_and_decompile.sh com.example.app

# Avec chemins personnalisés
./scripts/extract_and_decompile.sh com.example.app ./sortie ~/Android/Sdk/platform-tools/adb
```

Le script gère tout de bout en bout :

1. Vérifier adb, Docker, et l'état du device
2. Résoudre le chemin APK via `adb shell pm path <package>` — jamais en dur
3. Tirer `<package>_base.apk` dans le dossier de sortie (avertit si APK splitté détecté)
4. Construire `local/jadx` depuis `scripts/Dockerfile.jadx` si l'image est absente
5. Décompiler avec `--deobf` → `<output_dir>/jadx_out/`
6. Chercher secrets, endpoints Retrofit, entités Room, assets embarqués
7. Écrire `<output_dir>/findings.md`

## Règles de comportement agent

**Secrets** — ne jamais afficher les valeurs, reporter uniquement chemin du fichier + numéro de ligne.

**APK de production** — avertir explicitement si `android:debuggable` est absent du manifest. `run-as`, App Inspection, et Frida en mode attach ne fonctionneront pas sans root.

**Sécurité** — ne jamais envoyer, publier ou transmettre l'APK ou les sources décompilées vers un service externe. Ne jamais patcher ou resigner l'APK sauf demande explicite de l'utilisateur.

**Échecs** — si la décompilation échoue, reporter la sortie stderr de jadx et suggérer d'augmenter la mémoire Docker (`--memory 4g`). Ne jamais relancer silencieusement.

## Opérations avancées / manuelles

Setup device, extraction manuelle, patch APK, Frida :
→ [`references/reverse_engineering.md`](references/reverse_engineering.md)
