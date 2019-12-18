import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteContent extends StatefulWidget {
  final int maxSteps;
  final int step;

  AddQuoteContent({
    Key key,
    this.maxSteps,
    this.step
  }): super(key: key);

  @override
  AddQuoteContentState createState() => AddQuoteContentState();
}

class AddQuoteContentState extends State<AddQuoteContent> {
  String _lang = 'en';
  String _name = '';

  String get lang => _lang;
  String get name => _name;

  List<String> langs = ['en', 'fr'];

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ThemeColor>(context).accent;

    return ListView(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                'Add content',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${widget.step}/${widget.maxSteps}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(40.0),
              child: TextField(
                maxLines: null,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                onChanged: (newValue) {
                  _name = newValue;
                  AddQuoteInputs.name = newValue;
                },
                decoration: InputDecoration(
                  hintText: 'Type your quote there',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: color,
                      width: 2.0,
                    )
                  ),
                ),
              ),
            ),

            DropdownButton<String>(
              value: _lang,
              style: TextStyle(
                color: color,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 2.0,
                color: color,
              ),
              onChanged: (newValue) {
                setState(() {
                  _lang = newValue;
                  AddQuoteInputs.lang = newValue;
                });
              },
              items: langs.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
