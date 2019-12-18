import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';

class AddQuoteComment extends StatefulWidget {
  final int step;
  final int maxSteps;

  AddQuoteComment({Key key, this.maxSteps, this.step}): super(key: key);

  @override
  AddQuoteCommentState createState() => AddQuoteCommentState();
}

class AddQuoteCommentState extends State<AddQuoteComment> {
  String _comment = '';

  String get comment => _comment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                'Add comment',
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
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: SizedBox(
                width: 300.0,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Add a comment about the quote'
                  ),
                  onChanged: (newValue) {
                    _comment = newValue;
                    AddQuoteInputs.comment = newValue;
                  },
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
