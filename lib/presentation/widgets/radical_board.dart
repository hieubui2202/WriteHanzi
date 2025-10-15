import 'package:flutter/material.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/pages/practice_style.dart';

class RadicalBoard extends StatefulWidget {
  const RadicalBoard({
    super.key,
    required this.layout,
    required this.slots,
    required this.choices,
    this.onStateChanged,
    this.onMistake,
  });

  final String layout;
  final List<CharacterPart> slots;
  final List<CharacterPart> choices;
  final ValueChanged<bool>? onStateChanged;
  final VoidCallback? onMistake;

  @override
  State<RadicalBoard> createState() => _RadicalBoardState();
}

class _RadicalBoardState extends State<RadicalBoard> {
  late Map<String, CharacterPart?> _placements;
  late Set<String> _used;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant RadicalBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slots != widget.slots) {
      _reset();
    }
  }

  void _reset() {
    _placements = {for (final slot in widget.slots) slot.id: null};
    _used = <String>{};
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151A21),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10, width: 1.5),
            ),
            padding: const EdgeInsets.all(20),
            child: _buildLayout(),
          ),
        ),
        const SizedBox(height: 16),
        _buildChoices(),
      ],
    );
  }

  Widget _buildLayout() {
    switch (widget.layout) {
      case 'top-bottom':
        return Column(
          children: widget.slots.map((slot) => Expanded(child: _buildSlot(slot))).toList(),
        );
      case 'left-right':
        return Row(
          children: widget.slots.map((slot) => Expanded(child: _buildSlot(slot))).toList(),
        );
      case 'enclose':
        if (widget.slots.isEmpty) {
          return const SizedBox.shrink();
        }
        final outer = widget.slots.first;
        final inner = widget.slots.skip(1).toList();
        return Stack(
          children: [
            Positioned.fill(child: _buildSlot(outer)),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: inner
                    .map((slot) => SizedBox(height: 120, child: _buildSlot(slot)))
                    .toList(),
              ),
            ),
          ],
        );
      default:
        return Column(
          children: widget.slots.map((slot) => Expanded(child: _buildSlot(slot))).toList(),
        );
    }
  }

  Widget _buildSlot(CharacterPart slot) {
    final placed = _placements[slot.id];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DragTarget<CharacterPart>(
        onWillAccept: (data) => placed == null,
        onAccept: (data) {
          if (data.id == slot.id) {
            setState(() {
              _placements[slot.id] = data;
              _used.add(data.id);
            });
            _notify();
          } else {
            widget.onMistake?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sai vị trí rồi, thử lại nhé!'),
                duration: Duration(milliseconds: 500),
              ),
            );
          }
        },
        builder: (context, candidate, rejected) {
          final isActive = candidate.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isActive
                  ? practicePrimary.withOpacity(0.1)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: placed != null
                    ? practicePrimary
                    : isActive
                        ? practicePrimary.withOpacity(0.6)
                        : Colors.white24,
                width: 2.4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    placed?.label ?? slot.label,
                    textAlign: TextAlign.center,
                    style: bodyStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (placed != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Đã khớp',
                        style: TextStyle(color: practicePrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChoices() {
    final available = widget.choices.where((choice) => !_used.contains(choice.id)).toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: available.map(_buildChoice).toList(),
    );
  }

  Widget _buildChoice(CharacterPart part) {
    return LongPressDraggable<CharacterPart>(
      data: part,
      feedback: Material(
        color: Colors.transparent,
        child: _ChoiceChip(part: part, elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _ChoiceChip(part: part),
      ),
      child: _ChoiceChip(part: part),
    );
  }

  void _notify() {
    final complete = _placements.values.every((value) => value != null);
    widget.onStateChanged?.call(complete);
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.part, this.elevated = false});

  final CharacterPart part;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: elevated ? practicePrimary.withOpacity(0.18) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: practicePrimary.withOpacity(0.6), width: 1.6),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: practicePrimary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        part.label,
        style: bodyStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
