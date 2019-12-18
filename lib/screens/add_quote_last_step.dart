import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';

class AddQuoteLastStep extends StatefulWidget {
  final int step;
  final int maxSteps;
  final Function onPreviousPage;
  final Function onValidate;
  final Function onAddAnotherQuote;

  AddQuoteLastStep({
    Key key,
    this.maxSteps,
    this.onAddAnotherQuote,
    this.onPreviousPage,
    this.onValidate,
    this.step
  }): super(key: key);

  @override
  AddQuoteLastStepState createState() => AddQuoteLastStepState();
}

class AddQuoteLastStepState extends State<AddQuoteLastStep> {
  String comment = '';
  bool _isSending = false;
  bool isSuccess = false;
  bool isError = false;

  void complete() {
    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: AddQuoteInputs.isCompleted,
        children: <Widget>[
          if (!AddQuoteInputs.isCompleted)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Text(
                    'Last step!',
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
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                  child: Text(
                    'Alright! \n If you are satisfied with the data you provided, you can now propose your quote to moderators.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 24.0,
                    ),
                  ),
                ),

                if (_isSending == false)
                  Column(
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            _isSending = true;
                          });

                          if (widget.onValidate != null) {
                            widget.onValidate();
                          }
                        },
                        color: ThemeColor.success,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                              Text(
                                'Validate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),

                      FlatButton(
                        onPressed: () {
                          if (widget.onPreviousPage != null) {
                            widget.onPreviousPage();
                          }
                        },
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),

                if (_isSending)
                  CircularProgressIndicator(),
              ],
            ),

          if (AddQuoteInputs.isCompleted && !AddQuoteInputs.hasExceptions)
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.check, size: 40.0,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                    child: Text(
                      'Your quote has been successfully sent!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),

                  FlatButton(
                    onPressed: () {
                      if (widget.onAddAnotherQuote != null) {
                        widget.onAddAnotherQuote();
                      }
                    },
                    child: Text(
                      'Do you want to add another quote?',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                ],
              ),

          if (AddQuoteInputs.isCompleted && AddQuoteInputs.hasExceptions)
            Column(
              children: <Widget>[
                Icon(Icons.warning, size: 60.0,),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'There was an error while trying sending your quote. This maybe due to bad network.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22.0,
                      height: 1.3,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (widget.onValidate != null) {
                        widget.onValidate();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.arrow_back),
                          ),
                          Text(
                            'Try again',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}
