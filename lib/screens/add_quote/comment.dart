import 'package:flutter/material.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddQuoteComment extends StatefulWidget {
  @override
  _AddQuoteCommentState createState() => _AddQuoteCommentState();
}

class _AddQuoteCommentState extends State<AddQuoteComment> {
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    commentController.text = DataQuoteInputs.comment;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        commentCardInput(),
      ],
    );
  }

  Widget actionsInput({
    VoidCallback onClearInput,
    String clearInputText = 'Clear input',
  }) {
    double left = 40.0;
    double spacing = 20.0;

    if (MediaQuery.of(context).size.width < 600.0) {
      spacing = 5.0;
      left = 0.0;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 20.0,
        left: left,
      ),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          OutlinedButton.icon(
            onPressed: onClearInput,
            icon: Opacity(
              opacity: 0.6,
              child: Icon(Icons.clear),
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                clearInputText,
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: stateColors.foreground,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Opacity(
              opacity: 0.6,
              child: Icon(Icons.check),
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Save',
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: stateColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget commentCardInput() {
    final comment = DataQuoteInputs.comment;

    return Container(
      width: 300.0,
      padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: () async {
            await showMaterialModalBottomSheet(
                context: context,
                builder: (context, scrollController) {
                  return commentInput();
                });

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Comment',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      comment != null && comment.isNotEmpty
                          ? comment
                          : 'Tap to edit',
                    ),
                  ],
                ),
              ),
              Icon(Icons.short_text),
            ]),
          ),
        ),
      ),
    );
  }

  Widget commentInput() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleButton(
                onTap: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  size: 20.0,
                  color: stateColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          "Comment",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Useful information or context",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 50.0,
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
                labelText: 'e.g. This quote means...',
              ),
              style: TextStyle(
                fontSize: 20.0,
              ),
              onChanged: (newValue) {
                DataQuoteInputs.comment = newValue;
              },
            ),
          ),
          actionsInput(
            onClearInput: () {
              DataQuoteInputs.comment = '';
              commentController.clear();
              commentFocusNode.requestFocus();
            },
          ),
        ],
      ),
    );
  }
}
