import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/types/quotidian.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecentHero extends StatefulWidget {
  @override
  _RecentHeroState createState() => _RecentHeroState();
}

class _RecentHeroState extends State<RecentHero> {
  bool hasErrors = false;
  bool isConnected = false;
  bool isLoading = false;

  final limit = 6;
  final scrollController = ScrollController();

  List<Quote> quotes = [];
  Quotidian quotidian;

  String lang = 'en';
  String textTitle = 'Recent';

  @override
  void initState() {
    super.initState();
    fetch();
    fetchQuotidian();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quotes.length == 0) {
      return emptyView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(),
        actionsRow(),
        gridView(),
      ],
    );
  }

  Widget actionsRow() {
    final now = DateTime.now();
    var icon = Icon(Icons.wb_sunny);

    if (now.hour < 6 || now.hour > 18) {
      icon = Icon(Icons.brightness_2);
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 80.0,
      ),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        children: [
          ElevatedButton.icon(
            onPressed: showQuotidian,
            icon: icon,
            label: Text(
              "Tap here to see today quote",
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              textTitle = 'Random';
              getRandomQuotes();
            },
            style: OutlinedButton.styleFrom(
              primary: stateColors.secondary,
            ),
            icon: FaIcon(FontAwesomeIcons.random),
            label: Text(
              "Random quotes",
            ),
          ),
          Tooltip(
            message: "Restore recent",
            child: OutlinedButton.icon(
              onPressed: () {
                textTitle = 'Recent';
                fetch();
              },
              icon: Icon(Icons.restore),
              label: Text(''),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingView() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 80.0,
        vertical: 40.0,
      ),
      height: MediaQuery.of(context).size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              'Recent...',
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AnimatedAppIcon(
            size: 80.0,
          ),
        ],
      ),
    );
  }

  Widget emptyView() {
    return Container(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.6,
                child: Text(
                  'Recent...',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: fetch,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "There's no recent quotes",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              "Maybe your this language has been added recently",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget errorView() {
    return Container(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.6,
                child: Text(
                  'Recent...',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: fetch,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "There was an error while loading",
                style: TextStyle(
                  fontSize: 26.0,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: Text(
              "Check your connection and try again.",
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget gridView() {
    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1000.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 80.0,
                right: 80.0,
                top: 20.0,
                bottom: 80.0,
              ),
              child: Wrap(
                spacing: 40.0,
                runSpacing: 40.0,
                children: quotes.map((quote) {
                  return QuoteRowWithActions(
                    quote: quote,
                    elevation: 4.0,
                    showAuthor: true,
                    cardHeight: 250.0,
                    cardWidth: 250.0,
                    padding: const EdgeInsets.all(20.0),
                    isConnected: isConnected,
                    componentType: ItemComponentType.card,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget sectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 80.0,
        top: 20.0,
      ),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          textTitle,
          style: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      quotes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => isLoading = false);

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() => isLoading = false);
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchQuotidian() async {
    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();

    String month = now.month.toString();
    month = month.length == 2 ? month : '0$month';

    String day = now.day.toString();
    day = day.length == 2 ? day : '0$day';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotidians')
          .doc('${now.year}:$month:$day:${lang.toLowerCase()}')
          .get();

      if (!snapshot.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        quotidian = Quotidian.fromJSON(snapshot.data());
      });
    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());
    }
  }

  void getRandomQuotes() async {
    setState(() {
      isLoading = true;
      hasErrors = false;
      quotes.clear();
    });

    try {
      final date = DateTime.now();
      final createdAt = date.subtract(Duration(days: Random().nextInt(90)));

      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('lang', isEqualTo: lang)
          .where('createdAt', isGreaterThanOrEqualTo: createdAt)
          .limit(6)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err.toString());

      setState(() {
        isLoading = false;
        hasErrors = true;
      });
    }
  }

  void showQuotidian() {
    showFlash(
      context: context,
      persistent: false,
      builder: (context, controller) {
        return Flash.dialog(
          controller: controller,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          enableDrag: true,
          margin: const EdgeInsets.only(
            left: 120.0,
            right: 120.0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          child: FlashBar(
            message: Container(
              height: MediaQuery.of(context).size.height - 100.0,
              padding: const EdgeInsets.all(60.0),
              child: QuotePage(
                pinnedAppBar: false,
                quote: quotidian.quote,
                quoteId: quotidian.quote.id,
              ),
            ),
          ),
        );
      },
    );
  }
}
