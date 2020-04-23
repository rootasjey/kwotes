import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';

class AddQuoteLastStep extends StatefulWidget {
  final int step;
  final int maxSteps;
  final Function onPreviousStep;
  final Function onSaveDraft;
  final Function onPropose;

  AddQuoteLastStep({
    this.maxSteps,
    this.onPreviousStep,
    this.onSaveDraft,
    this.onPropose,
    this.step
  });

  @override
  _AddQuoteLastStepState createState() => _AddQuoteLastStepState();
}

class _AddQuoteLastStepState extends State<AddQuoteLastStep> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        content(),
        backButton(),
      ],
    );
  }

  Widget content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        sendComponent(),
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

  Widget sendComponent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Text(
            'Last step!',
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
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              'Alright! \n If you are satisfied with the data you provided, you can now propose your quote to moderators.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          )
        ),

        Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());

                if (widget.onPropose != null) {
                  widget.onPropose();
                }
              },
              color: ThemeColor.success,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Validate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              )
            ),

            FlatButton(
              onPressed: () {
                if (widget.onPreviousStep != null) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  widget.onSaveDraft();
                }
              },
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  'Save draft',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
