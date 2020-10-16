import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/quote_row.dart';
import 'package:memorare/components/base_page_app_bar.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/circle_author.dart';
import 'package:memorare/components/web/reference_card.dart';
import 'package:memorare/components/main_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:supercharged/supercharged.dart';

String _searchInputValue = '';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool hasNext = true;
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSearchingAuthors = false;
  bool isSearchingQuotes = false;
  bool isSearchingReferences = false;
  bool isNarrow = false;

  bool areQuotesVisible = true;
  bool areAuthorsVisible = true;
  bool areReferencesVisible = true;

  final authorsResults = List<Author>();
  final quotesResults = List<Quote>();
  final referencesResults = List<Reference>();

  final limit = 10;

  final pageRoute = SearchRoute;
  FocusNode searchFocusNode;
  ScrollController scrollController;

  TextEditingController searchInputController;

  Timer _searchTimer;

  DocumentSnapshot lastDoc;

  @override
  initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchInputController = TextEditingController();
    scrollController = ScrollController();

    if (_searchInputValue != null && _searchInputValue.isNotEmpty) {
      searchInputController.text = _searchInputValue;
      search();
    }
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
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
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
            )
          : null,
      body: RefreshIndicator(
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
                appBar(),
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    if (MediaQuery.of(context).size.width < 700.0) {
      return BasePageAppBar(
        title: TextButton.icon(
          onPressed: () {
            scrollController.animateTo(
              0,
              duration: 250.milliseconds,
              curve: Curves.easeIn,
            );
          },
          icon: AppIconHeader(
            padding: EdgeInsets.zero,
            size: 30.0,
          ),
          label: Text(
            'Search',
            style: TextStyle(
              fontSize: 22.0,
            ),
          ),
        ),
        showNavBackIcon: false,
      );
    }

    return MainAppBar(
      title: 'Search',
      automaticallyImplyLeading: true,
    );
  }

  Widget authorsResultsView() {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
      children: authorsResults.map((author) {
        return CircleAuthor(
          size: isNarrow ? 100.0 : 150.0,
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
              shareAuthor(context: context, author: author);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Widget authorsSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        authorsResults.isEmpty ? emptyView('authors') : authorsResultsView();

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        crossAxisAlignment:
            isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          titleSection(
            text: '${authorsResults.length} authors',
            iconData:
                areAuthorsVisible ? Icons.close_fullscreen : Icons.open_in_full,
            onPressed: () =>
                setState(() => areAuthorsVisible = !areAuthorsVisible),
          ),
          if (areAuthorsVisible) dataView,
        ],
      ),
    );
  }

  Widget body() {
    isNarrow = MediaQuery.of(context).size.width < 700.0;
    double horPadding = isNarrow ? 20.0 : 100.0;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          searchHeader(),
          quotesSection(),
          authorsSection(),
          referencesSection(),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 300.0,
            ),
          ),
        ]),
      ),
    );
  }

  Widget emptyView(String subject) {
    return Opacity(
      opacity: 0.6,
      child: Text(
        'No $subject found for "$_searchInputValue"',
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
            'There was an issue while searching $subject for "$_searchInputValue". You can try again.',
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
              shareQuote(context: context, quote: quote);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Widget quotesSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        quotesResults.isEmpty ? emptyView('quotes') : quotesResultsView();

    return Column(
      crossAxisAlignment:
          isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        titleSection(
          text: '${quotesResults.length} quotes',
          iconData:
              areQuotesVisible ? Icons.close_fullscreen : Icons.open_in_full,
          onPressed: () => setState(() => areQuotesVisible = !areQuotesVisible),
        ),
        if (areQuotesVisible) dataView,
      ],
    );
  }

  Widget referencesResultsView() {
    double height = 230.0;
    double width = 170.0;

    if (isNarrow) {
      height = 180.0;
      width = 120.0;
    }

    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: referencesResults.map((reference) {
        return ReferenceCard(
          height: height,
          width: width,
          id: reference.id,
          titleFontSize: isNarrow ? 14.0 : 18.0,
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
              shareReference(context: context, reference: reference);
              return;
            }
          },
        );
      }).toList(),
    );
  }

  Widget referencesSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        quotesResults.isEmpty ? emptyView('quotes') : referencesResultsView();

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        crossAxisAlignment:
            isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          titleSection(
            text: '${referencesResults.length} references',
            iconData: areReferencesVisible
                ? Icons.close_fullscreen
                : Icons.open_in_full,
            onPressed: () =>
                setState(() => areReferencesVisible = !areReferencesVisible),
          ),
          if (areReferencesVisible) dataView,
        ],
      ),
    );
  }

  Widget searchActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Wrap(spacing: 20.0, runSpacing: 20.0, children: [
        RaisedButton.icon(
            onPressed: () {
              _searchInputValue = '';
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
            )),
      ]),
    );
  }

  Widget searchHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: isNarrow ? 0.0 : 100.0,
        bottom: 60.0,
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
          final refresh = _searchInputValue != newValue && newValue.isEmpty;

          _searchInputValue = newValue;

          if (newValue.isEmpty) {
            if (refresh) {
              setState(() {});
            }
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
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget searchResultsData() {
    if (_searchInputValue.isEmpty) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${quotesResults.length + authorsResults.length + referencesResults.length} results in total',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              width: 200.0,
              child: Divider(
                thickness: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleSection({
    @required String text,
    VoidCallback onPressed,
    @required IconData iconData,
  }) {
    final padding = EdgeInsets.only(bottom: isNarrow ? 40.0 : 15.0);

    return Padding(
      padding: padding,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(iconData),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 26.0,
            color: stateColors.primary,
          ),
        ),
      ),
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
          .where('name', isGreaterThanOrEqualTo: _searchInputValue)
          .limit(limit)
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
          .where('name', isGreaterThanOrEqualTo: _searchInputValue)
          .limit(limit)
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
          .where('name', isGreaterThanOrEqualTo: _searchInputValue)
          .limit(limit)
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
}
