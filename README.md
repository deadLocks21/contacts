# Contacts

Réplique de l'application **Google Contacts** (Android) en Flutter, entièrement
locale : aucun compte, aucun serveur, le carnet ne quitte pas l'appareil.

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
  démarrage.
- Paramètres : tri, format des noms, thème clair/sombre/système.

**Étiquettes**
- Création, renommage, suppression (les contacts sont conservés), filtrage de la
  liste, application en lot.

## Lancer

```bash
flutter run
```

Au tout premier démarrage, un carnet de démonstration est écrit — il ne
réapparaît jamais ensuite.

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
