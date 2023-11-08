import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:rive/rive.dart";

class SearchEmptyView extends StatelessWidget {
  /// A sliver component to display when data is not ready yet.
  const SearchEmptyView({
    Key? key,
    this.description = "",
    this.icon,
    this.onRefresh,
    this.onTapDescription,
    this.onReinitSearch,
    this.title = "",
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback called when the user wants to manually refresh the data.
  final void Function()? onRefresh;

  /// Callback fired when the description is tapped.
  final void Function()? onTapDescription;

  /// Callback fired to reinit the search.
  final void Function()? onReinitSearch;

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
              const SizedBox(
                width: 200.0,
                height: 200.0,
                child: RiveAnimation.network(
                  // "https://public.rive.app/community/runtime-files/4597-9318-no-results-found.riv",
                  "https://public.rive.app/community/runtime-files/4523-9190-moving-car.riv",
                  fit: BoxFit.cover,
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextButton(
                  onPressed: onReinitSearch != null
                      ? () => onReinitSearch?.call()
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink,
                    backgroundColor: Colors.pink.shade50,
                    textStyle: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("search.reinitialize".tr()),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          TablerIcons.refresh,
                          size: 18.0,
                        ),
                      ),
                    ],
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
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
