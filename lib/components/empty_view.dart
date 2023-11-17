import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/utils.dart";

class EmptyView extends StatelessWidget {
  /// A sliver component to display when data is not ready yet.
  const EmptyView({
    Key? key,
    this.description = "",
    this.icon,
    this.onRefresh,
    this.onTapDescription,
    this.title = "",
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

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
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: RefreshIndicator(
          onRefresh: () async {
            return onRefresh?.call();
          },
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              icon ?? Container(),
              if (title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 30.0,
                        color: foregroundColor?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: TextButton(
                    onPressed: onTapDescription != null
                        ? () => onTapDescription?.call()
                        : null,
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
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
            ColoredTextButton(
              onPressed: onTapBackButton,
              textValue: buttonTextValue,
              textAlign: TextAlign.center,
              margin: const EdgeInsets.only(top: 24.0),
              style: TextButton.styleFrom(
                backgroundColor: accentColor?.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
