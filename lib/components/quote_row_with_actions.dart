import 'package:figstyle/components/user_lists.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/favourites.dart';
import 'package:figstyle/actions/quotes.dart';
import 'package:figstyle/actions/quotidians.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/quote_row.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/user_quotes_list.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class QuoteRowWithActions extends StatefulWidget {
  final bool canManage;
  final bool isConnected;

  /// Specify this only when componentType = ComponentType.Card.
  /// If true, author will be displayed on card.
  final bool showAuthor;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  final Color color;

  final double elevation;
  final double quoteFontSize;

  final Function onAfterAddToFavourites;
  final Function onAfterDeletePubQuote;
  final Function onAfterRemoveFromFavourites;
  final Function onAfterRemoveFromList;
  final Function onBeforeAddToFavourites;
  final Function onBeforeDeletePubQuote;
  final Function onBeforeRemoveFromFavourites;
  final Function onBeforeRemoveFromList;
  final Function onRemoveFromList;

  final ItemComponentType componentType;

  /// Required if `useSwipeActions` is true.
  final Key key;

  final EdgeInsets padding;

  final Quote quote;
  final QuotePageType quotePageType;

  /// Specify explicitly the quote'is
  /// because quote's id in favourites reflect
  /// the favourite's id and no the quote.
  final String quoteId;
  final String pageRoute;

  final List<Widget> stackChildren;

  /// A widget positioned before the main content (quote's content).
  /// Typcally an Icon or a small Container.
  final Widget leading;

  QuoteRowWithActions({
    this.canManage = false,
    this.color,
    this.isConnected = false,
    this.elevation,
    this.componentType = ItemComponentType.row,
    this.key,
    this.onAfterAddToFavourites,
    this.onAfterDeletePubQuote,
    this.onAfterRemoveFromFavourites,
    this.onAfterRemoveFromList,
    this.onBeforeAddToFavourites,
    this.onBeforeDeletePubQuote,
    this.onBeforeRemoveFromFavourites,
    this.onBeforeRemoveFromList,
    this.onRemoveFromList,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
    this.pageRoute = '',
    @required this.quote,
    this.quoteFontSize = 20.0,
    this.quoteId,
    this.quotePageType = QuotePageType.published,
    this.showAuthor = false,
    this.stackChildren = const [],
    this.leading,
    this.useSwipeActions = false,
  });

  @override
  _QuoteRowWithActionsState createState() => _QuoteRowWithActionsState();
}

class _QuoteRowWithActionsState extends State<QuoteRowWithActions> {
  List<UserQuotesList> userQuotesLists = [];

  String newListName = '';
  String newListDescription = '';

  int order = -1;
  int limit = 10;

  bool hasNext = true;

  bool isFavourite = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoaded = false;

  bool hasErrors = false;
  Error error;

  var lastDoc;

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;

    List<PopupMenuEntry<String>> popupItems;
    Function itemBuilder;

    List<SwipeAction> leadingActions = defaultActions;
    List<SwipeAction> trailingActions = defaultActions;

    if (widget.useSwipeActions) {
      leadingActions = getLeadingActions();
      trailingActions = getTrailingActions();
    } else {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    return QuoteRow(
      quote: quote,
      quoteId: widget.quoteId,
      color: widget.color,
      key: widget.key,
      quoteFontSize: widget.quoteFontSize,
      elevation: widget.elevation,
      padding: widget.padding,
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      componentType: widget.componentType,
      showAuthor: widget.showAuthor,
      stackChildren: widget.stackChildren,
      leading: widget.leading,
      useSwipeActions: widget.useSwipeActions,
      leadingActions: leadingActions,
      trailingActions: trailingActions,
    );
  }

  void onSelected(value) async {
    final quote = widget.quote;

    switch (value) {
      case 'addtofavourites':
        if (widget.onBeforeAddToFavourites != null) {
          widget.onBeforeAddToFavourites();
        }

        final success = await addToFavourites(
          context: context,
          quote: quote,
        );

        if (widget.onAfterAddToFavourites != null) {
          widget.onAfterAddToFavourites(success);
        }

        break;
      case 'addtolist':
        showBottomSheetList();
        break;
      case 'removefromfavourites':
        if (widget.onBeforeRemoveFromFavourites != null) {
          widget.onBeforeRemoveFromFavourites();
        }

        final success = await removeFromFavourites(
          context: context,
          quote: quote,
        );

        if (widget.onAfterRemoveFromFavourites != null) {
          widget.onAfterRemoveFromFavourites(success);
        }

        break;
      case 'removefromlist':
        widget.onRemoveFromList(quote);
        break;
      case 'share':
        shareQuote(context: context, quote: quote);
        break;
      case 'addquotidian':
        await addToQuotidians(
          quote: quote,
          lang: quote.lang,
        );

        break;
      case 'deletequote':
        FlashHelper.simpleDialog(
          context,
          title: 'Confirm deletion?',
          message:
              'The published quote will be deleted. This action is irreversible.',
          negativeAction: (context, controller, setState) {
            return FlatButton(
              child: Text('NO'),
              onPressed: () => controller.dismiss(),
            );
          },
          positiveAction: (context, controller, setState) {
            return FlatButton(
              child: Text('DELETE'),
              onPressed: () {
                controller.dismiss();
                deletePubQuote();
              },
            );
          },
        );
        break;
      default:
    }
  }

  void showBottomSheetList() {
    if (!userState.isUserConnected) {
      showSnack(
        context: context,
        message: "You must sign in to add this quote to a list.",
        type: SnackType.error,
      );

      return;
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => UserLists(
        scrollController: scrollController,
        quote: widget.quote,
      ),
    );
  }

  void deletePubQuote() async {
    if (widget.onBeforeDeletePubQuote != null) {
      widget.onBeforeDeletePubQuote();
    }

    final success = await deleteQuote(quote: widget.quote);

    if (widget.onAfterDeletePubQuote != null) {
      widget.onAfterDeletePubQuote(success);
    }
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    final popupItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'share',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
        ),
      ),
    ];

    if (widget.quotePageType == QuotePageType.published && widget.isConnected) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Like'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.favourites) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'removefromfavourites',
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Remove from favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    } else if (widget.quotePageType == QuotePageType.list) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'addtofavourites',
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Add to favourites'),
          ),
        ),
        PopupMenuItem(
          value: 'addtolist',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text('Add to...'),
          ),
        ),
      ]);
    }

    if (widget.canManage) {
      popupItems.addAll([
        PopupMenuItem(
            value: 'addquotidian',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Add to quotidians'),
            )),
        PopupMenuItem(
            value: 'deletequote',
            child: ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Delete published'),
            )),
      ]);
    }

    return popupItems;
  }

  List<SwipeAction> getLeadingActions() {
    final quote = widget.quote;

    final actions = [
      SwipeAction(
        title: 'Share',
        icon: Icon(Icons.ios_share, color: Colors.white),
        color: Colors.blue,
        onTap: (CompletionHandler handler) {
          handler(false);
          shareQuote(context: context, quote: quote);
        },
      ),
    ];

    if (widget.canManage) {
      actions.addAll([
        SwipeAction(
          title: 'Quotidian',
          icon: Icon(Icons.wb_sunny, color: Colors.white),
          color: Colors.yellow.shade800,
          onTap: (CompletionHandler handler) async {
            handler(false);
            await addToQuotidians(
              quote: quote,
              lang: quote.lang,
            );
          },
        ),
        SwipeAction(
          title: 'Delete',
          icon: Icon(Icons.delete_outline, color: Colors.white),
          color: stateColors.deletion,
          onTap: (CompletionHandler handler) {
            handler(false);

            showCustomModalBottomSheet(
              context: context,
              builder: (context, controller) {
                return Material(
                  child: SafeArea(
                    top: false,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                        title: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        tileColor: Color(0xfff55c5c),
                        onTap: () {
                          Navigator.of(context).pop();
                          deletePubQuote();
                        },
                      ),
                      ListTile(
                        title: Text('Cancel'),
                        trailing: Icon(Icons.close),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ]),
                  ),
                );
              },
              containerWidget: (context, animation, child) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(12.0),
                      child: child,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ]);
    }

    return actions;
  }

  List<SwipeAction> getTrailingActions() {
    if (!widget.isConnected) {
      return defaultActions;
    }

    final actions = <SwipeAction>[];

    actions.add(
      SwipeAction(
        title: 'Add to...',
        icon: Icon(Icons.playlist_add, color: Colors.white),
        color: Color(0xff5cc9f5),
        onTap: (CompletionHandler handler) {
          handler(false);
          showBottomSheetList();
        },
      ),
    );

    if (widget.quotePageType == QuotePageType.favourites) {
      actions.insert(
        0,
        SwipeAction(
          title: 'Unlike',
          icon: Icon(Icons.favorite, color: Colors.white),
          color: Color(0xff6638f0),
          onTap: (CompletionHandler handler) {
            handler(false);
            toggleFavourite();
          },
        ),
      );
    } else {
      actions.insert(
        0,
        SwipeAction(
          title: 'Like',
          icon: isFavourite
              ? Icon(Icons.favorite, color: Colors.white)
              : Icon(Icons.favorite_border, color: Colors.white),
          color: Color(0xff6638f0),
          onTap: (CompletionHandler handler) {
            handler(false);
            toggleFavourite();
          },
        ),
      );
    }

    if (widget.quotePageType == QuotePageType.list) {
      actions.add(SwipeAction(
        title: 'Remove',
        icon: Icon(Icons.remove_circle, color: Colors.white),
        color: Colors.pink,
        onTap: (CompletionHandler handler) {
          handler(false);
          widget.onRemoveFromList(widget.quote);
        },
      ));
    }

    return actions;
  }

  Future toggleFavourite() async {
    final quote = widget.quote;

    if (isFavourite) {
      if (widget.onBeforeAddToFavourites != null) {
        widget.onBeforeAddToFavourites();
      }

      final success = await addToFavourites(
        context: context,
        quote: quote,
      );

      if (widget.onAfterAddToFavourites != null) {
        widget.onAfterAddToFavourites(success);
      }
    } else {
      if (widget.onBeforeRemoveFromFavourites != null) {
        widget.onBeforeRemoveFromFavourites();
      }

      final success = await removeFromFavourites(
        context: context,
        quote: quote,
      );

      if (widget.onAfterRemoveFromFavourites != null) {
        widget.onAfterRemoveFromFavourites(success);
      }
    }
  }
}
