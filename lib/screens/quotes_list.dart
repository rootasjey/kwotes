import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/medium_quote_card.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:provider/provider.dart';

class QuotesListScreen extends StatefulWidget {
  final String id;
  final String name;
  final String description;

  QuotesListScreen({this.description, this.id, this.name});

  @override
  _QuotesListScreenState createState() => _QuotesListScreenState();
}

class _QuotesListScreenState extends State<QuotesListScreen> {
  QuotesList quotesList;

  bool isDeletingList = false;
  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  int limit = 10;
  int order = 1;
  int skip = 0;

  String displayedName = '';
  String displayedDescription = '';

  String oldName = '';
  String oldDescription = '';

  String updateListName = '';
  String updateListDescription = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      displayedName = widget.name;
      displayedDescription = widget.description;
    });

    fetchQuotes(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                showDeleteListDialog();
                return;
              }

              if (value == 'edit') {
                showEditListDialog();
                return;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                )
              ),
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                )
              ),
            ],
          ),
        ],
        title: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                displayedName,
                style: TextStyle(
                  color: accent,
                  fontSize: 30.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  displayedDescription,
                  style: TextStyle(
                    fontSize: 16.0,
                  )
                ),
              ),
            )
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: accent,),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        if (!isLoading && hasErrors) {
          return ErrorComponent(
            description: error != null ? error.toString() : '',
          );
        }

        if (isLoading) {
          return LoadingComponent(
            title: 'Loading the $displayedName list...',
            color: themeColor.background,
            padding: EdgeInsets.all(30.0),
          );
        }

        if (quotesList.quotes.length == 0) {
          return Center(
            child: EmptyView(
              title: 'Empty',
              description: 'You have no quotes in this list yet.',
            ),
          );
        }

        if (isDeletingList == true) {
          return LoadingComponent(
            title: 'Deleting $displayedName list...',
            color: themeColor.background,
            padding: EdgeInsets.all(30.0),
          );
        }

        List<Widget> quotesCards = [];

        for (var i = 0; i < quotesList.quotes.length; i++) {
          final quote = quotesList.quotes.elementAt(i);
          quotesCards.add(
            MediumQuoteCard(
              quote: quote,
              onRemove: () {
                removeFromList(i);
              },
              onRemoveText: 'Remove from $displayedName',
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          children: <Widget>[
            ...quotesCards,
          ],
        );
      }),
    );
  }

  void fetchQuotes(String id) {
    setState(() {
      isLoading = true;
    });

    Queries.listById(context, id)
      .then((quotesListResp) {
        setState(() {
          quotesList = quotesListResp;
          isLoading = false;
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

  void removeFromList(int index) {
    final quote = quotesList.quotes.elementAt(index);

    setState(() { // optimistic
      quotesList.quotes.removeAt(index);
    });

    Mutations.removeFromList(context, widget.id, quote.id)
      .then((booleanMessage) {
        if (!booleanMessage.boolean) {
          setState(() {
            quotesList.quotes.insert(index, quote);
          });

          Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: booleanMessage.message,
          )..show(context);
        }
      })
      .catchError((err) {
        setState(() {
            quotesList.quotes.insert(index, quote);
          });

          Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: err != null ?
              err.toString() :
              'Could not remove the quote. Try again or contact us.',
          )..show(context);
      });
  }

  void showEditListDialog() {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;

    updateListName = quotesList.name;
    updateListDescription = quotesList.description;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Edit ${quotesList.name}',
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: accent),
                hintText: quotesList.name,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                updateListName = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 10.0),),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: accent),
                hintText: updateListDescription,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                updateListDescription = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 20.0),),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    updateListName = '';
                    updateListDescription = '';
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),

                RaisedButton(
                  color: accent,
                  onPressed: () {
                    updateList();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void showDeleteListDialog() {
    final name = quotesList.name;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $name?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    'This action is irreversible.',
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Cancel',
                ),
              ),
            ),
            RaisedButton(
              color: ThemeColor.error,
              onPressed: () {
                deleteList();
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  void deleteList() {
    setState(() {
      isDeletingList = true;
    });

    Mutations.deleteList(context, widget.id)
      .then((booleanMessage) {
        if (booleanMessage.boolean) { // rollback
          Navigator.of(context).pop();
          return;
        }

        Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: booleanMessage.message,
          )..show(context);
      })
      .catchError((err) {
        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          message: err != null ?
            err.toString() :
            'Could not update your list. Try again later or contact us.',
        )..show(context);
      });
  }

  void updateList() {
    setState(() {
      oldName = displayedName;
      oldDescription = displayedDescription;

      displayedName = updateListName;
      displayedDescription = updateListDescription;
    });

    Mutations.updateList(
      context,
      widget.id,
      updateListName,
      updateListDescription
    ).then((resp) {
      if (!resp.boolean) {
        setState(() {
          displayedName = oldName;
          displayedDescription = oldDescription;
        });

        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          message: resp.message,
        )..show(context);
      }
    }).catchError((err) {
      setState(() {
        displayedName = oldName;
        displayedDescription = oldDescription;
      });

      Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.error,
          message: err != null ?
            err.toString() :
            'Could not update your list. Try again later or contact us.',
        )..show(context);
    });
  }
}
