import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class EmptyView extends StatelessWidget {
  /// A sliver component to display when data is not ready yet.
  const EmptyView({
    Key? key,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.description = "",
    this.icon,
    this.onRefresh,
    this.onTapDescription,
    this.title = "",
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// Column cross axis alignment.
  final CrossAxisAlignment columnCrossAxisAlignment;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback called when the user wants to manually refresh the data.
  final void Function()? onRefresh;

  /// Callback fired when the description is tapped.
  final void Function()? onTapDescription;

  /// Icon to display on top.
  final Icon? icon;

  /// Description of the empty data.
  final String description;

  /// You can specify what's the nature of the data.
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: RefreshIndicator(
          onRefresh: () async {
            return onRefresh?.call();
          },
          child: Column(
            crossAxisAlignment: columnCrossAxisAlignment,
            children: <Widget>[
              icon ?? const SizedBox.shrink(),
              if (title.isNotEmpty)
                AnimatedTextKit(
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  animatedTexts: [
                    ColorizeAnimatedText(
                      title,
                      textStyle: Utils.calligraphy.code(
                        textStyle: const TextStyle(
                          fontSize: 54.0,
                        ),
                      ),
                      colors: [
                        Constants.colors.foregroundPalette.first,
                        Constants.colors.foregroundPalette[1],
                        Constants.colors.foregroundPalette[2],
                        Constants.colors.foregroundPalette[3],
                        Constants.colors.foregroundPalette[4],
                      ],
                    ),
                  ],
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(6.0),
                    ),
                    onPressed: onTapDescription != null
                        ? () => onTapDescription?.call()
                        : null,
                    child: Text(
                      description,
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Return a Scaffold widget displaying an empty view.
  static Widget scaffold(
    BuildContext context, {
    Icon? icon,
    String title = "",
    String description = "",
    void Function()? onRefresh,
    void Function()? onTapDescription,
  }) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          return onRefresh?.call();
        },
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height - 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  icon ?? Container(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.6,
                    child: TextButton(
                      onPressed: () {
                        onTapDescription?.call();
                      },
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Return a Scaffold widget displaying an empty view.
  static Widget premium(
    BuildContext context, {
    Icon? icon,
    String title = "",
    String description = "",
    EdgeInsets margin = EdgeInsets.zero,
    void Function()? onRefresh,
    void Function()? onTapDescription,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: RefreshIndicator(
          onRefresh: () async {
            return onRefresh?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              icon ?? const SizedBox.shrink(),
              if (title.isNotEmpty)
                AnimatedTextKit(
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  animatedTexts: [
                    ColorizeAnimatedText(
                      title,
                      textStyle: Utils.calligraphy.code(
                        textStyle: const TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                      colors: [
                        Constants.colors.foregroundPalette.first,
                        Constants.colors.foregroundPalette[1],
                        Constants.colors.foregroundPalette[2],
                        Constants.colors.foregroundPalette[3],
                        Constants.colors.foregroundPalette[4],
                      ],
                    ),
                  ],
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: onTapDescription,
                    child: Text(
                      description,
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Return a Scaffold widget displaying an empty view.
  static Widget quotes(
    BuildContext context, {
    Color? foregroundColor,
    Color? accentColor,
    String title = "",
    String description = "",
    void Function()? onTapBackButton,
    String buttonTextValue = "Back",
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Icon(
                TablerIcons.quote_off,
                size: 42.0,
                color: accentColor,
              ),
            ),
            Text.rich(
              TextSpan(
                text: "",
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
              textAlign: TextAlign.center,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.4),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 160.0,
              ),
              child: ColoredTextButton(
                onPressed: onTapBackButton,
                textValue: buttonTextValue,
                textAlign: TextAlign.center,
                margin: const EdgeInsets.only(top: 24.0),
                style: TextButton.styleFrom(
                  backgroundColor: accentColor?.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Return a specific empty view for the search.
  static Widget searchEmptyView(
    BuildContext context, {
    /// Foreground color.
    Color? foregroundColor,

    /// Accent color.
    Color? accentColor,

    /// Space around this widget.
    final EdgeInsets margin = EdgeInsets.zero,

    /// Callback fired when the description is tapped.
    void Function()? onTapDescription,

    /// Callback fired when the description is tapped.
    void Function()? onReinitializeSearch,

    /// Callback called when the user wants to manually refresh the data.
    final void Function()? onRefresh,

    /// View's title.
    String title = "",

    /// View's description.
    String description = "",

    /// Text align.
    TextAlign textAlign = TextAlign.center,

    /// Icon to display on top.
    Widget? icon,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: RefreshIndicator(
          onRefresh: () async {
            return onRefresh?.call();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              icon ?? const SizedBox.shrink(),
              if (title.isNotEmpty)
                AnimatedTextKit(
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  animatedTexts: [
                    ColorizeAnimatedText(
                      title,
                      textAlign: textAlign,
                      textStyle: Utils.calligraphy.code(
                        textStyle: const TextStyle(
                          fontSize: 54.0,
                        ),
                      ),
                      colors: [
                        Constants.colors.foregroundPalette.first,
                        Constants.colors.foregroundPalette[1],
                        Constants.colors.foregroundPalette[2],
                        Constants.colors.foregroundPalette[3],
                        Constants.colors.foregroundPalette[4],
                      ],
                    ),
                  ],
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: TextButton(
                    onPressed: onTapDescription,
                    child: Text(
                      description,
                      textAlign: textAlign,
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: ColoredTextButton(
                  onPressed: onReinitializeSearch,
                  textValue: "search.reinitialize".tr(),
                  textAlign: TextAlign.center,
                  textFlex: 0,
                  margin: const EdgeInsets.only(top: 24.0),
                  icon: Icon(
                    TablerIcons.zoom_reset,
                    size: 18.0,
                    color: foregroundColor?.withOpacity(0.8),
                  ),
                  textStyle: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: foregroundColor?.withOpacity(0.8),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: foregroundColor?.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
