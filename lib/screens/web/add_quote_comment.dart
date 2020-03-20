import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/utils/on_long_press_nav_back.dart';
import 'package:memorare/utils/router.dart';

class AddQuoteComment extends StatefulWidget {
  @override
  _AddQuoteCommentState createState() => _AddQuoteCommentState();
}

class _AddQuoteCommentState extends State<AddQuoteComment> {
  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  String comment = '';

  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _commentController.text = AddQuoteInputs.comment;
  }

  @override
  Widget build(BuildContext context) {
    return AddQuoteLayout(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(
                onLongPress: () => onLongPressNavBack(context),
              ),
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

  Widget body() {
    return SizedBox(
      width: 400.0,
      child: Column(
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            child: title(),
          ),

          FadeInY(
            beginY: beginY,
            delay: delay + (1 * delayStep),
            child: commentInput()),

          FadeInY(
            beginY: beginY,
            delay: delay + (2 * delayStep),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Click on the bottom right button to propose your quote.',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),

          FadeInY(
            beginY: beginY,
            delay: delay + (3 * delayStep),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: FlatButton(
                onPressed: () => FluroRouter.router.pop(context),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Previous',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget commentInput() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 60.0),
          child: TextField(
              minLines: 2,
              maxLines: null,
              autofocus: true,
              controller: _commentController,
              focusNode: _commentFocusNode,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add a comment about the quote'
              ),
              onChanged: (newValue) {
                comment = newValue;
                AddQuoteInputs.comment = newValue;
              },
            ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  AddQuoteInputs.comment = '';
                  _commentController.clear();
                  _commentFocusNode.requestFocus();
                },
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Clear comment',
                  ),
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget helpButton() {
    return IconButton(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help)
      ),
      iconSize: 40.0,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 500.0,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        'Help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 500.0,
                    child: Opacity(
                      opacity: .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• Comment is optional',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• Use it if you want to specify the context, the hidden meaning of the quote or something related',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ],
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

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add comment',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        Opacity(
          opacity: 0.6,
          child: Text(
            '5/5',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
