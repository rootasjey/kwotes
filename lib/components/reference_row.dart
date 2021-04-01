import 'package:auto_route/auto_route.dart';
import 'package:fig_style/actions/share.dart';
import 'package:fig_style/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:fig_style/state/colors.dart';
import 'package:fig_style/types/reference.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class ReferenceRow extends StatefulWidget {
  final bool isNarrow;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  final EdgeInsets padding;

  /// Required if `useSwipeActions` is true.
  final Key key;

  final Reference reference;

  ReferenceRow({
    this.isNarrow = false,
    this.reference,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.useSwipeActions,
    this.key,
  });

  @override
  _ReferenceRowState createState() => _ReferenceRowState();
}

class _ReferenceRowState extends State<ReferenceRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

  @override
  initState() {
    super.initState();

    setState(() {
      iconHoverColor = stateColors.primary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reference = widget.reference;

    List<PopupMenuEntry<String>> popupItems;
    Function itemBuilder;

    List<SwipeAction> trailingActions;

    if (widget.useSwipeActions) {
      trailingActions = getTrailingActions();
    } else {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    final childRow = Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.tileBackground,
        child: InkWell(
          onTap: () {
            context.router.root.push(
              ReferencesDeepRoute(children: [
                ReferencePageRoute(
                  referenceId: reference.id,
                  referenceName: reference.name,
                  referenceImageUrl: reference.urls.image,
                ),
              ]),
            );
          },
          onHover: (isHover) {
            elevation = isHover ? 2.0 : 0.0;
            iconColor = isHover ? iconHoverColor : null;

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                avatar(reference),
                title(reference),
                actions(popupItems, itemBuilder),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.useSwipeActions) {
      return childRow;
    }

    return SwipeActionCell(
      key: widget.key,
      performsFirstActionWithFullSwipe: true,
      child: childRow,
      trailingActions: trailingActions,
    );
  }

  Widget actions(
      List<PopupMenuEntry<String>> popupItems, Function itemBuilder) {
    if (itemBuilder == null) {
      return Container();
    }

    return SizedBox(
      width: 50.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PopupMenuButton<String>(
            icon: Opacity(
              opacity: .6,
              child: iconColor != null
                  ? Icon(
                      Icons.more_vert,
                      color: iconColor,
                    )
                  : Icon(Icons.more_vert),
            ),
            onSelected: onSelected,
            itemBuilder: itemBuilder,
          ),
        ],
      ),
    );
  }

  Widget avatar(Reference reference) {
    final isImageOk = reference.urls.image?.isNotEmpty;

    if (!isImageOk) {
      return Padding(padding: EdgeInsets.zero);
    }

    final right = widget.isNarrow ? 10.0 : 40.0;

    return Padding(
        padding: EdgeInsets.only(right: right),
        child: Card(
          elevation: 4.0,
          child: Opacity(
            opacity: elevation > 0.0 ? 1.0 : 0.8,
            child: Image.network(
              reference.urls.image,
              width: 80.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          ),
        ));
  }

  Widget title(Reference reference) {
    var titleFontSize = widget.isNarrow ? 14.0 : 20.0;

    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            reference.name,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reference.type?.primary?.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: widget.isNarrow
                  ? Opacity(
                      opacity: 0.6,
                      child: Text(
                        reference.type.primary,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.filter_1),
                      label: Text(
                        reference.type.primary,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    return <PopupMenuEntry<String>>[
      PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
          )),
    ];
  }

  List<SwipeAction> getTrailingActions() {
    final actions = <SwipeAction>[];

    actions.add(
      SwipeAction(
        title: 'Share',
        icon: Icon(Icons.ios_share, color: Colors.white),
        color: Colors.blue,
        onTap: (CompletionHandler handler) {
          handler(false);
          ShareActions.shareReference(
            context: context,
            reference: widget.reference,
          );
        },
      ),
    );

    return actions;
  }

  void onSelected(value) {
    if (value == 'share') {
      ShareActions.shareReference(
        context: context,
        reference: widget.reference,
      );
      return;
    }
  }
}
