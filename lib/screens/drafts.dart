import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/add_quote.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/pagination.dart';
import 'package:memorare/types/temp_quote.dart';
import 'package:provider/provider.dart';

class Drafts extends StatefulWidget {
  @override
  _DraftsState createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  List<TempQuote> draftsList = [];
  bool isLoading = false;
  bool isLoadingTempQuote = false;
  bool hasErrors = false;
  Error error;

  int order = -1;

  Pagination pagination = Pagination();
  bool isLoadingMoreLists = false;
  ScrollController listScrollController = ScrollController();

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    fetchDrafts();
  }


  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;
    final backgroundColor = themeColor.background;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: InkWell(
          onTap: () {
            listScrollController.animateTo(
              0,
              duration: Duration(seconds: 2),
              curve: Curves.easeOutQuint,
            );
          },
          child: Text(
            'Drafts',
            style: TextStyle(
              color: accent,
              fontSize: 30.0,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                deleteAllDrafts();
                return;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete all'),
                )
              ),
            ],
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        if (!isLoading && hasErrors) {
          return ErrorComponent(
            description: error != null ? error.toString() : '',
          );
        }

        if (isLoading) {
          return LoadingComponent(
            title: 'Loading your drafts...',
            color: themeColor.background,
            padding: EdgeInsets.all(30.0),
          );
        }

        if (isLoadingTempQuote) {
          return Scaffold(
            body: LoadingComponent(
              title: 'Loading quote...',
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              color: backgroundColor,
              backgroundColor: Colors.transparent,
            ),
          );
        }

        if (draftsList.length == 0) {
          return EmptyView(
            icon: Icon(Icons.edit, size: 60.0),
            title: 'No drafts',
            description: 'You can save them when you are not ready to propose your quotes.',
            onRefresh: () async {
              await fetchDrafts();
              return null;
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await fetchDrafts();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotif) {
              if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
                  return false;
              }

              if (pagination.hasNext && !isLoadingMoreLists) {
                fetchMoreDrafts();
              }

              return false;
            },
            child: ListView.separated(
              controller: listScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
              itemCount: draftsList.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final item = draftsList.elementAt(index);

                return ListTile(
                  onTap: () {
                    editDraft(item);
                  },
                  trailing: moreButton(tempQuote: item, index: index),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  )
                );
              },
            )
          ),
        );
      }),
    );
  }

  Widget moreButton({int index, TempQuote tempQuote}) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'delete') {
          deleteDraft(index, tempQuote);
          return;
        }

        if (value == 'edit') {
          editDraft(tempQuote);
          return;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              'Edit',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future fetchDrafts() {
    setState(() {
      isLoading = true;
    });

    return Queries.drafts(
      context: context,
      limit: pagination.limit,
      order: order,
      skip: pagination.skip,

    ).then((draftsResp) {
      setState(() {
        isLoading = false;
        hasErrors = false;
        draftsList = draftsResp.entries;
        pagination = draftsResp.pagination;
      });
    })
    .catchError((err) {
      setState(() {
        error = err;
        isLoading = false;
        hasErrors = true;
      });
    });
  }

  Future fetchMoreDrafts() {
    isLoadingMoreLists = true;

    return Queries.drafts(
      context: context,
      limit: pagination.limit,
      order: order,
      skip: pagination.nextSkip,

    ).then((draftsResp) {
      setState(() {
        draftsList.addAll(draftsResp.entries);
        pagination = draftsResp.pagination;
        isLoadingMoreLists = false;
      });
    })
    .catchError((err) {
      setState(() {
        isLoadingMoreLists = false;
      });
    });
  }

  Future deleteDraft(int index, TempQuote draft) {
    setState(() {
      draftsList
        .removeWhere((draftItem) => draftItem.id == draft.id);
    });

    return Mutations.deleteDraft(context: context, id: draft.id)
      .then((booleanMessage) {})
      .catchError((err) {
        setState(() {
          draftsList.insert(index, draft);
        });

        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          messageText: Text(
            'Could not delete the draft (${err.toString()}).',
            style: TextStyle(color: Colors.white),
          ),
        )..show(context);
      });
  }

  Future deleteAllDrafts() {
    setState(() {
      draftsList = [];
    });

    return Mutations.deleteAllDrafts(context: context)
      .then((booleanMessage) {
        if (!booleanMessage.boolean) {
          fetchDrafts();

          Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            messageText: Text(
              'Could not delete all your draft (${booleanMessage.message}).',
              style: TextStyle(color: Colors.white),
            ),
          )..show(context);
        }
      })
      .catchError((err) {
        fetchDrafts();

        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          messageText: Text(
            'Could not delete all your draft (${err.toString()}).',
            style: TextStyle(color: Colors.white),
          ),
        )..show(context);
      });
  }

  Future editDraft(TempQuote draft) {
    setState(() {
      isLoadingTempQuote = true;
    });

    return Queries
      .draft(context: context, id: draft.id)
      .then((tempQuote) {
        isLoadingTempQuote = false;

        AddQuoteInputs.comment  = tempQuote.comment;
        AddQuoteInputs.id       = tempQuote.id;
        AddQuoteInputs.name     = tempQuote.name;
        AddQuoteInputs.lang     = tempQuote.lang;
        AddQuoteInputs.topics   = tempQuote.topics;

        if (tempQuote.author != null) {
          AddQuoteInputs.authorImgUrl   = tempQuote.author.imgUrl;
          AddQuoteInputs.authorJob      = tempQuote.author.job;
          AddQuoteInputs.authorName     = tempQuote.author.name;
          AddQuoteInputs.authorSummary  = tempQuote.author.summary;
          AddQuoteInputs.authorUrl      = tempQuote.author.url;
          AddQuoteInputs.authorWikiUrl  = tempQuote.author.wikiUrl;
        }

        if (tempQuote.references != null && tempQuote.references.length > 0) {
          final ref = tempQuote.references.first;
          AddQuoteInputs.refImgUrl  = ref.imgUrl;
          AddQuoteInputs.refLang    = ref.lang;
          AddQuoteInputs.refName    = ref.name;
          AddQuoteInputs.refSubType = ref.subType;
          AddQuoteInputs.refSummary = ref.summary;
          AddQuoteInputs.refType    = ref.type;
          AddQuoteInputs.refUrl     = ref.url;
          AddQuoteInputs.refWikiUrl = ref.wikiUrl;
        }

        AddQuoteInputs.isCompleted    = false;
        AddQuoteInputs.isSending      = false;
        AddQuoteInputs.hasExceptions  = false;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return AddQuote();
            }
          )
        );
      })
      .catchError((err) {
        setState(() {
          isLoadingTempQuote = false;
        });

        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          messageText: Text(
            'Sorry, there was an issue loading your draft (${err.toString()}).',
            style: TextStyle(color: Colors.white),
          ),
        )..show(context);
    });
  }
}
