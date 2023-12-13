import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/topic.dart";

/// A specific chip which welcomes a topic.
class TopicChip extends StatefulWidget {
  const TopicChip({
    super.key,
    required this.topic,
    this.selected = false,
    this.onSelected,
  });

  /// Topic.
  final Topic topic;

  /// Callback fired when a topic is tapped.
  final void Function(Topic topic, bool selected)? onSelected;

  /// Whether the chip is selected.
  final bool selected;

  @override
  State<TopicChip> createState() => _TopicChipState();
}

class _TopicChipState extends State<TopicChip> {
  double _elevation = 0.0;
  Color _borderColor = Colors.transparent;
  Color _textShadowColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _borderColor = widget.topic.color.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    final Topic topic = widget.topic;
    final bool selected = widget.selected;

    return MouseRegion(
      onEnter: (_) {
        if (selected) {
          setState(() => _borderColor = Colors.white38);
          return;
        }

        setState(() {
          _elevation = 4.0;
          _borderColor = topic.color;
          _textShadowColor = topic.color;
        });
      },
      onExit: (_) {
        if (selected) {
          setState(() {
            _elevation = 0.0;
            _textShadowColor = Colors.transparent;
            _borderColor = Colors.transparent;
          });
          return;
        }
        setState(() {
          _elevation = 0.0;
          _borderColor = topic.color.withOpacity(0.2);
          _textShadowColor = Colors.transparent;
        });
      },
      child: ChoiceChip(
        label: Text(topic.name),
        labelStyle: Utils.calligraphy.body(
          textStyle: TextStyle(
            color: selected ? getTextColor() : null,
            shadows: [
              Shadow(
                blurRadius: 0.5,
                offset: const Offset(-1.0, 1.0),
                color: _textShadowColor,
              ),
            ],
          ),
        ),
        checkmarkColor: getTextColor(),
        selected: selected,
        elevation: selected ? 8.0 : _elevation,
        selectedColor: topic.color,
        pressElevation: 0.0,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: _borderColor,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        onSelected: widget.onSelected != null
            ? (bool selected) => widget.onSelected?.call(topic, selected)
            : null,
      ),
    );
  }

  getTextColor() {
    return widget.topic.color.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;
  }
}
