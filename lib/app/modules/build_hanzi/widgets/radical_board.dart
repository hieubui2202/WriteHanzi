import 'package:flutter/material.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';

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
  late Set<String> _usedChoiceIds;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(covariant RadicalBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slots != widget.slots || oldWidget.choices != widget.choices) {
      _initializeState();
    }
  }

  void _initializeState() {
    _placements = {for (final slot in widget.slots) slot.id: null};
    _usedChoiceIds = <String>{};
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyState());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: _buildBoardArea(context),
          ),
        ),
        const SizedBox(height: 16),
        _buildChoices(context),
      ],
    );
  }

  Widget _buildBoardArea(BuildContext context) {
    switch (widget.layout) {
      case 'left-right':
        return Row(
          children: widget.slots
              .map((slot) => Expanded(child: _buildSlot(context, slot)))
              .toList(growable: false),
        );
      case 'top-bottom':
        return Column(
          children: widget.slots
              .map((slot) => Expanded(child: _buildSlot(context, slot)))
              .toList(growable: false),
        );
      case 'enclose':
        return _buildEncloseLayout(context);
      default:
        return Column(
          children: widget.slots
              .map((slot) => Expanded(child: _buildSlot(context, slot)))
              .toList(growable: false),
        );
    }
  }

  Widget _buildEncloseLayout(BuildContext context) {
    if (widget.slots.length < 2) {
      return Column(
        children: widget.slots
            .map((slot) => Expanded(child: _buildSlot(context, slot)))
            .toList(growable: false),
      );
    }
    final outer = widget.slots.first;
    final innerSlots = widget.slots.skip(1).toList();
    return Stack(
      children: [
        Positioned.fill(child: _buildSlot(context, outer)),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: innerSlots
                .map((slot) => SizedBox(
                      height: 120,
                      child: _buildSlot(context, slot),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlot(BuildContext context, CharacterPart slot) {
    final placed = _placements[slot.id];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DragTarget<CharacterPart>(
        onWillAccept: (data) => placed == null,
        onAccept: (data) {
          if (data.id == slot.id) {
            setState(() {
              _placements[slot.id] = data;
              _usedChoiceIds.add(data.id);
            });
            _notifyState();
          } else {
            widget.onMistake?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chưa đúng vị trí, thử lại nhé!'),
                duration: Duration(milliseconds: 500),
              ),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isActive = candidateData.isNotEmpty;
          return GestureDetector(
            onDoubleTap: placed == null
                ? null
                : () {
                    setState(() {
                      _usedChoiceIds.remove(placed.id);
                      _placements[slot.id] = null;
                    });
                    _notifyState();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.lightGreen.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: placed != null
                      ? Colors.green
                      : isActive
                          ? Colors.lightGreen
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      placed != null ? Icons.check_circle : Icons.dashboard_customize,
                      color: placed != null ? Colors.green : Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      placed?.label ?? slot.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            placed != null ? FontWeight.w700 : FontWeight.w500,
                        color: placed != null ? Colors.green.shade700 : Colors.black87,
                      ),
                    ),
                    if (placed != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Nhấn đúp để đổi',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChoices(BuildContext context) {
    final available = widget.choices
        .where((choice) => !_usedChoiceIds.contains(choice.id))
        .toList(growable: false);

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: available.map(_buildChoiceChip).toList(),
    );
  }

  Widget _buildChoiceChip(CharacterPart part) {
    return Draggable<CharacterPart>(
      data: part,
      feedback: Material(
        color: Colors.transparent,
        child: _ChoiceTile(part: part, elevated: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _ChoiceTile(part: part),
      ),
      child: _ChoiceTile(part: part),
    );
  }

  void _notifyState() {
    final complete = _placements.values.every((value) => value != null);
    widget.onStateChanged?.call(complete);
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.part, this.elevated = false});

  final CharacterPart part;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: elevated ? Colors.deepPurple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1.2),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        part.label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
