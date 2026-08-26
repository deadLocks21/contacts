import 'package:contacts/core/application/usecases/get_contact.usecase.dart';
import 'package:contacts/core/application/usecases/list_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/list_highlights.usecase.dart';
import 'package:contacts/core/application/usecases/load_contact_draft.usecase.dart';
import 'package:contacts/core/application/usecases/move_to_trash.usecase.dart';
import 'package:contacts/core/application/usecases/save_contact.usecase.dart';
import 'package:contacts/core/application/usecases/search_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/set_contact_options.usecase.dart';
import 'package:contacts/core/application/usecases/toggle_star.usecase.dart';

/// Les cas d'usage du carnet lui-même — lecture, édition, favoris, corbeille.
/// L'UI consomme ce service, jamais les repositories.
class ContactsApplicationService {
  const ContactsApplicationService({
    required this.list,
    required this.highlights,
    required this.get,
    required this.loadDraft,
    required this.save,
    required this.search,
    required this.toggleStar,
    required this.moveToTrash,
    required this.setOptions,
  });

  final ListContactsUseCase list;
  final ListHighlightsUseCase highlights;
  final GetContactUseCase get;
  final LoadContactDraftUseCase loadDraft;
  final SaveContactUseCase save;
  final SearchContactsUseCase search;
  final ToggleStarUseCase toggleStar;
  final MoveToTrashUseCase moveToTrash;
  final SetContactOptionsUseCase setOptions;
}
