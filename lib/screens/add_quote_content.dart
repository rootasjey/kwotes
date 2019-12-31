import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteContent extends StatefulWidget {
  final int maxSteps;
  final int step;
  final Function onNextStepTap;

  AddQuoteContent({
    Key key,
    this.maxSteps,
    this.onNextStepTap,
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
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return ListView(
      children: <Widget>[
        Stack(
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
                  padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                  child: TextField(
                    maxLines: null,
                    autofocus: true,
                    controller: _nameController,
                    keyboardType: TextInputType.multiline,
                    onChanged: (newValue) {
                      name = newValue;
                      AddQuoteInputs.name = newValue;
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
                          AddQuoteInputs.clearQuoteName();
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

                nextStepButton(),
              ],
            ),

            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ],
        ),
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

  Widget nextStepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: FlatButton(
        padding: EdgeInsets.all(10.0),
        onPressed: () {
          if (widget.onNextStepTap != null) {
            widget.onNextStepTap();
          }
        },
        child: Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Next step'),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.arrow_forward),
              )
            ],
          ),
        )
      ),
    );
  }
}
