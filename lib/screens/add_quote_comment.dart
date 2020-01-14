import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';

class AddQuoteComment extends StatefulWidget {
  final int step;
  final int maxSteps;
  final Function onNextStep;
  final Function onPreviousStep;

  AddQuoteComment({
    Key key,
    this.maxSteps,
    this.onNextStep,
    this.onPreviousStep,
    this.step,
  }): super(key: key);

  @override
  _AddQuoteCommentState createState() => _AddQuoteCommentState();
}

class _AddQuoteCommentState extends State<AddQuoteComment> {
  String comment = '';

  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = AddQuoteInputs.comment;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            content(),
            backButton(),
            forwardButton(),
          ],
        )
      ],
    );
  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        header(),

        input(),

        helpButton(),
      ],
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Text(
                'Add comment',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        ),
      ],
    );
  }

  Widget input() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 60.0),
          child: SizedBox(
            width: 300.0,
            child: TextField(
              controller: _commentController,
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
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  _commentController.clear();
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

  Widget backButton() {
    return Positioned(
      top: 10.0,
      left: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          onPressed: () {
            if (widget.onPreviousStep != null) {
              widget.onPreviousStep();
            }
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
                    '- Comment is optional',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- Use it if you want to specify the context, the hidden meaning of the quote or something related',
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
