# App icon & splash source assets

Drop the designed source images here, then run the generators (see below).
These are **source** files — the per-platform icon/splash assets are generated
into the native `android/` and `ios/` folders and don't need to be committed.

## Required files

| File | Size | Used by |
|------|------|---------|
| `app_icon.png` | 1024×1024, no transparency | iOS + Android legacy launcher icon |
| `app_icon_foreground.png` | 1024×1024, transparent, ~66% safe zone | Android adaptive icon foreground |
| `splash_logo.png` | ~512×512, transparent | Native splash (light + dark) |

Brand background: `#3478F6` (seed) · light splash `#FFFFFF` · dark splash `#0E0E10`.

## Designing the icon

Use the `app-icon` skill to generate the artwork, then export a 1024×1024 PNG
to `app_icon.png` (and a transparent foreground variant to
`app_icon_foreground.png`).

## Generating platform assets

```sh
# Launcher icons (iOS + Android)
dart run flutter_launcher_icons

# Native splash screen (iOS + Android, incl. Android 12+)
dart run flutter_native_splash:create
```

Re-run both whenever the source images change.
