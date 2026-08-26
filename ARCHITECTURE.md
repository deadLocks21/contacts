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

## Source de vérité

- **Le carnet d'adresses du système** (`ContactsContract` sur Android, `Contacts` sur iOS), lu
  et écrit via `flutter_contacts` : les fiches sont celles que voient le composeur, la
  messagerie et toutes les autres apps. L'app n'a pas de base de contacts à elle.
- Les **étiquettes** sont les *groupes* du carnet (`Groups` / `CNGroup`). Les groupes
  techniques d'Android (« My Contacts », « Starred in Android ») sont masqués, comme le fait
  Google Contacts.
- Les **identifiants** viennent du carnet : aucun format garanti (cf. `EntityId`).
- Hors mobile (desktop, tests), les implémentations `Local*` tiennent lieu de carnet, adossées
  au store local et alimentées par `DemoSeed`.

## Ce que l'app stocke quand même

- **La corbeille** : le carnet du système n'en a pas. Une fiche supprimée y est recopiée
  (`sqflite`, init FFI sur desktop) puis retirée du carnet, et réinsérée à la restauration —
  le système lui alloue alors un nouvel identifiant. Purge au bout de 30 jours, au démarrage.
- **Les réglages** (tri, format de nom, thème) dans `shared_preferences`.

## Limites assumées de l'adossement

- Les **relations** (« Conjoint : Marie ») n'ont pas d'équivalent exposé par `flutter_contacts` :
  elles voyagent en messagerie au libellé préfixé plutôt que d'être perdues (cf.
  `relationLabelPrefix`).
- Restaurer depuis la corbeille **change l'identifiant** de la fiche : l'ancien a disparu du
  carnet avec elle.
