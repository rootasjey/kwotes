import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/horizontal_card.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/language.dart';
import 'package:supercharged/supercharged.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 90.0, horizontal: 80.0),
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

          createCard(),
        ],
      ),
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
        quoteName: "It's our mistakes which define us the most.",
      );
    }

    return HorizontalCard(
      authorId  : quotidian.quote.author.id,
      authorName: quotidian.quote.author.name,
      quoteId   : quotidian.quote.id,
      quoteName : quotidian.quote.name,
    );
  }

  void fetchPreviousQuotidian() async {
    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();
    final yesterday = now.subtract(1.days);

    String month = yesterday.month.toString();
    month = month.length == 2 ? month : '0$month';

    String day = yesterday.day.toString();
    day = day.length == 2 ? day : '0$day';

    try {
      final doc = await FirestoreApp.instance
        .collection('quotidians')
        .doc('${yesterday.year}:$month:$day:${Language.current}')
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
