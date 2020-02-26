import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/data/add_quote_inputs.dart';

class AddQuoteLayout extends StatefulWidget {
  final Widget child;

  AddQuoteLayout({this.child});

  @override
  _AddQuoteLayoutState createState() => _AddQuoteLayoutState();
}

class _AddQuoteLayoutState extends State<AddQuoteLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          proposeQuote();
        },
        label: Text('Propose'),
        icon: Icon(Icons.send),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: <Widget>[
          widget.child,
          Footer(),
        ],
      ),
    );
  }


  void proposeQuote() {
    if (AddQuoteInputs.name.isEmpty) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "The quote's content cannot be empty.",
      )
      ..show(context);

      return;
    }
  }
}
