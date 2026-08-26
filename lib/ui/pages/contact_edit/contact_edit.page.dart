import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/pages/contact_edit/widgets/address_and_event_rows.widget.dart';
import 'package:contacts/ui/pages/contact_edit/widgets/edit_rows.widget.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_avatar.widget.dart';
import 'package:contacts/ui/widgets/label_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Le formulaire de création et de modification d'un contact.
///
/// Il travaille sur un [ContactDraft] — un brouillon mutable — et non sur
/// l'entité : tant que « Enregistrer » n'est pas touché, rien n'atteint le
/// carnet, et les lignes laissées vides sont écartées à la conversion.
class ContactEditPage extends ConsumerStatefulWidget {
  const ContactEditPage({super.key, this.contactId, this.labelId});

  /// Nul en création.
  final String? contactId;

  /// Étiquette à pré-cocher quand on crée depuis la vue d'une étiquette.
  final String? labelId;

  @override
  ConsumerState<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends ConsumerState<ContactEditPage> {
  ContactDraft? _draft;
  var _nameExpanded = false;
  var _moreFields = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final draft = await ref.read(contactsServiceProvider).loadDraft.execute(
          contactId: widget.contactId,
          labelIds: {if (widget.labelId != null) widget.labelId!},
        );
    if (mounted) setState(() => _draft = draft);
  }

  bool get _isCreation => widget.contactId == null;

  void _touch() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final draft = _draft;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fermer',
          onPressed: () => context.pop(),
        ),
        title: Text(_isCreation ? 'Créer un contact' : 'Modifier le contact'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const Key('saveContact'),
              onPressed: draft == null || _saving ? null : _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: draft == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  _photo(draft),
                  _labels(draft),
                  const SizedBox(height: 8),
                  ..._nameFields(draft),
                  _text(
                    icon: Icons.business_outlined,
                    label: 'Société',
                    value: draft.company,
                    onChanged: (v) => draft.company = v,
                  ),
                  _text(
                    icon: null,
                    label: 'Poste',
                    value: draft.jobTitle,
                    onChanged: (v) => draft.jobTitle = v,
                  ),
                  const SizedBox(height: 8),
                  ..._phones(draft),
                  ..._emails(draft),
                  if (!_moreFields)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _moreFields = true),
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Autres champs'),
                        ),
                      ),
                    )
                  else
                    ..._moreFieldRows(draft),
                ],
              ),
            ),
    );
  }

  // ------------------------------------------------------------------ photo

  Widget _photo(ContactDraft draft) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ContactAvatar(
              initials: _initialsPreview(draft),
              colorKey: '${draft.first} ${draft.last}',
              photoPath: draft.photoPath,
              size: 112,
            ),
            Material(
              color: colors.accentSoft,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _pickPhoto(draft),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.photo_camera_outlined, size: 20, color: colors.onAccentSoft),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initialsPreview(ContactDraft draft) {
    final f = draft.first.trim();
    final l = draft.last.trim();
    if (f.isNotEmpty && l.isNotEmpty) return '${f[0]}${l[0]}'.toUpperCase();
    final single = [f, l, draft.company.trim()].firstWhere((p) => p.isNotEmpty, orElse: () => '');
    return single.isEmpty ? '' : single[0].toUpperCase();
  }

  Future<void> _pickPhoto(ContactDraft draft) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir une photo'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (draft.photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Supprimer la photo'),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
    if (source == null) {
      // Fermeture sans choix : c'est aussi le chemin de « Supprimer la photo ».
      return;
    }

    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;
    final stored = await ref.read(contactsServiceProvider).setPhoto.execute(
          picked.path,
          contactId: draft.id ?? 'nouveau',
        );
    draft.photoPath = stored;
    _touch();
  }

  // ------------------------------------------------------------- étiquettes

  Widget _labels(ContactDraft draft) {
    final colors = context.appColors;
    final labels = ref.watch(labelListProvider).value ?? const <LabelDto>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final label in labels)
            FilterChip(
              label: Text(label.name),
              selected: draft.labelIds.contains(label.id),
              showCheckmark: true,
              selectedColor: colors.accentSoft,
              onSelected: (selected) {
                if (selected) {
                  draft.labelIds.add(label.id);
                } else {
                  draft.labelIds.remove(label.id);
                }
                _touch();
              },
            ),
          ActionChip(
            avatar: Icon(Icons.add, size: 18, color: colors.accent),
            label: Text('Étiquette', style: TextStyle(color: colors.accent)),
            onPressed: () async {
              final id = await createLabelDialog(context, ref);
              if (id != null) {
                draft.labelIds.add(id);
                _touch();
              }
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------- nom

  List<Widget> _nameFields(ContactDraft draft) => [
    Row(
      children: [
        Expanded(
          child: _text(
            icon: Icons.person_outline,
            label: 'Prénom',
            value: draft.first,
            onChanged: (v) {
              draft.first = v;
              _touch();
            },
          ),
        ),
        IconButton(
          tooltip: _nameExpanded ? 'Réduire' : 'Afficher tous les champs du nom',
          icon: Icon(_nameExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () => setState(() => _nameExpanded = !_nameExpanded),
        ),
      ],
    ),
    _text(
      icon: null,
      label: 'Nom de famille',
      value: draft.last,
      onChanged: (v) {
        draft.last = v;
        _touch();
      },
    ),
    if (_nameExpanded) ...[
      _text(icon: null, label: 'Préfixe', value: draft.prefix, onChanged: (v) => draft.prefix = v),
      _text(icon: null, label: 'Deuxième prénom', value: draft.middle, onChanged: (v) => draft.middle = v),
      _text(icon: null, label: 'Suffixe', value: draft.suffix, onChanged: (v) => draft.suffix = v),
      _text(icon: null, label: 'Surnom', value: draft.nickname, onChanged: (v) => draft.nickname = v),
      _text(
        icon: null,
        label: 'Prénom phonétique',
        value: draft.phoneticFirst,
        onChanged: (v) => draft.phoneticFirst = v,
      ),
      _text(
        icon: null,
        label: 'Nom phonétique',
        value: draft.phoneticLast,
        onChanged: (v) => draft.phoneticLast = v,
      ),
    ],
  ];

  // -------------------------------------------------------- champs libellés

  List<Widget> _phones(ContactDraft draft) => [
    for (var i = 0; i < draft.phones.length; i++)
      EditFieldRow<PhoneType>(
        key: ObjectKey(draft.phones[i]),
        draft: draft.phones[i],
        hint: 'Téléphone',
        icon: Icons.call_outlined,
        showIcon: i == 0,
        keyboardType: TextInputType.phone,
        values: PhoneType.values,
        labelOf: (t) => t.label,
        displayLabel: _labelOf(draft.phones[i], PhoneType.personnalise, (t) => t.label),
        isCustom: (t) => t == PhoneType.personnalise,
        onChanged: _touch,
        onRemove: () => setState(() => draft.phones.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.phones[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter un numéro',
      onPressed: () => setState(() => draft.phones.add(FieldDraft(type: PhoneType.mobile))),
    ),
  ];

  List<Widget> _emails(ContactDraft draft) => [
    for (var i = 0; i < draft.emails.length; i++)
      EditFieldRow<EmailType>(
        key: ObjectKey(draft.emails[i]),
        draft: draft.emails[i],
        hint: 'Adresse e-mail',
        icon: Icons.mail_outline,
        showIcon: i == 0,
        keyboardType: TextInputType.emailAddress,
        values: EmailType.values,
        labelOf: (t) => t.label,
        displayLabel: _labelOf(draft.emails[i], EmailType.personnalise, (t) => t.label),
        isCustom: (t) => t == EmailType.personnalise,
        onChanged: _touch,
        onRemove: () => setState(() => draft.emails.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.emails[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter une adresse e-mail',
      onPressed: () => setState(() => draft.emails.add(FieldDraft(type: EmailType.domicile))),
    ),
  ];

  List<Widget> _moreFieldRows(ContactDraft draft) => [
    for (var i = 0; i < draft.addresses.length; i++)
      EditAddressRow(
        key: ObjectKey(draft.addresses[i]),
        draft: draft.addresses[i],
        showIcon: i == 0,
        onChanged: _touch,
        onRemove: () => setState(() => draft.addresses.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.addresses[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter une adresse',
      onPressed: () => setState(() => draft.addresses.add(AddressDraft())),
    ),
    for (var i = 0; i < draft.events.length; i++)
      EditEventRow(
        key: ObjectKey(draft.events[i]),
        draft: draft.events[i],
        showIcon: i == 0,
        onChanged: _touch,
        onRemove: () => setState(() => draft.events.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.events[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter une date',
      onPressed: () => setState(() => draft.events.add(EventDraft())),
    ),
    for (var i = 0; i < draft.websites.length; i++)
      EditFieldRow<WebsiteType>(
        key: ObjectKey(draft.websites[i]),
        draft: draft.websites[i],
        hint: 'Site Web',
        icon: Icons.link,
        showIcon: i == 0,
        keyboardType: TextInputType.url,
        values: WebsiteType.values,
        labelOf: (t) => t.label,
        displayLabel: _labelOf(draft.websites[i], WebsiteType.personnalise, (t) => t.label),
        isCustom: (t) => t == WebsiteType.personnalise,
        onChanged: _touch,
        onRemove: () => setState(() => draft.websites.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.websites[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter un site Web',
      onPressed: () => setState(() => draft.websites.add(FieldDraft(type: WebsiteType.profil))),
    ),
    for (var i = 0; i < draft.relations.length; i++)
      EditFieldRow<RelationType>(
        key: ObjectKey(draft.relations[i]),
        draft: draft.relations[i],
        hint: 'Nom de la personne',
        icon: Icons.people_outline,
        showIcon: i == 0,
        values: RelationType.values,
        labelOf: (t) => t.label,
        displayLabel: _labelOf(draft.relations[i], RelationType.personnalise, (t) => t.label),
        isCustom: (t) => t == RelationType.personnalise,
        onChanged: _touch,
        onRemove: () => setState(() => draft.relations.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.relations[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter une relation',
      onPressed: () => setState(() => draft.relations.add(FieldDraft(type: RelationType.ami))),
    ),
    for (var i = 0; i < draft.chats.length; i++)
      EditFieldRow<ChatType>(
        key: ObjectKey(draft.chats[i]),
        draft: draft.chats[i],
        hint: 'Chat',
        icon: Icons.forum_outlined,
        showIcon: i == 0,
        values: ChatType.values,
        labelOf: (t) => t.label,
        displayLabel: _labelOf(draft.chats[i], ChatType.personnalise, (t) => t.label),
        isCustom: (t) => t == ChatType.personnalise,
        onChanged: _touch,
        onRemove: () => setState(() => draft.chats.removeAt(i)),
        onCustomLabel: () => _askCustomLabel(draft.chats[i].customLabel),
      ),
    AddFieldButton(
      label: 'Ajouter un chat',
      onPressed: () => setState(() => draft.chats.add(FieldDraft(type: ChatType.hangouts))),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(Icons.sticky_note_2_outlined,
                  size: 22, color: context.appColors.textMuted),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: draft.notes,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Notes'),
              onChanged: (v) => draft.notes = v,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    ),
  ];

  /// Libellé affiché par le sélecteur : l'intitulé personnalisé quand il y en
  /// a un, le libellé du type sinon.
  String _labelOf<T>(FieldDraft<T> field, T customValue, String Function(T) labelOf) =>
      field.type == customValue && field.customLabel.trim().isNotEmpty
          ? field.customLabel.trim()
          : labelOf(field.type);

  Future<String?> _askCustomLabel(String initial) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Libellé personnalisé'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex. : Maison de campagne'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  // ------------------------------------------------------------ champ texte

  Widget _text({
    required IconData? icon,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: icon == null ? null : Icon(icon, size: 22, color: colors.textMuted),
          ),
          Expanded(
            child: TextFormField(
              initialValue: value,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: label),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- enregistrement

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(contactsServiceProvider).save.execute(draft);
      if (router.canPop()) router.pop();
    } on BlankContactException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
