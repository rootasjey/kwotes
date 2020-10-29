import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/utils/language.dart';

class AddQuoteContent extends StatefulWidget {
  final Function onSaveDraft;

  AddQuoteContent({this.onSaveDraft});

  @override
  _AddQuoteContentState createState() => _AddQuoteContentState();
}

class _AddQuoteContentState extends State<AddQuoteContent> {
  bool isKeyHandled = false;

  FocusNode nameFocusNode;
  FocusNode clearFocusNode;

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    clearFocusNode = FocusNode();
    nameController.text = DataQuoteInputs.quote.name;
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    clearFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          quoteInput(),
          actionsInput(),
        ],
      ),
    );
  }

  Widget actionsInput() {
    final isSmall = MediaQuery.of(context).size.width < 600.0;

    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        top: 40.0,
        bottom: 30.0,
      ),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 10.0,
        children: <Widget>[
          langSelect(),
          clearAction(isSmall: isSmall),
          saveDraftAction(isSmall: isSmall),
        ],
      ),
    );
  }

  Widget clearAction({bool isSmall = false}) {
    if (isSmall) {
      return IconButton(
        tooltip: 'Clear content',
        onPressed: () {
          DataQuoteInputs.quote.name = '';
          nameController.clear();
          nameFocusNode.requestFocus();
        },
        icon: Opacity(
          opacity: 0.6,
          child: Icon(Icons.delete_sweep),
        ),
      );
    }

    return OutlinedButton.icon(
      focusNode: clearFocusNode,
      onPressed: () {
        DataQuoteInputs.quote.name = '';
        nameController.clear();
        nameFocusNode.requestFocus();
      },
      icon: Opacity(
        opacity: 0.6,
        child: Icon(Icons.delete_sweep),
      ),
      label: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear content',
        ),
      ),
    );
  }

  Widget langSelect() {
    return DropdownButton<String>(
      value: DataQuoteInputs.quote.lang,
      style: TextStyle(
        color: stateColors.primary,
        fontSize: 20.0,
      ),
      icon: Icon(Icons.language),
      iconEnabledColor: stateColors.primary,
      onChanged: (newValue) {
        setState(() {
          DataQuoteInputs.quote.lang = newValue;
        });
      },
      items: Language.available().map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
    );
  }

  Widget quoteInput() {
    return TextField(
      maxLines: null,
      autofocus: true,
      focusNode: nameFocusNode,
      controller: nameController,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (newValue) {
        DataQuoteInputs.quote.name = newValue;
      },
      style: TextStyle(
        fontSize: 22.0,
      ),
      decoration: InputDecoration(
        hintText: 'Type your quote...',
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  Widget saveDraftAction({bool isSmall = false}) {
    if (isSmall) {
      return IconButton(
        tooltip: 'Save draft',
        onPressed: widget.onSaveDraft,
        icon: Opacity(
          opacity: 0.6,
          child: Icon(Icons.save_alt),
        ),
      );
    }

    return OutlinedButton.icon(
      focusNode: clearFocusNode,
      onPressed: widget.onSaveDraft,
      icon: Opacity(opacity: 0.6, child: Icon(Icons.save_alt)),
      label: Opacity(
        opacity: 0.6,
        child: Text(
          'Save draft',
        ),
      ),
    );
  }
}
