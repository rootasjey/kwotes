import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';

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

  final nameController = TextEditingController();

  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  @override
  void initState() {
    super.initState();

    nameController.text = AddQuoteInputs.quote.name;
    lang = AddQuoteInputs.quote.lang;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                header(),

                textInput(),

                langSelect(),

                Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      saveDraftButton(),
                      helpButton(),
                    ],
                  ),
                ),
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
        FadeInY(
          delay: delay + (1 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: EdgeInsets.only(top: 45.0),
            child: Text(
              'Add content',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (2 * delayStep),
          beginY: beginY,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              '${widget.step}/${widget.maxSteps}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget langSelect() {
    return FadeInY(
      delay: delay + (5 * delayStep),
      beginY: beginY,
      child: DropdownButton<String>(
        value: lang,
        style: TextStyle(
          color: stateColors.primary,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        underline: Container(
          height: 2.0,
          color: stateColors.primary,
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
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      top: 30.0,
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
      top: 30.0,
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
    return Column(
      children: <Widget>[
        MaterialButton(
          onPressed: () {
            if (widget.onSaveDraft != null) {
              widget.onSaveDraft();
            }
          },
          color: stateColors.primary,
          textColor: Colors.white,
          child: Icon(
            Icons.save_alt,
            size: 32,
          ),
          padding: EdgeInsets.all(16),
          shape: CircleBorder(),
        ),

        Opacity(
          opacity: 0.6,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text('Save to drafts'),
          ),
        ),
      ],
    );
  }

  Widget helpButton() {
    return FadeInY(
      delay: delay + (7 * delayStep),
      beginY: beginY,
      child: Column(
        children: <Widget>[
          MaterialButton(
            onPressed: () {
              showHelpSheet();
            },
            color: stateColors.primary,
            textColor: Colors.white,
            child: Icon(
              Icons.help_outline,
              size: 32,
            ),
            padding: EdgeInsets.all(16),
            shape: CircleBorder(),
          ),

          Opacity(
            opacity: 0.6,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text('Help'),
            ),
          ),
        ],
      ),
    );
  }

  void showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
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
                  '• Only the quote\'s content is required for submission',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '• Your quote should be short (<200 characters), catchy and memorable',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '• Quotes with a reference are preferred. A reference can be a movie, a book, a song, a game or from any cultural material',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '• The moderators can reject, remove or modify your quotes without notice, before or after validation',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '• Explicit, offensive and disrespectful words and ideas can be rejected',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '• Long press the green validation button (with a check mark) at any step to save your quote in drafts',
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
  }

  Widget textInput() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: delay + (3 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: EdgeInsets.only(
              left: 40.0,
              right: 40.0,
              top: 100.0,
            ),
            child: TextField(
              maxLines: null,
              autofocus: true,
              controller: nameController,
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
                    color: stateColors.primary,
                    width: 2.0,
                  )
                ),
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (4 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: EdgeInsets.only(right: 25.0, bottom: 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    AddQuoteInputs.quote.name = '';
                    nameController.clear();
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
        ),
      ],
    );
  }
}
