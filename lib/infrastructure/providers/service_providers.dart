import 'package:contacts/core/application/services/contacts_application.service.dart';
import 'package:contacts/core/application/services/labels_application.service.dart';
import 'package:contacts/core/application/services/organize_application.service.dart';
import 'package:contacts/core/application/services/settings_application.service.dart';
import 'package:contacts/core/application/usecases/apply_label.usecase.dart';
import 'package:contacts/core/application/usecases/create_label.usecase.dart';
import 'package:contacts/core/application/usecases/delete_forever.usecase.dart';
import 'package:contacts/core/application/usecases/delete_label.usecase.dart';
import 'package:contacts/core/application/usecases/export_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/get_contact.usecase.dart';
import 'package:contacts/core/application/usecases/import_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/list_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/list_duplicates.usecase.dart';
import 'package:contacts/core/application/usecases/list_highlights.usecase.dart';
import 'package:contacts/core/application/usecases/list_labels.usecase.dart';
import 'package:contacts/core/application/usecases/list_trash.usecase.dart';
import 'package:contacts/core/application/usecases/load_contact_draft.usecase.dart';
import 'package:contacts/core/application/usecases/load_settings.usecase.dart';
import 'package:contacts/core/application/usecases/merge_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/move_to_trash.usecase.dart';
import 'package:contacts/core/application/usecases/purge_expired_trash.usecase.dart';
import 'package:contacts/core/application/usecases/rename_label.usecase.dart';
import 'package:contacts/core/application/usecases/restore_from_trash.usecase.dart';
import 'package:contacts/core/application/usecases/save_contact.usecase.dart';
import 'package:contacts/core/application/usecases/search_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/set_contact_options.usecase.dart';
import 'package:contacts/core/application/usecases/toggle_star.usecase.dart';
import 'package:contacts/core/application/usecases/update_settings.usecase.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

/// Assemblage des cas d'usage du carnet. L'UI ne consomme que ces services :
/// elle ne voit jamais un repository, encore moins son implémentation.
@Riverpod(keepAlive: true)
ContactsApplicationService contactsService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return ContactsApplicationService(
    list: ListContactsUseCase(contacts),
    highlights: ListHighlightsUseCase(contacts),
    get: GetContactUseCase(contacts, labels),
    loadDraft: LoadContactDraftUseCase(contacts),
    save: SaveContactUseCase(contacts, logger),
    search: SearchContactsUseCase(contacts),
    toggleStar: ToggleStarUseCase(contacts, logger),
    moveToTrash: MoveToTrashUseCase(contacts, ref.watch(trashRepositoryProvider), logger),
    setOptions: SetContactOptionsUseCase(contacts, logger),
  );
}

@Riverpod(keepAlive: true)
LabelsApplicationService labelsService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return LabelsApplicationService(
    list: ListLabelsUseCase(labels, contacts),
    create: CreateLabelUseCase(labels, logger),
    rename: RenameLabelUseCase(labels, logger),
    delete: DeleteLabelUseCase(labels, contacts, logger),
    apply: ApplyLabelUseCase(contacts, logger),
  );
}

@Riverpod(keepAlive: true)
OrganizeApplicationService organizeService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  final trash = ref.watch(trashRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return OrganizeApplicationService(
    listDuplicates: ListDuplicatesUseCase(contacts),
    merge: MergeContactsUseCase(contacts, logger),
    importVCard: ImportVCardUseCase(contacts, labels, logger),
    exportVCard: ExportVCardUseCase(contacts, labels, logger),
    listTrash: ListTrashUseCase(trash),
    restore: RestoreFromTrashUseCase(contacts, trash, logger),
    deleteForever: DeleteForeverUseCase(trash, logger),
    purgeExpired: PurgeExpiredTrashUseCase(trash, logger),
  );
}

@Riverpod(keepAlive: true)
SettingsApplicationService settingsService(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsApplicationService(
    load: LoadSettingsUseCase(repository),
    update: UpdateSettingsUseCase(repository, ref.watch(loggerProvider)),
  );
}
