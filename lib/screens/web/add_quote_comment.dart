import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';

class AddQuoteComment extends StatefulWidget {
  @override
  _AddQuoteCommentState createState() => _AddQuoteCommentState();
}

class _AddQuoteCommentState extends State<AddQuoteComment> {
  String comment = '';

  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    commentController.text = AddQuoteInputs.comment;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        commentInput(),
      ],
    );
  }

  Widget commentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            left: 15.0,
          ),
          child: TextField(
            minLines: 1,
            maxLines: null,
            autofocus: true,
            controller: commentController,
            focusNode: commentFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              icon: Icon(Icons.edit),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              labelText: 'Add comment about the quote...',
            ),
            style: TextStyle(
              fontSize: 20.0,
            ),
            onChanged: (newValue) {
              comment = newValue;
              AddQuoteInputs.comment = newValue;
            },
          ),
        ),

        FlatButton.icon(
          onPressed: () {
            AddQuoteInputs.comment = '';
            commentController.clear();
            commentFocusNode.requestFocus();
          },
          icon: Opacity(
            opacity: 0.6,
            child: Icon(Icons.clear),
          ),
          label: Opacity(
            opacity: 0.6,
            child: Text(
              'Clear',
            ),
          )
        ),
      ],
    );
  }
}
