import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/screens/add_quote/reference.dart';
import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditQuote extends StatefulWidget {
  final String quoteId;
  final Quote quote;

  const EditQuote({
    Key key,
    @required @PathParam() this.quoteId,
    this.quote,
  }) : super(key: key);

  @override
  _EditQuoteState createState() => _EditQuoteState();
}

class _EditQuoteState extends State<EditQuote> {
  bool hasErrors = false;
  bool isLoading = false;
  bool isSaving = false;

  DocumentSnapshot quoteDoc;

  Quote quote;

  String errorDescription = '';

  @override
  initState() {
    super.initState();

    if (widget.quote == null) {
      fetch();
    } else {
      quote = widget.quote;
      fillDataInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || hasErrors) {
      return localView();
    }

    return AddQuoteSteps();
  }

  Widget localView() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PageAppBar(
            textTitle: "Edit quote",
            textSubTitle: quote != null ? quote.name : "",
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              body(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (isSaving) {
      return loadingView(message: "Saving reference data...");
    }

    if (hasErrors) {
      return errorView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AddQuoteReference(),
    );
  }

  Widget errorView() {
    if (errorDescription.isEmpty) {
      errorDescription = "Sorry there was an unexpected error."
          "Please try again or contact us if the issue persists.";
    }

    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: [
          Opacity(
            opacity: 0.6,
            child: Icon(
              UniconsLine.exclamation_triangle,
              size: 42.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(errorDescription),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingView({String message = "Loading reference data..."}) {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: [
          AnimatedAppIcon(),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      hasErrors = false;
    });

    try {
      quoteDoc = await FirebaseFirestore.instance
          .collection('quotes')
          .doc(widget.quoteId)
          .get();

      if (!quoteDoc.exists) {
        setState(() {
          hasErrors = true;
          errorDescription = "The quote with the id ${widget.quoteId} "
              "doesn't exists. It may have been deleted";
        });
        return;
      }

      final quoteData = quoteDoc.data();
      quoteData['id'] = quoteDoc.id;
      quote = Quote.fromJSON(quoteData);

      setState(() {
        isLoading = false;
        fillDataInputs();
      });
    } catch (error) {
      appLogger.d(error);

      setState(() {
        isLoading = false;
        hasErrors = true;
        errorDescription = "There was an error while fetching quote data. "
            "Please try again later or contact us if the issue persists.";
      });
    }
  }

  void fillDataInputs() async {
    if (quote == null) {
      hasErrors = true;
      errorDescription = "There was an error while fetching quote data. "
          "Please try again later or contact us if the issue persists.";
      return;
    }

    DataQuoteInputs.quote = quote;

    DataQuoteInputs.author = Author.fromIdName(
      id: quote.author.id,
      name: quote.author.name,
    );

    DataQuoteInputs.reference = Reference.fromIdName(
      id: quote.reference.id,
      name: quote.reference.name,
    );

    DataQuoteInputs.isEditingPubQuote = true;
  }
}
