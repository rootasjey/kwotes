import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorMetadaRow extends StatelessWidget {
  const AuthorMetadaRow({
    super.key,
    required this.author,
    required this.foregroundColor,
    this.show = true,
    this.margin = EdgeInsets.zero,
  });

  /// Author data for this component.
  final Author author;

  /// Hide this widget if true.
  /// Default to true.
  final bool show;

  /// Text foreground color.
  final Color foregroundColor;

  /// Space around this widget.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Padding(
      padding: margin,
      child: Wrap(
        children: [
          if (author.job.isNotEmpty)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.briefcase,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        author.job,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor.withOpacity(0.6),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!author.birth.dateEmpty)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.baby_bottle,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      Jiffy.parseFromDateTime(author.birth.date).yMMMMd,
                    ),
                  ],
                ),
              ),
            ),
          if (!author.death.dateEmpty)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.skull,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      Jiffy.parseFromDateTime(author.death.date).yMMMMd,
                    ),
                  ],
                ),
              ),
            ),
          if (author.isFictional)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.wand,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Text("fictional".tr()),
                  ],
                ),
              ),
            ),
        ]
            .animate(interval: 100.ms)
            .fadeIn(duration: 300.ms, curve: Curves.decelerate)
            .slideX(begin: 0.2, end: 0.0),
      ),
    );
  }
}
