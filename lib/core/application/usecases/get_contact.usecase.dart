import 'package:contacts/core/application/dtos/contact_detail.dto.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// La fiche complète d'un contact, étiquettes résolues.
/// Renvoie `null` si la fiche n'existe plus (supprimée depuis un autre écran).
class GetContactUseCase {
  const GetContactUseCase(this._contacts, this._labels);

  final ContactRepository _contacts;
  final LabelRepository _labels;

  Future<ContactDetailDto?> execute(String id, {required AppSettings settings}) async {
    final contact = await _contacts.getById(id);
    if (contact == null) return null;
    return ContactMapper.detail(
      contact,
      nameFormat: settings.nameFormat,
      allLabels: await _labels.listAll(),
    );
  }
}
