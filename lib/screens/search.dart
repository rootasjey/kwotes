import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/quote_row_with_actions.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/author_suggestion.dart';
import 'package:figstyle/types/reference_suggestion.dart';
import 'package:figstyle/utils/search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/share.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/circle_author.dart';
import 'package:figstyle/components/reference_card.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/quote.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<AuthorSuggestion> authorsSuggestions = [];
  List<Quote> quotesSuggestions = [];
  List<ReferenceSuggestion> referencesSuggestions = [];

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
      body: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
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
                    appBar(),
                    body(),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget appBar() {
    if (MediaQuery.of(context).size.width < 700.0) {
      return PageAppBar(
        textTitle: 'Search',
        expandedHeight: 60.0,
        showNavBackIcon: false,
        onTitlePressed: () {
          scrollController.animateTo(
            0,
            duration: 250.milliseconds,
            curve: Curves.easeIn,
          );
        },
      );
    }

    return DesktopAppBar(
      title: 'Search',
      padding: const EdgeInsets.only(left: 65.0),
      automaticallyImplyLeading: true,
    );
  }

  Widget authorsListView() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        top: 10.0,
      ),
      child: Wrap(
        spacing: 40.0,
        runSpacing: 40.0,
        alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
        children: authorsSuggestions.map((suggestion) {
          return CircleAuthor(
            size: isNarrow ? 100.0 : 150.0,
            author: suggestion.author,
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
                shareAuthor(context: context, author: suggestion.author);
                return;
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget authorsSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        authorsSuggestions.isEmpty ? emptyView('authors') : authorsListView();

    final length = authorsSuggestions.length;

    final text = length > 1 ? '$length authors' : '$length author';

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(
            text: text,
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
    double horPadding = isNarrow ? 0.0 : 100.0;

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
              bottom: 100.0,
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

  Widget quotesListView() {
    return Observer(builder: (context) {
      final isConnected = userState.isUserConnected;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: quotesSuggestions.map((quote) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 700.0,
                ),
                child: QuoteRowWithActions(
                  quote: quote,
                  quoteId: quote.id,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  color: stateColors.appBackground,
                  isConnected: isConnected,
                ),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget quotesSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView =
        quotesSuggestions.isEmpty ? emptyView('quotes') : quotesListView();

    final length = quotesSuggestions.length;

    final text = length > 1 ? '$length quotes' : '$length quote';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(
          text: text,
          iconData:
              areQuotesVisible ? Icons.close_fullscreen : Icons.open_in_full,
          onPressed: () => setState(() => areQuotesVisible = !areQuotesVisible),
        ),
        if (areQuotesVisible) dataView,
      ],
    );
  }

  Widget referencesListView() {
    double height = 230.0;
    double width = 170.0;

    if (isNarrow) {
      height = 180.0;
      width = 120.0;
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        top: 10.0,
      ),
      child: Wrap(
        spacing: 40.0,
        runSpacing: 40.0,
        children: referencesSuggestions.map((suggestion) {
          return ReferenceCard(
            height: height,
            width: width,
            id: suggestion.reference.id,
            titleFontSize: isNarrow ? 14.0 : 18.0,
            imageUrl: suggestion.reference.urls.image,
            name: suggestion.reference.name,
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
                shareReference(
                    context: context, reference: suggestion.reference);
                return;
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget referencesSection() {
    if (_searchInputValue.isEmpty) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    final dataView = referencesSuggestions.isEmpty
        ? emptyView('quotes')
        : referencesListView();

    final length = referencesSuggestions.length;

    final text = length > 1 ? '$length references' : '$length reference';

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection(
            text: text,
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
      padding: const EdgeInsets.only(left: 10.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 0.0,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              _searchInputValue = '';
              searchInputController.clear();
              searchFocusNode.requestFocus();

              setState(() {});
            },
            icon: Opacity(
              opacity: 0.6,
              child: Icon(Icons.delete_sweep),
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Clear input',
              ),
            ),
          ),
          OutlinedButton.icon(
              onPressed: () => FocusScope.of(context).unfocus(),
              label: Text(''),
              icon: Opacity(
                opacity: 0.6,
                child: Icon(Icons.keyboard_hide),
              )),
          OutlinedButton.icon(
            onPressed: () {
              launch('https://www.algolia.com/');
            },
            icon: Image.network(
              'https://res.cloudinary.com/hilnmyskv/image/upload/q_auto/v1604064568/Algolia_com_Website_assets/images/shared/algolia_logo/algolia-blue-mark.png',
              width: 20.0,
              height: 20.0,
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Search by Algolia',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: isNarrow ? 0.0 : 100.0,
        left: 20.0,
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
    final fontSize = MediaQuery.of(context).size.width < 390.0 ? 20.0 : 36.0;

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
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
          fontSize: fontSize,
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
      padding: const EdgeInsets.only(
        left: 10.0,
        top: 20.0,
      ),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${quotesSuggestions.length + authorsSuggestions.length + referencesSuggestions.length} results in total',
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
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
      ),
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
      authorsSuggestions.clear();
    });

    try {
      final query = algolia
          .index('authors')
          .search(_searchInputValue)
          .setHitsPerPage(10)
          .setPage(0);

      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => isSearchingAuthors = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final author = AuthorSuggestion.fromJSON(data);
        final fromReference = author.author.fromReference;

        if (fromReference != null &&
            fromReference.id != null &&
            fromReference.id.isNotEmpty) {
          try {
            final ref = await FirebaseFirestore.instance
                .collection('references')
                .doc(fromReference.id)
                .get();

            final refData = ref.data();
            refData['id'] = ref.id;

            author.parseReferenceJSON(refData);
          } catch (error) {}
        }

        authorsSuggestions.add(author);
      }

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
      quotesSuggestions.clear();
    });

    try {
      final query = algolia
          .index('quotes')
          .search(_searchInputValue)
          .setHitsPerPage(10)
          .setPage(0);

      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => isSearchingAuthors = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final quote = Quote.fromJSON(data);
        quotesSuggestions.add(quote);
      }

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
      referencesSuggestions.clear();
    });

    try {
      final query = algolia
          .index('references')
          .search(_searchInputValue)
          .setHitsPerPage(10)
          .setPage(0);

      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => isSearchingReferences = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final reference = ReferenceSuggestion.fromJSON(data);
        referencesSuggestions.add(reference);
      }

      setState(() {
        isSearchingReferences = false;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
