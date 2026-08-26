import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Une fiche à la corbeille et le temps qu'il lui reste avant purge.
class TrashEntryDto {
  final ContactSummaryDto contact;

  /// Jours restants avant suppression définitive (0 = aujourd'hui).
  final int daysLeft;

  /// Phrase affichée sous le nom (« Suppression définitive dans 12 jours »).
  final String countdown;

  const TrashEntryDto({
    required this.contact,
    required this.daysLeft,
    required this.countdown,
  });
}
