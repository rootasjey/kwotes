import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/screens/reject_temp_quote.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/temp_quotes.dart';
import 'package:figstyle/components/temp_quote_row.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/temp_quote.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TempQuoteRowWithActions extends StatefulWidget {
  final bool canManage;
  final bool isDraft;

  final double cardSize;
  final double elevation;

  /// If true, this will activate swipe actions
  /// and deactivate popup menu button.
  final bool useSwipeActions;

  /// If true, the popup menu will be displayed whatever [useSwipeActions] value.
  final bool showPopupMenuButton;

  final EdgeInsets padding;

  final Function itemBuilder;
  final Function onSelected;
  final Function onTap;

  final Function onBeforeDelete;
  final Function onBeforeValidate;
  final Function(bool) onAfterValidate;
  final Function(bool) onAfterDelete;
  final Function onNavBack;

  final ItemComponentType componentType;

  /// Required if `useSwipeActions` is true.
  final Key key;

  final List<Widget> stackChildren;

  final TempQuote tempQuote;
  final QuotePageType quotePageType;

  TempQuoteRowWithActions({
    this.canManage = false,
    this.cardSize = 250.0,
    this.componentType = ItemComponentType.row,
    this.elevation = 0.0,
    this.isDraft = false,
    this.itemBuilder,
    this.key,
    this.onSelected,
    this.onTap,
    this.onBeforeDelete,
    this.onBeforeValidate,
    this.onAfterValidate,
    this.onAfterDelete,
    this.onNavBack,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 30.0,
    ),
    @required this.tempQuote,
    this.quotePageType = QuotePageType.published,
    this.showPopupMenuButton = false,
    this.stackChildren = const [],
    this.useSwipeActions = false,
  });

  @override
  _TempQuoteRowWithActionsState createState() =>
      _TempQuoteRowWithActionsState();
}

class _TempQuoteRowWithActionsState extends State<TempQuoteRowWithActions> {
  @override
  Widget build(BuildContext context) {
    final quote = widget.tempQuote;

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

    if (widget.showPopupMenuButton && popupItems == null) {
      popupItems = getPopupItems();
      itemBuilder = (BuildContext context) => popupItems;
    }

    return TempQuoteRow(
      key: widget.key,
      elevation: widget.elevation,
      padding: widget.padding,
      cardSize: widget.cardSize,
      componentType: widget.componentType,
      isDraft: widget.isDraft,
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      onLongPress: onLongPress,
      onTap: widget.onTap ?? () => editAction(quote),
      tempQuote: quote,
      useSwipeActions: widget.useSwipeActions,
      leadingActions: leadingActions,
      trailingActions: trailingActions,
    );
  }

  void onSelected(value) async {
    final tempQuote = widget.tempQuote;

    switch (value) {
      case 'deletetempquote':
        deleteAction(tempQuote);
        break;
      case 'edit':
        editAction(tempQuote);
        break;
      case 'copy':
        copyFromAction(tempQuote);
        break;
      case 'validate':
        validateAction(tempQuote);
        break;
      case 'reject':
        rejectAction(tempQuote);
        break;
      default:
        break;
    }
  }

  List<PopupMenuEntry<String>> getPopupItems() {
    final popupItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'edit',
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit'),
        ),
      ),
      PopupMenuItem(
        value: 'copy',
        child: ListTile(
          leading: Icon(Icons.copy),
          title: Text('Copy from...'),
        ),
      ),
      PopupMenuItem(
        value: 'deletetempquote',
        child: ListTile(
          leading: Icon(Icons.delete_forever),
          title: Text('Delete'),
        ),
      ),
    ];

    if (widget.canManage) {
      popupItems.addAll([
        PopupMenuItem(
          value: 'validate',
          child: ListTile(
            leading: Icon(Icons.check),
            title: Text('Validate'),
          ),
        ),
        PopupMenuItem(
          value: 'reject',
          child: ListTile(
            leading: Icon(Icons.close),
            title: Text('Reject'),
          ),
        ),
      ]);
    }

    return popupItems;
  }

  void deleteAction(TempQuote tempQuote) async {
    if (widget.onBeforeDelete != null) {
      widget.onBeforeDelete();
    }

    bool success = false;

    if (widget.canManage) {
      success = await TempQuotesActions.deleteTempQuoteAdmin(
        context: context,
        tempQuote: tempQuote,
      );
    } else {
      success = await TempQuotesActions.deleteTempQuote(
        context: context,
        tempQuote: tempQuote,
      );
    }

    if (widget.onAfterDelete != null) {
      widget.onAfterDelete(success);
    }
  }

  void editAction(TempQuote tempQuote) async {
    DataQuoteInputs.populateWithTempQuote(tempQuote);

    await context.router.root.push(
      DashboardPageRoute(
        children: [
          AddQuoteStepsRoute(),
        ],
      ),
    );

    if (widget.onNavBack != null) {
      widget.onNavBack();
    }
  }

  void copyFromAction(TempQuote tempQuote) async {
    DataQuoteInputs.populateWithTempQuote(tempQuote, copy: true);

    context.router.root
        .navigate(DashboardPageRoute(children: [AddQuoteStepsRoute()]));
  }

  void onLongPress() {
    final children = [
      ListTile(
        title: Text('Edit'),
        trailing: Icon(
          Icons.edit,
        ),
        onTap: () {
          Navigator.of(context).pop();
          editAction(widget.tempQuote);
        },
      ),
      ListTile(
        title: Text('Copy from'),
        trailing: Icon(
          Icons.copy,
        ),
        onTap: () {
          Navigator.of(context).pop();
          copyFromAction(widget.tempQuote);
        },
      ),
      ListTile(
        title: Text('Delete'),
        trailing: Icon(
          Icons.delete_forever,
        ),
        onTap: () {
          Navigator.of(context).pop();
          deleteAction(widget.tempQuote);
        },
      ),
    ];

    if (widget.canManage) {
      children.addAll([
        ListTile(
          title: Text('Validate'),
          trailing: Icon(
            Icons.check,
          ),
          onTap: () {
            Navigator.of(context).pop();
            validateAction(widget.tempQuote);
          },
        ),
        ListTile(
          title: Text('Reject'),
          trailing: Icon(
            Icons.close,
          ),
          onTap: () {
            Navigator.of(context).pop();
            rejectAction(widget.tempQuote);
          },
        ),
      ]);
    }

    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
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
  }

  void rejectAction(TempQuote tempQuote) async {
    final size = MediaQuery.of(context).size;

    if (size.width > Constants.maxMobileWidth &&
        size.height > Constants.maxMobileWidth) {
      await showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            enableDrag: true,
            margin: const EdgeInsets.only(
              left: 120.0,
              right: 120.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: FlashBar(
              message: Container(
                height: MediaQuery.of(context).size.height - 100.0,
                padding: const EdgeInsets.all(60.0),
                child: RejectTempQuote(tempQuote: tempQuote),
              ),
            ),
          );
        },
      );
    } else {
      await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => RejectTempQuote(
          scrollController: ModalScrollController.of(context),
          tempQuote: tempQuote,
        ),
      );
    }
  }

  void validateAction(TempQuote tempQuote) async {
    if (widget.onBeforeValidate != null) {
      widget.onBeforeValidate();
    }

    final userAuth = stateUser.userAuth;

    final success = await TempQuotesActions.validateTempQuote(
      tempQuote: tempQuote,
      uid: userAuth.uid,
    );

    if (widget.onAfterValidate != null) {
      widget.onAfterValidate(success);
    }
  }

  List<SwipeAction> getLeadingActions() {
    final actions = <SwipeAction>[];

    if (widget.canManage) {
      actions.addAll([
        SwipeAction(
          title: 'Validate',
          icon: Icon(Icons.check, color: Colors.white),
          color: stateColors.validation,
          onTap: (CompletionHandler handler) {
            handler(false);
            validateAction(widget.tempQuote);
          },
        ),
        SwipeAction(
          title: 'Reject',
          icon: Icon(Icons.cancel, color: Colors.white),
          color: stateColors.secondary,
          onTap: (CompletionHandler handler) {
            handler(false);
            rejectAction(widget.tempQuote);
          },
        ),
      ]);
    }

    actions.add(
      SwipeAction(
        title: 'Delete',
        icon: Icon(Icons.delete, color: Colors.white),
        color: stateColors.deletion,
        nestedAction: SwipeNestedAction(title: "Confirm?"),
        onTap: (CompletionHandler handler) {
          handler(false);
          deleteAction(widget.tempQuote);
        },
      ),
    );

    return actions;
  }

  List<SwipeAction> getTrailingActions() {
    final actions = <SwipeAction>[];
    final tempQuote = widget.tempQuote;

    actions.addAll([
      SwipeAction(
        title: 'Copy from...',
        icon: Icon(Icons.copy, color: Colors.white),
        color: stateColors.primary,
        onTap: (CompletionHandler handler) {
          handler(false);
          copyFromAction(tempQuote);
        },
      ),
      SwipeAction(
        title: 'Edit',
        icon: Icon(Icons.edit, color: Colors.white),
        color: stateColors.secondary,
        onTap: (CompletionHandler handler) {
          handler(false);
          editAction(tempQuote);
        },
      ),
    ]);

    return actions;
  }
}
