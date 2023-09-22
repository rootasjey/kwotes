import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class AuthorPageBody extends StatelessWidget {
  const AuthorPageBody({
    super.key,
    required this.author,
    this.pageState = EnumPageState.idle,
    this.onTapSeeQuotes,
  });

  /// Author data for this component.
  final Author author;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired when the "see related quotes" button is tapped.
  final void Function()? onTapSeeQuotes;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 48.0,
        right: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Hero(
            tag: author.id,
            child: Material(
              color: Colors.transparent,
              child: Text(
                author.name,
                style: Utils.calligraphy.title(
                  textStyle: const TextStyle(
                    fontSize: 68.0,
                  ),
                ),
              ),
            ),
          ),
          AnimatedTextKit(
            isRepeatingAnimation: false,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                author.summary,
                speed: const Duration(milliseconds: 10),
                curve: Curves.decelerate,
                textStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 24.0,
                    color: foregroundColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Wrap(
              children: [
                if (author.urls.image.isNotEmpty)
                  Card(
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BetterAvatar(
                            radius: 16.0,
                            avatarMargin: EdgeInsets.zero,
                            imageProvider: NetworkImage(author.urls.image),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          Text(author.job),
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
                              TablerIcons.horse_toy,
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
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: TextButton(
                onPressed: onTapSeeQuotes,
                style: TextButton.styleFrom(
                  foregroundColor: Constants.colors.getRandomFromPalette(),
                ),
                child: Text(
                  "see_related_quotes".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.8, end: 0.0),
        ]),
      ),
    );
  }
}
