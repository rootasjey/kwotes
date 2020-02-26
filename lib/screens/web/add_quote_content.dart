import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/utils/router.dart';

class AddQuoteContent extends StatefulWidget {
  @override
  _AddQuoteContentState createState() => _AddQuoteContentState();
}

class _AddQuoteContentState extends State<AddQuoteContent> {
  String lang = 'en';
  String name = '';

  var _nameFocusNode = FocusNode();

  List<String> langs = ['en', 'fr'];

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = AddQuoteInputs.name;
    lang = AddQuoteInputs.lang;
  }

  @override
  Widget build(BuildContext context) {
    return AddQuoteLayout(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(),
              body(),
            ],
          ),

          Positioned(
            right: 50.0,
            top: 80.0,
            child: helpButton(),
          )
        ],
      ),
    );
  }

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add content',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        Opacity(
          opacity: 0.6,
          child: Text(
            '1/6',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget body() {
    return SizedBox(
      width: 500.0,
      child: Column(
        children: <Widget>[
          title(),

          Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 80.0),
            child: TextField(
              maxLines: null,
              autofocus: true,
              focusNode: _nameFocusNode,
              controller: _nameController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (newValue) {
                name = newValue;
                AddQuoteInputs.name = newValue;
              },
              decoration: InputDecoration(
                hintText: 'Type your quote there',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  )
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(right: 25.0, bottom: 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    AddQuoteInputs.clearQuoteName();
                    _nameController.clear();
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  },
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      'Clear quote content',
                    ),
                  )
                ),
              ],
            ),
          ),

          langSelect(Colors.blue),

          buttonsNavigation(),
        ],
      ),
    );
  }

  Widget langSelect(Color color) {
    return DropdownButton<String>(
      value: lang,
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
          lang = newValue;
          AddQuoteInputs.lang = newValue;
        });
      },
      items: langs.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
    );
  }

  Widget buttonsNavigation() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, bottom: 300.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FlatButton(
              onPressed: () {
                FluroRouter.router.pop(context);
              },
              shape: RoundedRectangleBorder(
                side: BorderSide(),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Cancel',
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FlatButton(
              onPressed: () {
                FluroRouter.router.pop(context);
              },
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Next',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget helpButton() {
    return IconButton(
      iconSize: 40.0,
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help)
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      'Help',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- Only the quote\'s content is required for submission',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- Your quote should be short (<200 characters), catchy and memorable',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- Quotes with a reference are preferred. A reference can be a movie, a book, a song, a game or from any cultural material',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- The moderators can reject, remove or modify your quotes without notice, before or after validation',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- Explicit, offensive and disrespectful words and ideas can be rejected',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '- Long press the green validation button (with a check mark) at any step to save your quote in drafts',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
