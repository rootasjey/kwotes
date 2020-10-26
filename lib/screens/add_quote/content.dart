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
          quoteActionsInput(),
        ],
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

  Widget quoteActionsInput() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        top: 40.0,
        bottom: 30.0,
      ),
      child: Wrap(
        children: <Widget>[
          langSelect(),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
          ),
          FlatButton.icon(
              focusNode: clearFocusNode,
              onPressed: () {
                DataQuoteInputs.quote.name = '';
                nameController.clear();
                nameFocusNode.requestFocus();
              },
              icon: Opacity(opacity: 0.6, child: Icon(Icons.clear)),
              label: Opacity(
                opacity: 0.6,
                child: Text(
                  'Clear content',
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
          ),
          FlatButton.icon(
              focusNode: clearFocusNode,
              onPressed: widget.onSaveDraft,
              icon: Opacity(opacity: 0.6, child: Icon(Icons.save)),
              label: Opacity(
                opacity: 0.6,
                child: Text(
                  'Save draft',
                ),
              )),
        ],
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
}
