/// Exceptions métier du carnet d'adresses.
sealed class ContactException implements Exception {
  const ContactException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// L'identifiant demandé ne correspond à aucune fiche.
class ContactNotFoundException extends ContactException {
  const ContactNotFoundException(this.id) : super('Contact introuvable : $id');

  final String id;
}

/// Enregistrement d'un formulaire qui ne contient rien d'affichable.
class BlankContactException extends ContactException {
  const BlankContactException() : super('Un contact doit avoir au moins un champ renseigné');
}

/// Une étiquette porte déjà ce nom (comparaison insensible à la casse).
class LabelAlreadyExistsException extends ContactException {
  const LabelAlreadyExistsException(this.name) : super('L\'étiquette « $name » existe déjà');

  final String name;
}

/// L'identifiant demandé ne correspond à aucune étiquette.
class LabelNotFoundException extends ContactException {
  const LabelNotFoundException(this.id) : super('Étiquette introuvable : $id');

  final String id;
}

/// Le fichier vCard fourni est illisible.
class VCardParseException extends ContactException {
  const VCardParseException(super.message);
}
