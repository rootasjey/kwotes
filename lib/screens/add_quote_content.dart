import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteContent extends StatefulWidget {
  final int maxSteps;
  final int step;
  final Function onNextStep;
  final Function onSaveDraft;

  AddQuoteContent({
    Key key,
    this.maxSteps,
    this.onNextStep,
    this.onSaveDraft,
    this.step
  }): super(key: key);

  @override
  _AddQuoteContentState createState() => _AddQuoteContentState();
}

class _AddQuoteContentState extends State<AddQuoteContent> {
  String lang = 'en';
  String name = '';

  List<String> langs = ['en', 'fr'];

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = AddQuoteInputs.quote.name;
    lang = AddQuoteInputs.quote.lang;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                header(),

                Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                  child: TextField(
                    maxLines: null,
                    autofocus: true,
                    controller: _nameController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (newValue) {
                      name = newValue;
                      AddQuoteInputs.quote.name = newValue;
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your quote there',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: accent,
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
                          AddQuoteInputs.quote.name = '';
                          _nameController.clear();
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

                langSelect(accent),

                saveDraftButton(),

                helpButton(),
              ],
            ),

            backButton(),
            forwardButton(),
          ],
        ),
      ],
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Text(
            'Add content',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Opacity(
          opacity: 0.6,
          child: Text(
            '${widget.step}/${widget.maxSteps}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
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
          AddQuoteInputs.quote.lang = newValue;
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

  Widget backButton() {
    return Positioned(
      top: 10.0,
      left: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
      )
    );
  }

  Widget forwardButton() {
    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          onPressed: () {
            if (widget.onNextStep != null) {
              widget.onNextStep();
            }
          },
          icon: Icon(Icons.arrow_forward),
        ),
      )
    );
  }

  Widget saveDraftButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: FlatButton(
        padding: EdgeInsets.all(10.0),
        onPressed: () {
          if (widget.onNextStep != null) {
            widget.onSaveDraft();
          }
        },
        child: Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.save),
              ),
              Text('Save to drafts'),
            ],
          ),
        )
      ),
    );
  }

  Widget helpButton() {
    return IconButton(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ListView(
              padding: EdgeInsets.all(40.0),
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
            );
          }
        );
      },
      icon: Icon(Icons.help),
    );
  }
}
