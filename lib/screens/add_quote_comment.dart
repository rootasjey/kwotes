import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
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
  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentController.text = AddQuoteInputs.comment;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            body(),
            backButton(),
            forwardButton(),
          ],
        )
      ],
    );
  }

  Widget body() {
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
            FadeInY(
              delay: delay + (1 * delayStep),
              beginY: beginY,
              child: Padding(
                padding: EdgeInsets.only(top: 45.0),
                child: Text(
                  'Add comment',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
        ),
      ],
    );
  }

  Widget input() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: delay + (3 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: EdgeInsets.only(top: 100.0),
            child: SizedBox(
              width: 300.0,
              child: TextField(
                controller: commentController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add a comment about the quote'
                ),
                onChanged: (newValue) {
                  AddQuoteInputs.comment = newValue;
                },
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (4 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    AddQuoteInputs.comment = '';
                    commentController.clear();
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
        ),
      ],
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

  Widget helpButton() {
    return FadeInY(
      delay: delay + (5 * delayStep),
      beginY: beginY,
      child: IconButton(
        icon: Icon(Icons.help),
        iconSize: 40.0,
        padding: EdgeInsets.symmetric(vertical: 20.0),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Center(
                        child: Text(
                          'Help',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                    ),

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
              );
            }
          );
        },
      ),
    );
  }
}
