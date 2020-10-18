import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/page_app_bar.dart';
import 'package:memorare/components/reference_row.dart';
import 'package:memorare/components/sliver_loading_view.dart';
import 'package:memorare/components/web/reference_card.dart';
import 'package:memorare/components/web/empty_content.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/main_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/enums.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

class References extends StatefulWidget {
  @override
  _ReferencesState createState() => _ReferencesState();
}

class _ReferencesState extends State<References> {
  bool descending = true;
  bool hasNext = true;
  bool hasErrors = false;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSearching = false;

  DocumentSnapshot lastDoc;
  HeaderViewType headerViewType = HeaderViewType.search;

  TextEditingController searchInputController;

  Timer _searchTimer;

  final referencesList = List<Reference>();
  final searchResults = List<Reference>();

  final pageRoute = ReferencesRoute;
  FocusNode searchFocusNode;
  ScrollController scrollController;

  int limit = 30;

  String searchInputValue = '';
  String lastSearchValue = '';

  var itemsLayout = ItemsLayout.grid;

  @override
  initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchInputController = TextEditingController();
    scrollController = ScrollController();

    initProps();
    fetch();
  }

  @override
  dispose() {
    searchFocusNode.dispose();
    scrollController.dispose();
    searchInputController.dispose();
    super.dispose();
  }

  void initProps() {
    descending = appLocalStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appLocalStorage.getItemsStyle(pageRoute);
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
      body: body(),
    );
  }

  Widget appBar() {
    return PageAppBar(
      textTitle: 'Options',
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
      descending: descending,
      onDescendingChanged: (newDescending) {
        if (descending == newDescending) {
          return;
        }

        descending = newDescending;
        fetch();

        appLocalStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appLocalStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
      additionalIconButtons: [
        FadeInY(
          beginY: 10.0,
          delay: 3.0,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Container(
              height: 25,
              width: 2.0,
              color: stateColors.foreground.withOpacity(0.5),
            ),
          ),
        ),
        FadeInY(
          beginY: 10.0,
          delay: 3.5,
          child: IconButton(
            onPressed: () {
              setState(() {
                searchInputValue = lastSearchValue;
                headerViewType = HeaderViewType.search;
              });
            },
            icon: Icon(Icons.search),
            color: stateColors.foreground.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget body() {
    return RefreshIndicator(
        onRefresh: () async {
          await fetch();
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

            // Don't load more search results.
            if (searchInputValue.isNotEmpty) {
              return false;
            }

            if (hasNext && !isLoadingMore) {
              fetchMore();
            }

            return false;
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              MainAppBar(
                title: 'References',
                automaticallyImplyLeading: true,
              ),
              headerViewType == HeaderViewType.options
                  ? appBar()
                  : searchHeader(),
              SliverPadding(padding: const EdgeInsets.only(top: 50.0)),
              bodyListContent(),
              SliverPadding(padding: const EdgeInsets.only(bottom: 300.0)),
            ],
          ),
        ));
  }

  Widget bodyListContent() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (referencesList.length == 0) {
      return emptyView();
    }

    final references =
        searchInputValue.isEmpty ? referencesList : searchResults;

    if (itemsLayout == ItemsLayout.grid) {
      return sliverGrid(references);
    }

    return sliverList(references);
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.sentiment_neutral,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title: "There's was an issue while loading all references",
            subtitle: 'Check your connection an try to refresh this page',
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () => fetch(),
          ),
        ),
      ]),
    );
  }

  Widget searchActions() {
    return Wrap(spacing: 20.0, runSpacing: 20.0, children: [
      RaisedButton.icon(
          onPressed: () {
            searchInputValue = '';
            lastSearchValue = '';
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
      RaisedButton.icon(
          onPressed: () {
            setState(() {
              lastSearchValue = searchInputValue;
              searchInputValue = '';
              headerViewType = HeaderViewType.options;
            });
          },
          icon: Opacity(opacity: 0.6, child: Icon(Icons.swap_horiz)),
          label: Opacity(
            opacity: 0.6,
            child: Text(
              'Switch to options',
            ),
          )),
    ]);
  }

  Widget searchHeader() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 100.0),
      sliver: SliverList(
          delegate: SliverChildListDelegate([
        searchInput(),
        searchActions(),
        searchResultsData(),
      ])),
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

          if (isSearching || newValue.isEmpty) {
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
          fontSize: 32.0,
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search reference...',
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget searchResultsData() {
    if (searchInputValue.isEmpty || isSearching) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          '${searchResults.length} results',
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
      ),
    );
  }

  Widget sliverGrid(List<Reference> references) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250.0,
          childAspectRatio: 0.6,
          mainAxisSpacing: 30.0,
          crossAxisSpacing: 30.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final reference = references.elementAt(index);

            return ReferenceCard(
              height: 260.0,
              width: 200.0,
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
                  shareReference(context: context, reference: reference);
                  return;
                }
              },
            );
          },
          childCount: references.length,
        ),
      ),
    );
  }

  Widget sliverList(List<Reference> references) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reference = references.elementAt(index);

          return ReferenceRow(
            reference: reference,
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
        },
        childCount: references.length,
      ),
    );
  }

  Future fetch() async {
    setState(() {
      isLoading = true;
      referencesList.clear();
    });

    try {
      final snapshot = await Firestore.instance
          .collection('references')
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final reference = Reference.fromJSON(data);
        referencesList.add(reference);
      });

      setState(() {
        lastDoc = snapshot.documents.last;
        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await Firestore.instance
          .collection('references')
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.documents.forEach((doc) {
        final data = doc.data;
        data['id'] = doc.documentID;

        final reference = Reference.fromJSON(data);
        referencesList.add(reference);
      });

      setState(() {
        isLoadingMore = false;
        hasNext = snapshot.documents.isNotEmpty;
        lastDoc = snapshot.documents.last;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void search() async {
    isSearching = true;
    searchResults.clear();

    try {
      final snapshot = await Firestore.instance
          .collection('references')
          .where('name', isGreaterThanOrEqualTo: searchInputValue)
          .limit(20)
          .getDocuments();

      if (snapshot.documents.isEmpty) {
        return;
      }

      snapshot.documents.forEach((element) {
        final data = element.data;
        data['id'] = element.documentID;

        final reference = Reference.fromJSON(data);
        searchResults.add(reference);
      });

      setState(() {
        isSearching = false;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
