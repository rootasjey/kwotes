import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/data/mutationsOperations.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/screens/add_quote_author.dart';
import 'package:memorare/screens/add_quote_comment.dart';
import 'package:memorare/screens/add_quote_content.dart';
import 'package:memorare/screens/add_quote_last_step.dart';
import 'package:memorare/screens/add_quote_reference.dart';
import 'package:memorare/screens/add_quote_topics.dart';
import 'package:memorare/types/boolean_message.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final int maxSteps = 6;
  String mainTopic = '';
  bool _isFabVisible = true;

  final _pageController = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onNextPage() {
    if (_pageController.page < (maxSteps - 1)) {
      _pageController.nextPage(
        curve: ElasticInCurve(),
        duration: Duration(milliseconds: 300),
      );
    }
  }

  void onPreviousPage() async {
    if (_pageController.page > 0) {
      await _pageController.previousPage(
        curve: ElasticInCurve(),
        duration: Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isFabVisible ?
        FloatingActionButton(
          backgroundColor: ThemeColor.success,
          onPressed: () {
            validateQuote();
          },
          child: Icon(Icons.check,),
        ) :
        Padding(padding: EdgeInsets.all(0),),

      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          if (pageIndex == (maxSteps - 1)) {
            setState(() {
              _isFabVisible = false;
            });

            return;
          }

          setState(() {
            _isFabVisible = true;
          });
        },
        children: <Widget>[
          AddQuoteContent(step: 1, maxSteps: maxSteps),
          AddQuoteTopics(step: 2, maxSteps: maxSteps,),
          AddQuoteAuthor(step: 3, maxSteps: maxSteps,),
          AddQuoteReference(step: 4, maxSteps: maxSteps,),
          AddQuoteComment(step: 5, maxSteps: maxSteps),
          AddQuoteLastStep(
            step: 6,
            maxSteps: maxSteps,
            onPreviousPage: () { onPreviousPage(); },
            onValidate: () async {
              validateQuote();
            },
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
    final booleanMessage = await proposeQuote();

    if (booleanMessage.boolean) {
      AddQuoteInputs.isCompleted = true;
      AddQuoteInputs.hasExceptions = false;

      Flushbar(
        backgroundColor: ThemeColor.success,
        messageText: Text(
          'Your quote has been successfully proposed.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
      )..show(context);

      if (_pageController.page < (maxSteps - 1)) {
        _pageController.jumpToPage(maxSteps - 1);
      }

      return;
    }

    AddQuoteInputs.isCompleted = true;
    AddQuoteInputs.hasExceptions = true;

    Flushbar(
      backgroundColor: ThemeColor.error,
      messageText: Text(
        '${booleanMessage.message}',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  Future<BooleanMessage> proposeQuote() async {
    final clientsModels = Provider.of<HttpClientsModel>(context);

    if (clientsModels == null) {
      return BooleanMessage(
        boolean: false,
        message: 'Sorry, an error happenned. Please contact us by email or Twitter (More detail: null http).',
      );
    }

    final client = clientsModels.defaultClient.value;

    return client.mutate(
      MutationOptions(
        documentNode: MutationsOperations.propose,
        variables: {
          'name'          : AddQuoteInputs.name,
          'lang'          : AddQuoteInputs.lang,
          'topics'        : AddQuoteInputs.topics,
          'authorImgUrl'  : AddQuoteInputs.authorImgUrl,
          'authorName'    : AddQuoteInputs.authorName,
          'authorJob'     : AddQuoteInputs.authorJob,
          'authorSummary' : AddQuoteInputs.authorSummary,
          'authorUrl'     : AddQuoteInputs.authorUrl,
          'authorWikiUrl' : AddQuoteInputs.authorWikiUrl,
          'refImgUrl'     : AddQuoteInputs.refImgUrl,
          'refLang'       : AddQuoteInputs.refLang,
          'refName'       : AddQuoteInputs.refName,
          'refSubType'    : AddQuoteInputs.refSubType,
          'refSummary'    : AddQuoteInputs.refSummary,
          'refType'       : AddQuoteInputs.refType,
          'refPromoUrl'   : AddQuoteInputs.refPromoUrl,
          'refUrl'        : AddQuoteInputs.refUrl,
          'comment'       : AddQuoteInputs.comment,
        }
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return BooleanMessage(
          boolean: false,
          message: queryResult.exception.graphqlErrors.length > 0 ?
            queryResult.exception.graphqlErrors.first.message :
            queryResult.exception.clientException.message,
        );
      }

      return BooleanMessage(boolean: true,);

    }).catchError((error) {
      return BooleanMessage(
        boolean: false,
        message: error.toString(),
      );
    });
  }
}
