import 'package:figstyle/actions/share.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/author.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class AuthorRow extends StatefulWidget {
  final Author author;

  final bool isNarrow;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  final EdgeInsets padding;

  /// Required if `useSwipeActions` is true.
  final Key key;

  AuthorRow({
    this.author,
    this.isNarrow = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.useSwipeActions,
    this.key,
  });

  @override
  _AuthorRowState createState() => _AuthorRowState();
}

class _AuthorRowState extends State<AuthorRow> {
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
    final author = widget.author;

    List<PopupMenuEntry<String>> popupItems;
    Function itemBuilder;

    List<SwipeAction> trailingActions;

    if (widget.useSwipeActions) {
      trailingActions = getTrailingActions();
    } else {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    final childRow = Padding(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.tileBackground,
        child: InkWell(
          onTap: () {
            AuthorPageRoute(
              authorId: author.id,
              authorImageUrl: author.urls.image,
              authorName: author.name,
            ).show(context);
          },
          onHover: (isHover) {
            setState(() {
              elevation = isHover ? 2.0 : 0.0;
              iconColor = isHover ? iconHoverColor : null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                avatar(author),
                title(author),
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

  Widget avatar(Author author) {
    final isImageOk = author.urls.image?.isNotEmpty;

    if (!isImageOk) {
      return Padding(padding: EdgeInsets.zero);
    }

    final right = widget.isNarrow ? 10.0 : 40.0;

    return Padding(
      padding: EdgeInsets.only(right: right),
      child: Hero(
        tag: author.id,
        child: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: Opacity(
            opacity: elevation > 0.0 ? 1.0 : 0.8,
            child: Image.network(
              author.urls.image,
              width: 80.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget title(Author author) {
    final titleFontSize = widget.isNarrow ? 14.0 : 20.0;

    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: '${author.id}-name',
            child: Text(
              author.name,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (author.job?.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: widget.isNarrow
                  ? Opacity(
                      opacity: 0.6,
                      child: Text(
                        author.job,
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.work_outline),
                      label: Text(
                        author.job,
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
          ShareActions.shareAuthor(context: context, author: widget.author);
        },
      ),
    );

    return actions;
  }

  void onSelected(value) {
    if (value == 'share') {
      ShareActions.shareAuthor(context: context, author: widget.author);
      return;
    }
  }
}
