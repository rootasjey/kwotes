import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

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
  bool isSending = false;
  bool isCompleted = false;
  bool hasExceptions = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isSending = AddQuoteInputs.isSending;
      isCompleted = AddQuoteInputs.isCompleted;
      hasExceptions = AddQuoteInputs.hasExceptions;
    });
  }

  void notifyComplete({bool hasExceptionsResp}) {
    setState(() {
      hasExceptions = hasExceptionsResp;
      isSending = false;
      isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);
    final backgroundColor = themeColor.background;
    final accent = themeColor.accent;

    return Center(
      child: ListView(
        shrinkWrap: isCompleted,
        children: <Widget>[
          if (!isCompleted)
            sendComponent(),

          if (isCompleted && !hasExceptions)
            successComponent(backgroundColor: backgroundColor),

          if (isCompleted && hasExceptions)
            retryComponent(
              backgroundColor: backgroundColor,
              accent: accent
            ),
        ],
      ),
    );
  }

  Widget sendComponent() {
    return Column(
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

        if (isSending == false)
          Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());

                  if (widget.onValidate != null) {
                    setState(() {
                      isSending = true;
                    });

                    widget.onValidate();
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
                  if (widget.onPreviousPage != null) {
                    widget.onPreviousPage();
                  }
                },
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),

        if (isSending)
          CircularProgressIndicator(),
      ],
    );
  }

  Widget successComponent({Color backgroundColor}) {
    return Column(
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
            style: TextStyle(color: backgroundColor),
          ),
        )
      ],
    );
  }

  Widget retryComponent({Color backgroundColor, Color accent}) {
    return Column(
      children: <Widget>[
        Icon(Icons.warning, size: 60.0,),
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            AddQuoteInputs.exceptionMessage.isNotEmpty ?
              AddQuoteInputs.exceptionMessage :
              'There was an error while trying sending your quote. This maybe due to bad network.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: backgroundColor,
              fontSize: 22.0,
              height: 1.3,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: RaisedButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());

              if (widget.onValidate != null) {
                widget.onValidate();
              }
            },
            color: accent,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Icon(Icons.settings_backup_restore),
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
    );
  }
}
