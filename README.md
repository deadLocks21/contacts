# Contacts

Réplique de l'application **Google Contacts** en Flutter.

Architecture hexagonale layer-first — voir [ARCHITECTURE.md](ARCHITECTURE.md).

## Lancer

```bash
flutter run                      # appareil connecté
flutter run -d chrome            # web
```

## Qualité

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # codegen Riverpod
```
