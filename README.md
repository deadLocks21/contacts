# Contacts

Réplique de l'application **Google Contacts** (Android) en Flutter, adossée au
**carnet d'adresses du système** : les fiches affichées et modifiées sont les
vrais contacts de l'appareil, ceux que voient le composeur et la messagerie.
Aucun compte, aucun serveur : le carnet ne quitte pas l'appareil. Seul le
**journal applicatif** peut sortir, vers Signoz, si le build a été configuré pour
— et il ne transporte ni nom, ni numéro, ni adresse (cf. [Observabilité](#observabilité)).

Architecture hexagonale layer-first, identique à `songbook/app`, `motorz/app` et
`kidflix/app` — voir [ARCHITECTURE.md](ARCHITECTURE.md).

## Fonctionnalités

**Carnet**
- Liste alphabétique à sections, index latéral pour sauter à une lettre, tri par
  prénom ou nom de famille, format d'affichage « Jean Martin » ou « Martin, Jean ».
- Fiche complète : téléphones, e-mails, adresses postales, sites, dates
  importantes, relations, messageries, notes — chaque ligne avec son libellé,
  personnalisable. Les listes de libellés reprennent celles de Google.
- Formulaire d'édition : bloc nom dépliable (préfixe, deuxième prénom, suffixe,
  surnom, phonétique), photo, « Autres champs », étiquettes.
- Actions rapides depuis la fiche : appeler, SMS, e-mail, itinéraire, site web,
  partage au format vCard.
- Sélection multiple par appui long : favoris, étiquettes, partage, corbeille.

**Faits marquants**
- Favoris, anniversaires des 30 prochains jours (avec l'âge atteint), fiches
  récemment ajoutées ou modifiées.

**Organiser**
- Fusionner et corriger : détection des doublons par e-mail, numéro ou nom, et
  fusion sans perte d'information.
- Import et export vCard 3.0 (libellés personnalisés et étiquettes compris).
- Corbeille : 30 jours de rétention, restauration, purge automatique au
  démarrage. Le carnet du système n'ayant pas de corbeille, la fiche y est
  recopiée localement avant d'en être retirée.
- Paramètres : tri, format des noms, thème clair/sombre/système.

**Étiquettes**
- Création, renommage, suppression (les contacts sont conservés), filtrage de la
  liste, application en lot.

## Lancer

```bash
flutter run
```

Sur mobile, l'app demande l'accès au carnet d'adresses au premier lancement.
Sur desktop, où il n'y a pas de carnet système, elle tourne sur un carnet
simulé écrit au premier démarrage — de quoi travailler l'UI sans téléphone.

## Observabilité

L'app tient un journal — ce qu'elle fait, et surtout ce qui rate — expédié à
**Signoz** en OTLP/HTTP. Sans point d'entrée configuré, tout reste dans la
console de développement : Signoz est une option du build, jamais une dépendance
au démarrage.

```bash
# Développement, contre un collecteur local
flutter run \
  --dart-define=SIGNOZ_INGEST_URL=http://localhost:4318/v1/logs

# Émulateur Android → collecteur sur la machine hôte
flutter run \
  --dart-define=SIGNOZ_INGEST_URL=http://10.0.2.2:4318/v1/logs

# Build de release, vers Signoz Cloud
flutter build appbundle --release \
  --dart-define=SIGNOZ_INGEST_URL=https://ingest.eu.signoz.cloud:443/v1/logs \
  --dart-define=SIGNOZ_INGESTION_KEY="$SIGNOZ_INGESTION_KEY" \
  --dart-define=APP_VERSION="$VERSION+$BUILD_NUMBER"
```

| `--dart-define`         | Rôle                                                         |
|-------------------------|--------------------------------------------------------------|
| `SIGNOZ_INGEST_URL`     | Point d'entrée OTLP. **Vide = Signoz débranché.**            |
| `SIGNOZ_INGESTION_KEY`  | Jeton Signoz Cloud. Inutile en auto-hébergé sans authentification. |
| `SIGNOZ_ENV`            | Force `deployment.environment` (défaut : `production` en release). |
| `APP_VERSION`           | Devient `service.version` — filtrer par version de l'app.    |

En build de développement **avec** un point d'entrée, chaque ligne part vers
Signoz **et** dans la console, préfixée `[→signoz]` : ce qu'on lit en local est
exactement ce qui arrive là-bas.

### Ce qu'on y trouve

Chaque ligne porte les attributs de ressource `service.name`, `service.version`,
`deployment.environment`, `os.type` et `contacts.backend` (`device` sur mobile,
`local` sur le carnet simulé), plus l'écran affiché au moment de l'écriture
(`app.route`).

- **Erreurs non rattrapées** — `flutter.error` (framework), `dart.uncaught`
  (asynchrone), `provider.failed` (toute lecture qui échoue : la liste, une
  fiche, la recherche, l'amorçage) avec le nom du provider fautif. Une erreur
  part **sans attendre** la minuterie de 10 s, et emporte avec elle ce qui
  patientait : ce qui précède une panne est ce qu'on veut lire, et un plantage
  natif juste après emporterait le tampon. Restent hors de portée, faute de
  gestionnaire natif : les plantages Swift/Obj-C et JVM.
- **Le carnet du système qui refuse** — `contacts.permission.denied`,
  `contacts.backend.failed` et `labels.backend.failed`, avec l'opération.
- **Échecs silencieux à l'écran** — `action.unsupported` (aucune app pour
  composer, écrire, ouvrir une carte), `vcard.import.unreadable`,
  `store.open_failed` (base locale illisible : la corbeille repart vide).
- **Ce que fait l'app** — `app.started`, `app.bootstrap`, `app.lifecycle`,
  `app.route`, `contact.saved`, `contact.trashed`, `trash.restored`,
  `trash.purged`, `contacts.merged`, `vcard.imported`, `label.created`,
  `settings.updated`…

### Ce qu'on n'y trouve pas

Ni nom, ni numéro, ni e-mail, ni adresse, ni note : **aucun contenu de fiche**.
Le journal ne transporte que des identifiants, des compteurs et des schémas
d'URI (`tel`, `mailto`, `geo`). C'est une règle, pas un usage — un test la
vérifie (`test/core/application/usecases/usecase_logging_test.dart`).

Le réseau sortant n'est déclaré que pour cela : `INTERNET` sur Android,
`com.apple.security.network.client` sur macOS. Un point d'entrée en `http://`
sur iOS demanderait en plus une exception ATS — la configuration de
développement, donc, pas celle qu'on livre.

## Qualité

```bash
flutter analyze
flutter test
dart format --line-length 100 lib test
dart run build_runner build   # codegen Riverpod
```

## Plateformes

Android, iOS et macOS. Le web n'est pas visé : le carnet s'appuie sur `sqflite`
et le système de fichiers (photos, export `.vcf`), que `dart:io` ne fournit pas
au navigateur.
