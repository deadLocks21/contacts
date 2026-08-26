import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Index alphabétique latéral : les lettres réellement présentes dans la
/// liste. Un appui ou un glissement le long de la bande saute à la section
/// correspondante, une bulle rappelant la lettre visée pendant le geste.
class AlphabetIndex extends StatefulWidget {
  const AlphabetIndex({super.key, required this.letters, required this.onSelected});

  final List<String> letters;

  /// Appelée avec la lettre visée, y compris pendant le glissement.
  final ValueChanged<String> onSelected;

  @override
  State<AlphabetIndex> createState() => _AlphabetIndexState();
}

class _AlphabetIndexState extends State<AlphabetIndex> {
  int? _active;

  void _selectAt(double localY, double height, double slot) {
    if (widget.letters.isEmpty) return;
    // La bande de lettres est centrée verticalement : on ramène l'ordonnée du
    // doigt dans son repère avant d'en déduire la lettre visée.
    final top = (height - slot * widget.letters.length) / 2;
    final index = ((localY - top) / slot).floor().clamp(0, widget.letters.length - 1);
    if (index == _active) return;
    setState(() => _active = index);
    widget.onSelected(widget.letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (widget.letters.length < 2) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // Les lettres se répartissent sur toute la hauteur de la liste, mais
        // la taille du texte reste plafonnée : sans ce plafond, dix lettres sur
        // un grand écran donneraient des capitales géantes par-dessus la liste.
        final slot = height / widget.letters.length;
        final fontSize = (slot - 4).clamp(9.0, 12.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _selectAt(d.localPosition.dy, height, slot),
          onVerticalDragUpdate: (d) => _selectAt(d.localPosition.dy, height, slot),
          onVerticalDragEnd: (_) => setState(() => _active = null),
          onTapUp: (_) => setState(() => _active = null),
          onTapCancel: () => setState(() => _active = null),
          child: SizedBox(
            width: 24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.letters.length; i++)
                  SizedBox(
                    height: slot,
                    child: Center(
                      child: Text(
                        widget.letters[i],
                        style: TextStyle(
                          fontSize: fontSize,
                          height: 1,
                          fontWeight: i == _active ? FontWeight.w700 : FontWeight.w500,
                          color: i == _active ? colors.accent : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
