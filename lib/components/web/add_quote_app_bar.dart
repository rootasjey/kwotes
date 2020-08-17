import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';

class AddQuoteAppBar extends StatefulWidget {
  final Function onTapIconHeader;
  final String title;

  /// If specified, show an icon button which will show
  /// a bottom sheet containing this widget content.
  final Widget help;

  AddQuoteAppBar({
    this.help,
    this.onTapIconHeader,
    this.title = '',
  });

  @override
  _AddQuoteAppBarState createState() => _AddQuoteAppBarState();
}

class _AddQuoteAppBarState extends State<AddQuoteAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverLayoutBuilder(
          builder: (context, constrains) {
            final isNarrow = constrains.crossAxisExtent < 700.0;
            final leftPadding = isNarrow
              ? 0.0
              : 60.0;

            return SliverAppBar(
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: stateColors.appBackground.withOpacity(1.0),
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.only(
                  left: leftPadding,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        color: stateColors.foreground,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),

                    AppIconHeader(
                      size: 40.0,
                      padding: EdgeInsets.zero,
                      onTap: () =>
                        FluroRouter.router.navigateTo(context, RootRoute),
                    ),

                    if (widget.title.isNotEmpty)
                      titleBar(isNarrow: isNarrow),
                  ],
                ),
              ),
              flexibleSpace: userSection(isNarrow),
            );
          },
        );
      },
    );
  }

  Widget helpButton() {
    return IconButton(
      iconSize: 35.0,
      color: Colors.yellow.shade700,
      icon: Icon(Icons.help),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Column(
              children: <Widget>[
                widget.help,

                OutlineButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: stateColors.primary,
                  ),
                  borderSide: BorderSide(
                    color: stateColors.primary,
                  ),
                  label: Text(
                    'Close',
                    style: TextStyle(
                      color: stateColors.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget titleBar({bool isNarrow = false}) {
    return Container(
      width: MediaQuery.of(context).size.width - 320.0,
      padding: const EdgeInsets.only(left: 40.0),
      child: isNarrow
        ? Tooltip(
          message: widget.title,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: stateColors.foreground,
              ),
            ),
          ),
        )
        : Opacity(
          opacity: 0.6,
          child: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: stateColors.foreground,
            ),
          ),
        ),
    );
  }

  Widget userAvatar({bool isNarrow = true}) {
    final arrStr = userState.username.split(' ');
    String initials = '';

    if (arrStr.length > 0) {
      initials = arrStr.length > 1
      ? arrStr.reduce((value, element) => value + element.substring(1))
      : arrStr.first;

      if (initials != null && initials.isNotEmpty) {
        initials = initials.substring(0, 1);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: PopupMenuButton<String>(
        icon: CircleAvatar(
          backgroundColor: stateColors.primary,
          radius: 20.0,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // tooltip: 'More quick links',
        onSelected: (value) {
          if (value == 'signout') {
            userSignOut(context: context);
            return;
          }

          FluroRouter.router.navigateTo(
            context,
            value,
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (isNarrow)
            const PopupMenuItem(
              value: AddQuoteContentRoute,
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text(
                  'Add quote',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),

          const PopupMenuItem(
            value: FavouritesRoute,
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text(
                'Favourites',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          const PopupMenuItem(
            value: ListsRoute,
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text(
                'Lists',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          const PopupMenuItem(
            value: DraftsRoute,
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Drafts',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: PublishedQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'Published',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: TempQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.timelapse),
              title: Text(
                'In Validation',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          const PopupMenuItem(
            value: AccountRoute,
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: 'signout',
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Sign out',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userSection(bool isNarrow) {
    return Observer(builder: (context) {
      final children = List<Widget>();

      if (userState.isUserConnected) {
        children.add(userAvatar(isNarrow: isNarrow));
      }

      if (widget.help != null) {
        children.add(helpButton());
      }

      return Container(
        padding: const EdgeInsets.only(
          top: 5.0,
          right: 10.0,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: children,
        ),
      );
    });
  }
}
