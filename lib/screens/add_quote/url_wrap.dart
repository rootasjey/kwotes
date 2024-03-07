import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/types/urls.dart";

class UrlWrap extends StatefulWidget {
  /// A widget displaying a list of url chips on a row.
  /// Typically used on edit author page or edit reference page.
  const UrlWrap({
    super.key,
    required this.initialUrls,
    this.onUrlChanged,
    this.lastUsed = const [],
    this.margin = EdgeInsets.zero,
  });

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when url input has changed.
  final void Function(String key, String value)? onUrlChanged;

  /// Last used urls.
  final List<String> lastUsed;

  /// Initial url values (fill in text inputs).
  final Urls initialUrls;

  @override
  State<UrlWrap> createState() => _UrlWrapState();
}

class _UrlWrapState extends State<UrlWrap> {
  /// Show all url buttons if true.
  bool _showAllUrls = false;

  final List<String> _availableButtons = [
    "amazon",
    "facebook",
    "imdb",
    "instagram",
    "netflix",
    "prime_video",
    "twitch",
    "twitter",
    "website",
    "wikipedia",
    "youtube",
  ];

  final List<String> _buttons = [];

  @override
  void initState() {
    super.initState();
    _buttons.addAll(_availableButtons);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    children.addAll(getLastUsedItems());

    if (_showAllUrls) {
      children.addAll(getRemainingItems());
    } else {
      children.add(
        IconButton(
          tooltip: "quote.add.links.more".tr(),
          icon: const Icon(TablerIcons.dots),
          onPressed: () {
            setState(() {
              _showAllUrls = !_showAllUrls;
              _buttons.clear();
              _buttons.addAll(_availableButtons);
            });
          },
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  List<Widget> getLastUsedItems() {
    final List<Widget> widgets = [];

    for (final String key in widget.lastUsed) {
      _buttons.remove(key);
      widgets.add(
        ExpandInputChip(
          tooltip: "quote.add.links.$key".tr(),
          avatar: CircleAvatar(
            radius: 14.0,
            foregroundColor:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            backgroundColor: Colors.transparent,
            child: Icon(getIconFromKey(key)),
          ),
          initialValue: widget.initialUrls.getValue(key),
          hintText: "quote.add.links.example.$key".tr(),
          onTextChanged: (String value) => widget.onUrlChanged?.call(
            key,
            value,
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> getRemainingItems() {
    final List<Widget> widgets = [];

    for (final String key in _buttons) {
      widgets.add(
        ExpandInputChip(
          tooltip: "quote.add.links.$key".tr(),
          avatar: CircleAvatar(
            radius: 14.0,
            foregroundColor:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            backgroundColor: Colors.transparent,
            child: Icon(getIconFromKey(key)),
          ),
          hintText: "quote.add.links.example.$key".tr(),
          onTextChanged: (String value) => widget.onUrlChanged?.call(
            key,
            value,
          ),
        ),
      );
    }

    return widgets;
  }

  IconData getIconFromKey(String key) {
    switch (key) {
      case "amazon":
        return TablerIcons.brand_amazon;
      case "facebook":
        return TablerIcons.brand_facebook;
      case "imdb":
        return TablerIcons.movie;
      case "instagram":
        return TablerIcons.brand_instagram;
      case "netflix":
        return TablerIcons.brand_netflix;
      case "prime_video":
        return TablerIcons.video;
      case "twitch":
        return TablerIcons.brand_twitch;
      case "twitter":
        return TablerIcons.brand_twitter;
      case "website":
        return TablerIcons.globe;
      case "wikipedia":
        return TablerIcons.brand_wikipedia;
      case "youtube":
        return TablerIcons.brand_youtube;
      default:
        return TablerIcons.globe;
    }
  }
}
