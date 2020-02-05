import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/horizontal_card.dart';
import 'package:memorare/types/quotidian.dart';

class PreviousQuotidians extends StatefulWidget {
  @override
  _PreviousQuotidiansState createState() => _PreviousQuotidiansState();
}

class _PreviousQuotidiansState extends State<PreviousQuotidians> {
  Quotidian quotidian;
  bool isLoading = false;

  @override
  initState() {
    super.initState();

    if (quotidian != null) { return; }
    fetchPreviousQuotidian();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500.0,
      child: Container(
        decoration: BoxDecoration(color: Color(0xFFEDEDEC)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                'YESTERDAY',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),

            SizedBox(
              width: 50.0,
              child: Divider(thickness: 2.0,),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Quotes of the past.'
                ),
              ),
            ),

            createCard(),
          ],
        ),
      )
    );
  }

  Widget createCard() {
    if (isLoading) {
      return HorizontalCard(
        quoteName: 'Loading...',
        authorName: '...',
      );
    }

    if (!isLoading && quotidian == null) {
      return HorizontalCard(
        quoteName: 'Sorry, a bug has slipped through. Try reloading the page.',
      );
    }

    return HorizontalCard(
      authorName: quotidian.quote.author.name,
      quoteId: quotidian.quote.id,
      quoteName: quotidian.quote.name,
    );
  }

  void fetchPreviousQuotidian() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('quotidians')
        .doc('02:02:2020')
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        quotidian = Quotidian.fromJSON(doc.data());
        isLoading = false;
      });

    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
