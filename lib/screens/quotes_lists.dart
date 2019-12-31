import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/screens/quotes_list.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:provider/provider.dart';

class QuotesLists extends StatefulWidget {
  @override
  _QuotesListsState createState() => _QuotesListsState();
}

class _QuotesListsState extends State<QuotesLists> {
  List<QuotesList> lists = [];
  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  int limit = 10;
  int order = 1;
  int skip = 0;

  String newListName = '';
  String newListDescription = '';

  String updateListName = '';
  String updateListDescription = '';

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    fetchLists();
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
          'Lists',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateListDialog();
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: accent,
      ),
      body: Builder(builder: (BuildContext context) {
        if (!isLoading && hasErrors) {
          return ErrorComponent(
            description: error != null ? error.toString() : '',
          );
        }

        if (isLoading) {
          return LoadingComponent(
            title: 'Loading your lists...',
            color: themeColor.background,
            padding: EdgeInsets.all(30.0),
          );
        }

        if (lists.length == 0) {
          return EmptyView(
            icon: Icon(Icons.list, size: 60.0),
            title: 'No personalized lists',
            description: 'You have no list yet. You can create a thematic one.',
            onRefresh: () async {
              await fetchLists();
              return null;
            },
            onTapDescription: () {
              showCreateListDialog();
            },
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
          itemCount: lists.length,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            final item = lists.elementAt(index);

            return ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return QuotesListScreen(
                        id: item.id,
                        name: item.name,
                        description: item.description,
                      );
                    }
                  )
                );
              },
              trailing: moreButton(quotesList: item, index: index),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  if (item.description != null)
                    Opacity(
                      opacity: .6,
                      child: Text(
                        item.description,
                      ),
                    ),
                ],
              )
            );
          },
        );
      }),
    );
  }

  Widget moreButton({int index, QuotesList quotesList}) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'delete') {
          showDeleteListDialog(quotesList: quotesList, index: index);
          return;
        }

        if (value == 'edit') {
          showEditListDialog(index: index, quotesList: quotesList);
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

  Future fetchLists() {
    setState(() {
      isLoading = true;
    });

    return Queries.lists(context, limit, order, skip)
      .then((quotesListsResp) {
        setState(() {
          isLoading = false;
          hasErrors = false;
          lists = quotesListsResp.entries;
        });
      })
      .catchError((err) {
        error = err;
        isLoading = false;
        hasErrors = true;
      });
  }

  void showCreateListDialog() {
    final themeColor = Provider.of<ThemeColor>(context);
    final accent = themeColor.accent;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Create a new list'
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListName = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 10.0),),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListDescription = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 20.0),),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),

                RaisedButton(
                  color: accent,
                  onPressed: () {
                    createNewList();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Create',
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

  void showDeleteListDialog({QuotesList quotesList, int index}) {
    final id = quotesList.id;
    final name = quotesList.name;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $name list?'),
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
                deleteList(id: id, index: index);
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

  void createNewList() {
    Mutations.createList(
      context: context,
      name: newListName,
      description: newListDescription

    ).then((quotesListResp) {
      setState(() {
        lists.add(quotesListResp);
      });
    })
    .catchError((err) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: 'Could not create your new list. Try again later or contact us.',
      )..show(context);
    });
  }

  void deleteList({String id, int index}) {
    final itemToDelete = lists.elementAt(index);

    setState(() {
      lists.removeAt(index);
    });

    Mutations.deleteList(context, id)
      .then((booleanMessage) {
        if (booleanMessage.boolean) { // rollback
          return;
        }

        setState(() {
          lists.insert(index, itemToDelete);
        });
      })
      .catchError((err) {
        setState(() {
          lists.insert(index, itemToDelete);
        });
      });
  }

  void updateList({QuotesList quotesList, int index}) {
    final listToUpdate = lists.elementAt(index);

    final id = listToUpdate.id;
    final name = updateListName;
    final description = updateListDescription;

    final oldName = listToUpdate.name;
    final oldDescription = listToUpdate.description;

    setState(() {
      listToUpdate.name = updateListName;
      listToUpdate.description = updateListDescription;
    });

    Mutations.updateList(context, id, name, description)
      .then((resp) {
        if (!resp.boolean) {
          setState(() {
            listToUpdate.name = oldName;
            listToUpdate.description = oldDescription;
          });

          Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: 'Could not update your list. Try again later or contact us.',
          )..show(context);
        }
      }).catchError((err) {
        setState(() {
          listToUpdate.name = oldName;
          listToUpdate.description = oldDescription;
        });

        Flushbar(
            duration: Duration(seconds: 3),
            backgroundColor: ThemeColor.error,
            message: 'Could not update your list. Try again later or contact us.',
          )..show(context);
      });
  }
}
