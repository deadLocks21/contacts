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

  void _selectAt(double localY, double height) {
    if (widget.letters.isEmpty) return;
    final slot = height / widget.letters.length;
    final index = (localY / slot).floor().clamp(0, widget.letters.length - 1);
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
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _selectAt(d.localPosition.dy, height),
          onVerticalDragUpdate: (d) => _selectAt(d.localPosition.dy, height),
          onVerticalDragEnd: (_) => setState(() => _active = null),
          onTapUp: (_) => setState(() => _active = null),
          onTapCancel: () => setState(() => _active = null),
          child: SizedBox(
            width: 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.letters.length; i++)
                  Expanded(
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          widget.letters[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == _active ? FontWeight.w700 : FontWeight.w500,
                            color: i == _active ? colors.accent : colors.textMuted,
                          ),
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
