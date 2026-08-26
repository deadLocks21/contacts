import 'package:contacts/core/domain/services/contacts_access.service.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

/// Accès au carnet du système, via la demande de permission de la plateforme.
class FlutterContactsAccess implements ContactsAccess {
  const FlutterContactsAccess();

  @override
  Future<bool> request() => fc.FlutterContacts.requestPermission();
}

/// Accès toujours accordé — là où le carnet est simulé, il n'y a rien à
/// autoriser.
class AlwaysGrantedContactsAccess implements ContactsAccess {
  const AlwaysGrantedContactsAccess();

  @override
  Future<bool> request() async => true;
}
