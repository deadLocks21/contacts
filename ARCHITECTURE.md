# Architecture — contacts (Flutter)

Architecture **hexagonale, layer-first**, identique à `songbook/app`, `motorz/app`, `kidflix/app`.

## Dépendances

```
UI → Application → Domain ← Infrastructure
```

1. **Domain** (`lib/core/domain/`) ne dépend de personne — Dart pur.
   - ❌ Pas de Riverpod · ❌ pas de Flutter · ❌ pas d'HTTP. ✅ logique métier pure.
   - `model/` : entités (champs `final`, invariants par `assert`, `copyWith`/`==`/`hashCode`
     manuels), value objects (`UuidValue`, `ContactName`), enums avec `wire`/`fromWire`/`label`.
   - `services/` : interfaces de ports (`*.repository.dart`, `*.service.dart`).
2. **Application** (`lib/core/application/`) ne dépend que de Domain — Dart pur.
   - `dtos/` : DTOs (`fromDomain`/`toDomain`/`fromJson`/`toJson`, dates ISO-8601, enums via
     `.name`). **L'UI ne manipule que des DTOs.**
   - `usecases/` : un cas d'usage = une classe `NameUseCase` (ports en dépendances).
   - `services/` : orchestration applicative (regroupement alphabétique, détection de
     doublons, fusion, vCard).
3. **Infrastructure** (`lib/infrastructure/`) ne dépend que de Domain. **Seul lieu de Riverpod.**
   - Implémentations concrètes (`sqflite.*`, `in_memory.*`, `shared_prefs.*`).
   - `providers/` : providers Riverpod (`@riverpod`, `*.g.dart`) — assemblage des dépendances.
4. **UI** (`lib/ui/`) ne dépend que d'Application (et des interfaces Domain via providers).
   - `pages/<feature>/*.page.dart`, `widgets/*.widget.dart`, `providers/*.provider.dart`.
   - `router/` : go_router + `AppRoutes` + `StatefulShellRoute` pour les trois onglets
     (Contacts, Faits marquants, Organiser), chacun gardant sa pile et son défilement.
   - `theme/` : `AppThemeData` + `ContactsPalette` + `AppColors` (ThemeExtension) +
     `context.appColors`.

## Règles

- **Imports absolus** (`package:contacts/...`), jamais de `../`.
- **Modèles écrits à la main** — pas de freezed/json_serializable. `build_runner` seulement pour
  le codegen Riverpod. Lint : `flutter_lints` + `riverpod_lint`.
- Chaque interface a une impl réelle **et** une impl `InMemory*` (tests, repli).
- **Tests** : miroir de `lib/` avec les `InMemory*` comme doublures (pas de mockito).

## Persistance

- **Source de vérité locale** : `sqflite` (init FFI sur desktop). Toutes les lectures viennent
  du local ; l'implémentation mémoire prend le relais si la base ne s'ouvre pas, et sert de
  doublure aux tests.
- IDs = **UUID générés côté client**.
- Suppression **logique** : un contact supprimé part à la corbeille (`deleted_at`) et n'est
  purgé qu'au bout de 30 jours (comme Google Contacts).
- Réglages (tri, format de nom, thème) dans `shared_preferences`.
