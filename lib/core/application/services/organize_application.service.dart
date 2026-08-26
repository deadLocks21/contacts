import 'package:contacts/core/application/usecases/delete_forever.usecase.dart';
import 'package:contacts/core/application/usecases/export_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/import_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/list_duplicates.usecase.dart';
import 'package:contacts/core/application/usecases/list_trash.usecase.dart';
import 'package:contacts/core/application/usecases/merge_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/purge_expired_trash.usecase.dart';
import 'package:contacts/core/application/usecases/restore_from_trash.usecase.dart';

/// Les cas d'usage de l'onglet « Organiser » : fusionner et corriger,
/// importer/exporter, corbeille.
class OrganizeApplicationService {
  const OrganizeApplicationService({
    required this.listDuplicates,
    required this.merge,
    required this.importVCard,
    required this.exportVCard,
    required this.listTrash,
    required this.restore,
    required this.deleteForever,
    required this.purgeExpired,
  });

  final ListDuplicatesUseCase listDuplicates;
  final MergeContactsUseCase merge;
  final ImportVCardUseCase importVCard;
  final ExportVCardUseCase exportVCard;
  final ListTrashUseCase listTrash;
  final RestoreFromTrashUseCase restore;
  final DeleteForeverUseCase deleteForever;
  final PurgeExpiredTrashUseCase purgeExpired;
}
