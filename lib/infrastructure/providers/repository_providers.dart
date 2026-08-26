import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/infrastructure/contacts/local.contact.repository.dart';
import 'package:contacts/infrastructure/labels/local.label.repository.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) =>
    LocalContactRepository(ref.watch(localRecordStoreProvider));

@Riverpod(keepAlive: true)
LabelRepository labelRepository(Ref ref) =>
    LocalLabelRepository(ref.watch(localRecordStoreProvider));
