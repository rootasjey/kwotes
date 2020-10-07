import 'package:flutter/material.dart';
import 'package:memorare/actions/quotes.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/temp_quote_row.dart';
import 'package:memorare/screens/add_quote/steps.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/temp_quote.dart';

class TempQuoteRowWithActions extends StatefulWidget {
  final bool canManage;
  final bool isDraft;

  final double cardSize;
  final double elevation;

  final Function itemBuilder;
  final Function onSelected;
  final Function onTap;

  final Function onBeforeDelete;
  final Function onBeforeValidate;
  final Function onAfterValidate;
  final Function onAfterDelete;

  final ItemLayoutType layout;
  final List<Widget> stackChildren;

  final TempQuote tempQuote;
  final QuoteRowActionType type;

  TempQuoteRowWithActions({
    this.canManage = false,
    this.cardSize = 250.0,
    this.elevation = 0.0,
    this.isDraft = false,
    this.itemBuilder,
    this.layout = ItemLayoutType.row,
    this.onSelected,
    this.onTap,
    this.onBeforeDelete,
    this.onBeforeValidate,
    this.onAfterValidate,
    this.onAfterDelete,
    @required this.tempQuote,
    this.type = QuoteRowActionType.published,
    this.stackChildren = const [],
  });

  @override
  _TempQuoteRowWithActionsState createState() =>
      _TempQuoteRowWithActionsState();
}

class _TempQuoteRowWithActionsState extends State<TempQuoteRowWithActions> {
  @override
  Widget build(BuildContext context) {
    final quote = widget.tempQuote;
    final popupItems = getPopupItems();

    return TempQuoteRow(
      tempQuote: quote,
      itemBuilder: (context) => popupItems,
      onSelected: onSelected,
      layout: widget.layout,
    );
  }

  void onSelected(value) async {
    final tempQuote = widget.tempQuote;

    switch (value) {
      case 'deletetempquote':
        if (widget.onBeforeDelete != null) {
          widget.onBeforeDelete();
        }

        final success = await deleteTempQuote(
          context: context,
          tempQuote: tempQuote,
        );

        if (widget.onAfterDelete != null) {
          widget.onAfterDelete(success);
        }

        break;
      case 'edit':
        AddQuoteInputs.navigatedFromPath = 'admintempquotes';
        AddQuoteInputs.populateWithTempQuote(tempQuote);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
        break;
      case 'validate':
        if (widget.onBeforeValidate != null) {
          widget.onBeforeValidate();
        }

        final userAuth = await userState.userAuth;

        final success = await validateTempQuote(
          tempQuote: tempQuote,
          uid: userAuth.uid,
        );

        if (widget.onAfterValidate != null) {
          widget.onAfterValidate(success);
        }

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
          )),
      PopupMenuItem(
          value: 'deletetempquote',
          child: ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text('Delete'),
          )),
    ];

    if (widget.canManage) {
      popupItems.addAll([
        PopupMenuItem(
            value: 'validate',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('Validate'),
            )),
      ]);
    }

    return popupItems;
  }
}
