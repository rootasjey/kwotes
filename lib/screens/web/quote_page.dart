import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/quote.dart';

class QuotePage extends StatefulWidget {
  final String quoteId;

  QuotePage({this.quoteId});

  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  bool isLoading;
  Quote quote;

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView(
        children: <Widget>[
          Text('Loading...')
        ],
      );
    }

    if (quote == null) {
      return Text('Error while loading the quote.');
    }

    return ListView(
      children: <Widget>[
        Text(
          quote.name,
        )
      ],
    );
  }


  void fetchQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('quotes')
        .doc(widget.quoteId)
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

      return;
      }

      setState(() {
        isLoading = false;
        quote = Quote.fromJSON(doc.data());
      });

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      print(error);
    }
  }
}
