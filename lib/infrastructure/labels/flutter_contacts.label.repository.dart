import 'dart:async';

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

/// Étiquettes du carnet du système.
///
/// Ce que Google Contacts appelle « étiquette » est un **groupe** du carnet
/// d'adresses (`Groups` sur Android, `CNGroup` sur iOS) : les mêmes que voient
/// les autres applications. L'app n'a donc pas sa propre notion d'étiquette.
///
/// Le carnet ne datant pas ses groupes, les dates portées par le modèle sont
/// celles de la lecture : elles ne servent qu'à l'ordre d'affichage, lui-même
/// alphabétique.
class FlutterContactsLabelRepository implements LabelRepository {
  FlutterContactsLabelRepository(this._logger) {
    _listener = () => _bump();
    fc.FlutterContacts.addListener(_listener);
  }

  final LoggerApplicationService _logger;
  final _controller = StreamController<int>.broadcast();
  late final void Function() _listener;
  var _revision = 0;

  void _bump() => _controller.add(++_revision);

  void dispose() {
    fc.FlutterContacts.removeListener(_listener);
    _controller.close();
  }

  @override
  Stream<int> get changes => _controller.stream;

  /// Groupes techniques du carnet Android, que Google Contacts ne montre pas :
  /// « My Contacts » est le groupe d'appartenance par défaut, et « Starred in
  /// Android » le miroir de l'étoile des favoris, déjà exposée ailleurs. Les
  /// afficher comme étiquettes donnerait deux cases à cocher sans effet
  /// compréhensible.
  static const _systemGroups = {'my contacts', 'starred in android'};

  /// Journalise puis relance ce que le carnet refuse. Les groupes échouent pour
  /// leurs propres raisons — un compte qui n'accepte pas qu'on en crée, par
  /// exemple — et « l'étiquette ne s'enregistre pas » n'a sinon aucune trace.
  Future<T> _guard<T>(
    String operation,
    Future<T> Function() body, {
    Map<String, Object?> attrs = const {},
  }) async {
    try {
      return await body();
    } catch (e, st) {
      await _logger.error(
        'labels.backend.failed',
        attrs: {'operation': operation, ...attrs},
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<ContactLabel>> listAll() async {
    if (!await fc.FlutterContacts.requestPermission(readonly: true)) return const [];
    return _guard('listAll', () async {
      final groups = await fc.FlutterContacts.getGroups();
      final now = DateTime.now();
      return [
        for (final g in groups)
          if (g.name.trim().isNotEmpty && !_systemGroups.contains(g.name.trim().toLowerCase()))
            ContactLabel(id: EntityId(g.id), name: g.name, createdAt: now, updatedAt: now),
      ];
    });
  }

  @override
  Future<ContactLabel?> getById(String id) async {
    final labels = await listAll();
    return labels.where((l) => l.id.value == id).firstOrNull;
  }

  @override
  Future<void> save(ContactLabel label) async {
    if (!await fc.FlutterContacts.requestPermission()) return;
    await _guard('save', attrs: {'label.id': label.id.value}, () async {
      final groups = await fc.FlutterContacts.getGroups();
      final existing = groups.where((g) => g.id == label.id.value).firstOrNull;
      if (existing == null) {
        await fc.FlutterContacts.insertGroup(fc.Group('', label.name));
      } else {
        await fc.FlutterContacts.updateGroup(fc.Group(existing.id, label.name));
      }
      _bump();
    });
  }

  @override
  Future<void> delete(String id) async {
    if (!await fc.FlutterContacts.requestPermission()) return;
    await _guard('delete', attrs: {'label.id': id}, () async {
      await fc.FlutterContacts.deleteGroup(fc.Group(id, ''));
      _bump();
    });
  }
}
