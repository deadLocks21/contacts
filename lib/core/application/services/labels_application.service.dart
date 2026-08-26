import 'package:contacts/core/application/usecases/apply_label.usecase.dart';
import 'package:contacts/core/application/usecases/create_label.usecase.dart';
import 'package:contacts/core/application/usecases/delete_label.usecase.dart';
import 'package:contacts/core/application/usecases/list_labels.usecase.dart';
import 'package:contacts/core/application/usecases/rename_label.usecase.dart';

/// Les cas d'usage des étiquettes.
class LabelsApplicationService {
  const LabelsApplicationService({
    required this.list,
    required this.create,
    required this.rename,
    required this.delete,
    required this.apply,
  });

  final ListLabelsUseCase list;
  final CreateLabelUseCase create;
  final RenameLabelUseCase rename;
  final DeleteLabelUseCase delete;
  final ApplyLabelUseCase apply;
}
