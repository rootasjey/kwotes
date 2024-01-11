import "package:flutter/material.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/utils.dart";

class TopicPageHeader extends StatelessWidget {
  const TopicPageHeader({
    super.key,
    required this.topic,
    this.isMobileSize = false,
    this.onTapName,
  });

  /// Adapt the user interface to small screens if true.
  final bool isMobileSize;

  /// Callback fired when topic name is tapped.
  final void Function()? onTapName;

  /// Topic name.
  final String topic;

  @override
  Widget build(BuildContext context) {
    return PageAppBar(
      axis: Axis.horizontal,
      toolbarHeight: 120.0,
      isMobileSize: isMobileSize,
      children: [
        Hero(
          tag: topic,
          child: InkWell(
            onTap: onTapName,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
