import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/components/web/circle_author.dart';
import 'package:memorare/components/web/reference_card.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:share/share.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool hasNext                = true;
  bool hasErrors              = false;
  bool isFabVisible           = false;
  bool isLoading              = false;
  bool isLoadingMore          = false;
  bool isSearchingAuthors     = false;
  bool isSearchingQuotes      = false;
  bool isSearchingReferences  = false;

  final authorsResults = List<Author>();
  final quotesResults = List<Quote>();
  final referencesResults = List<Reference>();

  int limit = 30;

  final pageRoute = SearchRoute;
  FocusNode searchFocusNode;
  ScrollController scrollController;

  String searchInputValue = '';

  TextEditingController searchInputController;

  Timer _searchTimer;

  var lastDoc;

  @override
  initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchInputController = TextEditingController();
    scrollController = ScrollController();
  }

  @override
  dispose() {
    searchFocusNode.dispose();
    scrollController.dispose();
    searchInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        FloatingActionButton(
          onPressed: () {
            scrollController.animateTo(
              0.0,
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: stateColors.primary,
          foregroundColor: Colors.white,
          child: Icon(Icons.arrow_upward),
        ) : null,
      body: body(),
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: () async {
        await search();
        return null;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

          // Load more scenario
          if (scrollNotif.metrics.pixels <
              scrollNotif.metrics.maxScrollExtent) {
            return false;
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            HomeAppBar(
              title: 'Search',
              automaticallyImplyLeading: true,
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 100.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  searchHeader(),

                  quotesSection(),
                  authorsSection(),
                  referencesSection(),

                  Padding(padding: const EdgeInsets.only(bottom: 300.0)),
                ]),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget authorsSection() {
    if (searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView = authorsResults.isEmpty
      ? emptyView('authors')
      : authorsResultsView();

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(
            text: '${authorsResults.length} authors',
          ),

          dataView,
        ],
      ),
    );
  }

  Widget quotesSection() {
    if (searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView = quotesResults.isEmpty
      ? emptyView('quotes')
      : quotesResultsView();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(
          text: '${quotesResults.length} quotes',
        ),

        dataView,
      ],
    );
  }

  Widget referencesSection() {
    if (searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView = quotesResults.isEmpty
      ? emptyView('quotes')
      : referencesResultsView();

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(
            text: '${referencesResults.length} references',
          ),

          dataView,
        ],
      ),
    );
  }

  Widget titleSection({String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26.0,
          color: stateColors.primary,
        ),
      ),
    );
  }

  Widget emptyView(String subject) {
    return Opacity(
      opacity: 0.6,
      child: Text(
        'No $subject found for "$searchInputValue"',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget errorView(String subject) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Opacity(
          opacity: 0.6,
          child: Text(
            'There was an issue while searching $subject for "$searchInputValue". You can try again.',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),

        OutlineButton.icon(
          onPressed: () {
            switch (subject) {
              case 'quotes':
                searchQuotes();
                break;
              case 'authors':
                searchAuthors();
                break;
              case 'references':
                searchReferences();
                break;
              default:
            }
          },
          icon: Icon(Icons.refresh),
          label: Text('Retry'),
        ),
      ]),
    );
  }

  Widget searchActions() {
    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: [
        RaisedButton.icon(
          onPressed: () {
            searchInputValue = '';
            searchInputController.clear();
            searchFocusNode.requestFocus();

            setState(() {});
          },
          icon: Opacity(opacity: 0.6, child: Icon(Icons.clear)),
          label: Opacity(
            opacity: 0.6,
            child: Text(
              'Clear content',
            ),
          )
        ),
      ]
    );
  }

  Widget searchHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 50.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchInput(),
          searchActions(),
          searchResultsData(),
        ],
      ),
    );
  }

  Widget searchInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: TextField(
        maxLines: null,
        autofocus: true,
        focusNode: searchFocusNode,
        controller: searchInputController,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (newValue) {
          final refresh = searchInputValue != newValue && newValue.isEmpty;

          searchInputValue = newValue;

          if (newValue.isEmpty) {
            if (refresh) { setState(() {}); }
            return;
          }

          if (_searchTimer != null) {
            _searchTimer.cancel();
          }

          _searchTimer = Timer(
            500.milliseconds,
            () => search(),
          );
        },
        style: TextStyle(
          fontSize: 36.0,
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search quote...',
          border: OutlineInputBorder(
            borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget searchResultsData() {
    if (searchInputValue.isEmpty) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          children: <Widget>[
            Text(
              '${quotesResults.length + authorsResults.length + referencesResults.length} results in total',
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),

            SizedBox(
              width: 200.0,
              child: Divider(thickness: 1.0,),
            ),
          ],
        ),
      ),
    );
  }

  Widget authorsResultsView() {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: authorsResults.map((author) {
        return CircleAuthor(
          author: author,
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'share') {
              shareAuthor(author);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Widget quotesResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: quotesResults.map((quote) {
        return QuoteRow(
          quote: quote,
          quoteId: quote.id,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              )),
          ],
          onSelected: (value) {
            if (value == 'share') {
              shareQuote(quote);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Widget referencesResultsView() {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: referencesResults.map((reference) {
        return ReferenceCard(
          height: 230.0,
          width: 170.0,
          id: reference.id,
          imageUrl: reference.urls.image,
          name: reference.name,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              )),
          ],
          onSelected: (value) {
            if (value == 'share') {
              shareReference(reference);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Future search() async {
    searchAuthors();
    searchQuotes();
    searchReferences();
  }

  void searchAuthors() async {
    setState(() {
      isSearchingAuthors = false;
      authorsResults.clear();
    });

    try {
      final snapshot = await Firestore.instance
        .collection('authors')
        .where('name', isGreaterThanOrEqualTo: searchInputValue)
        .limit(10)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        return;
      }

      snapshot.documents.forEach((element) {
        final data = element.data;
        data['id'] = element.documentID;

        final author = Author.fromJSON(data);
        authorsResults.add(author);
      });

      setState(() {
        isSearchingAuthors = false;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void searchQuotes() async {
    setState(() {
      isSearchingQuotes = false;
      quotesResults.clear();
    });

    try {
      final snapshot = await Firestore.instance
        .collection('quotes')
        .where('name', isGreaterThanOrEqualTo: searchInputValue)
        .limit(10)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        return;
      }

      snapshot.documents.forEach((element) {
        final data = element.data;
        data['id'] = element.documentID;

        final quote = Quote.fromJSON(data);
        quotesResults.add(quote);
      });

      setState(() {
        isSearchingQuotes = false;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void searchReferences() async {
    setState(() {
      isSearchingReferences = false;
      referencesResults.clear();
    });

    try {
      final snapshot = await Firestore.instance
        .collection('references')
        .where('name', isGreaterThanOrEqualTo: searchInputValue)
        .limit(10)
        .getDocuments();

      if (snapshot.documents.isEmpty) {
        return;
      }

      snapshot.documents.forEach((element) {
        final data = element.data;
        data['id'] = element.documentID;

        final reference = Reference.fromJSON(data);
        referencesResults.add(reference);
      });

      setState(() {
        isSearchingReferences = false;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void shareAuthor(Author author) {
    if (kIsWeb) {
      shareAuthorWeb(author);
      return;
    }

    shareAuthorMobile(author);
  }

  void shareAuthorWeb(Author author) async {
    String sharingText = author.name;
    final urlReference = 'https://outofcontext.app/#/reference/${author.id}';

    if (author.job != null && author.job.isNotEmpty) {
      sharingText += ' (${author.job})';
    }

    final hashtags = '&hashtags=outofcontext';

    await launch(
      'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
    );
  }

  void shareAuthorMobile(Author author) {
    final RenderBox box = context.findRenderObject();
    String sharingText = author.name;
    final urlReference = 'https://outofcontext.app/#/reference/${author.id}';

    if (author.job != null && author.job.isNotEmpty) {
      sharingText += ' (${author.job})';
    }

    sharingText += ' - URL: $urlReference';

    Share.share(
      sharingText,
      subject: 'Out Of Context',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  void shareQuote(Quote quote) {
    if (kIsWeb) {
      shareTwitter(quote: quote,);
      return;
    }

    shareFromMobile(context: context, quote: quote);
  }

  void shareReference(Reference reference) {
    if (kIsWeb) {
      shareReferenceWeb(reference);
      return;
    }

    shareReferenceMobile(reference);
  }

  void shareReferenceWeb(Reference reference) async {
    String sharingText = reference.name;
    final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    final hashtags = '&hashtags=outofcontext';

    await launch(
      'https://twitter.com/intent/tweet?via=outofcontextapp&text=$sharingText$hashtags&url=$urlReference',
    );
  }

  void shareReferenceMobile(Reference reference) {
    final RenderBox box = context.findRenderObject();
    String sharingText = reference.name;
    final urlReference = 'https://outofcontext.app/#/reference/${reference.id}';

    if (reference.type.primary.isNotEmpty) {
      sharingText += ' (${reference.type.primary})';
    }

    sharingText += ' - URL: $urlReference';

    Share.share(
      sharingText,
      subject: 'Out Of Context',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
