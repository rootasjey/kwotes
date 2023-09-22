import "package:flex_list/flex_list.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/showcase_text.dart";
import "package:kwotes/types/reference.dart";

class ShowcaseReferences extends StatelessWidget {
  const ShowcaseReferences({
    super.key,
    this.margin = EdgeInsets.zero,
    this.references = const [],
    this.onTapReference,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of authors.
  final List<Reference> references;

  /// Callback fired when reference name is tapped.
  final void Function(Reference reference)? onTapReference;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    int index = -1;

    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: FlexList(
          horizontalSpacing: 6.0,
          verticalSpacing: 6.0,
          children: references
              .map(
                (Reference reference) {
                  index++;
                  return ShowcaseText(
                    docId: reference.id,
                    textValue: reference.name,
                    foregroundColor: index % 2 == 0
                        ? foregroundColor?.withOpacity(0.1)
                        : foregroundColor?.withOpacity(0.2),
                    onTap: onTapReference != null
                        ? () => onTapReference?.call(reference)
                        : null,
                  );
                },
              )
              .toList()
              .animate(interval: 7.ms)
              .fadeIn(duration: 125.ms)
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
              ),
        ),
      ),
    );
  }
}
