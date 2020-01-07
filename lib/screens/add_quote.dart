import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/screens/add_quote_author.dart';
import 'package:memorare/screens/add_quote_comment.dart';
import 'package:memorare/screens/add_quote_content.dart';
import 'package:memorare/screens/add_quote_last_step.dart';
import 'package:memorare/screens/add_quote_reference.dart';
import 'package:memorare/screens/add_quote_topics.dart';
import 'package:memorare/types/colors.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final int maxSteps = 6;
  String mainTopic = '';
  bool isFabVisible = true;

  var lastStepState = GlobalKey<AddQuoteLastStepState>();

  final _pageController = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onNextPage() async {
    if (_pageController.page < (maxSteps - 1)) {
      _pageController.jumpToPage(_pageController.page.toInt() + 1);
    }
  }

  void onPreviousPage() async {
    if (_pageController.page > 0) {
      _pageController.jumpToPage(_pageController.page.toInt() - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        InkWell(
          onLongPress: () => saveDraft(),
          child: FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: ThemeColor.success,
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              validateQuote();
            },
            child: Icon(Icons.check,),
          ),
        ) :
        Padding(padding: EdgeInsets.zero,),

      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          if (pageIndex == (maxSteps - 1)) {
            setState(() {
              isFabVisible = false;
            });

            return;
          }

          setState(() {
            isFabVisible = true;
          });
        },
        children: <Widget>[
          AddQuoteContent(
            step: 1,
            maxSteps: maxSteps,
            onNextStep: () => onNextPage(),
            onSaveDraft: () => saveDraft(),
          ),

          AddQuoteTopics(
            step: 2,
            maxSteps: maxSteps,
            onNextStep: () => onNextPage(),
            onPreviousStep: () => onPreviousPage(),
          ),

          AddQuoteAuthor(
            step: 3,
            maxSteps: maxSteps,
            onNextStep: () => onNextPage(),
            onPreviousStep: () => onPreviousPage(),
          ),

          AddQuoteReference(
            step: 4,
            maxSteps: maxSteps,
            onNextStep: () => onNextPage(),
            onPreviousStep: () => onPreviousPage(),
          ),

          AddQuoteComment(
            step: 5,
            maxSteps: maxSteps,
            onNextStep: () => onNextPage(),
            onPreviousStep: () => onPreviousPage(),
          ),

          AddQuoteLastStep(
            key: lastStepState,
            step: 6,
            maxSteps: maxSteps,
            onPreviousStep: () => onPreviousPage(),
            onValidate: () => validateQuote(),
            onSaveDraft: () => saveDraft(),
            onAddAnotherQuote: () {
              AddQuoteInputs.clearQuoteName();
              AddQuoteInputs.clearStatus();
              _pageController.jumpToPage(0);
            },
          ),
        ],
      ),
    );
  }

  void validateQuote() async {
    final booleanMessage = AddQuoteInputs.id.isEmpty ?
      await Mutations.createTempQuote(context: context) :
      await Mutations.updateTempQuote(context: context);

    String successMessage = AddQuoteInputs.id.isEmpty ?
      'Your quote has been successfully proposed.':
      'Your quote has been successfully saved.';

    if (_pageController.page < (maxSteps - 1)) {
      _pageController.jumpToPage(maxSteps - 1);
    }

    AddQuoteInputs.isCompleted = true;

    if (booleanMessage.boolean) {
      AddQuoteInputs.hasExceptions = false;

      Flushbar(
        backgroundColor: ThemeColor.success,
        messageText: Text(
          successMessage,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
      )..show(context);

      if (lastStepState != null && lastStepState.currentState != null) {
        lastStepState.currentState.notifyComplete(hasExceptionsResp: false);
      }

      return;
    }

    AddQuoteInputs.hasExceptions = true;
    AddQuoteInputs.exceptionMessage = booleanMessage.message;

    Flushbar(
      backgroundColor: ThemeColor.error,
      messageText: Text(
        '${booleanMessage.message}',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 3),
    )..show(context);

    if (lastStepState != null && lastStepState.currentState != null) {
      lastStepState.currentState.notifyComplete(hasExceptionsResp: true);
    }

    saveDraft();
  }

  void saveDraft() {
    Mutations.createDraft(context: context)
      .then((draftId) {
        Flushbar(
          backgroundColor: ThemeColor.success,
          messageText: Text('Your quote has been saved in drafts.'),
          duration: Duration(seconds: 3),
        )..show(context);
      });
  }
}
