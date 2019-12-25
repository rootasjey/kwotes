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
        title: Text(
          displayedName,
          style: TextStyle(
            color: accent,
            fontSize: 30.0,
          ),
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

        List<Widget> quotesCards = [];

        for (var quote in quotesList.quotes) {
          quotesCards.add(
            MediumQuoteCard(
              quote: quote,
              onRemove: () {
                print('remove');
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

  void showEditListDialog({QuotesList quotesList, int index}) {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;

    final name = quotesList.name;
    final description = quotesList.description;

    updateListName = name;
    updateListDescription = description;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Edit $name',
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: accent),
                hintText: name,
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
                hintText: description,
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
                    updateList(quotesList: quotesList, index: index);
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

  void updateList({QuotesList quotesList, int index}) {
    final name = updateListName;
    final description = updateListDescription;


    setState(() {
      oldName = displayedName;
      oldDescription = displayedDescription;

      displayedName = updateListName;
      displayedDescription = updateListDescription;
    });

    UserMutations.updateList(context, widget.id, name, description)
      .then((resp) {
        if (!resp.boolean) {
          setState(() {
            displayedName = oldName;
            displayedDescription = oldDescription;
          });

          Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: 'Could not update your list. Try again later or contact us.',
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
            message: 'Could not update your list. Try again later or contact us.',
          )..show(context);
      });
  }
}
