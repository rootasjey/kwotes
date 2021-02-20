import 'package:figstyle/components/lang_popup_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:unicons/unicons.dart';

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
          langButton(),
          clearButton(isSmall: isSmall),
          saveDraftButton(isSmall: isSmall),
        ],
      ),
    );
  }

  Widget clearButton({bool isSmall = false}) {
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

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: OutlinedButton.icon(
        focusNode: clearFocusNode,
        onPressed: () {
          DataQuoteInputs.quote.name = '';
          nameController.clear();
          nameFocusNode.requestFocus();
        },
        icon: Opacity(
          opacity: 0.6,
          child: Icon(UniconsLine.times),
        ),
        label: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              'Clear',
            ),
          ),
        ),
      ),
    );
  }

  Widget langButton() {
    return SizedBox(
      height: 46.0,
      child: Card(
        elevation: 2.0,
        child: LangPopupMenuButton(
          opacity: 0.6,
          padding: EdgeInsets.zero,
          lang: DataQuoteInputs.quote.lang,
          onLangChanged: (newValue) {
            setState(() {
              DataQuoteInputs.quote.lang = newValue;
            });
          },
        ),
      ),
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

  Widget saveDraftButton({bool isSmall = false}) {
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

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: OutlinedButton.icon(
        focusNode: clearFocusNode,
        onPressed: widget.onSaveDraft,
        icon: Opacity(
          opacity: 0.6,
          child: Icon(
            UniconsLine.save,
          ),
        ),
        label: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              'Save draft',
            ),
          ),
        ),
      ),
    );
  }
}
