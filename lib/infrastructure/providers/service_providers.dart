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
import 'package:contacts/core/application/usecases/set_contact_photo.usecase.dart';
import 'package:contacts/core/application/usecases/toggle_star.usecase.dart';
import 'package:contacts/core/application/usecases/update_settings.usecase.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

/// Assemblage des cas d'usage du carnet. L'UI ne consomme que ces services :
/// elle ne voit jamais un repository, encore moins son implémentation.
@Riverpod(keepAlive: true)
ContactsApplicationService contactsService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  return ContactsApplicationService(
    list: ListContactsUseCase(contacts),
    get: GetContactUseCase(contacts, labels),
    loadDraft: LoadContactDraftUseCase(contacts),
    save: SaveContactUseCase(contacts),
    search: SearchContactsUseCase(contacts),
    toggleStar: ToggleStarUseCase(contacts),
    moveToTrash: MoveToTrashUseCase(contacts),
    setPhoto: SetContactPhotoUseCase(ref.watch(photoStoreProvider)),
    setOptions: SetContactOptionsUseCase(contacts),
  );
}

@Riverpod(keepAlive: true)
LabelsApplicationService labelsService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  return LabelsApplicationService(
    list: ListLabelsUseCase(labels, contacts),
    create: CreateLabelUseCase(labels),
    rename: RenameLabelUseCase(labels),
    delete: DeleteLabelUseCase(labels, contacts),
    apply: ApplyLabelUseCase(contacts),
  );
}

@Riverpod(keepAlive: true)
OrganizeApplicationService organizeService(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider);
  final labels = ref.watch(labelRepositoryProvider);
  final photos = ref.watch(photoStoreProvider);
  return OrganizeApplicationService(
    listDuplicates: ListDuplicatesUseCase(contacts),
    merge: MergeContactsUseCase(contacts),
    importVCard: ImportVCardUseCase(contacts, labels),
    exportVCard: ExportVCardUseCase(contacts, labels),
    listTrash: ListTrashUseCase(contacts),
    restore: RestoreFromTrashUseCase(contacts),
    deleteForever: DeleteForeverUseCase(contacts, photos),
    purgeExpired: PurgeExpiredTrashUseCase(contacts, photos),
  );
}

@Riverpod(keepAlive: true)
SettingsApplicationService settingsService(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsApplicationService(
    load: LoadSettingsUseCase(repository),
    update: UpdateSettingsUseCase(repository),
  );
}
