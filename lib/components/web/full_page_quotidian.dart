import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/quotidian.dart';

Quotidian _quotidian;

class FullPageQuotidian extends StatefulWidget {
  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (_quotidian != null) { return; }
    fetchQuotidian();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: <Widget>[
          CircularProgressIndicator(),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 40.0,
            ),
          )
        ],
      );
    }

    if (!isLoading && _quotidian == null) {
      return Column(
        children: <Widget>[
          Text(
            'Sorry, an unexpected error happended :(',
            style: TextStyle(
              fontSize: 35.0,
            ),
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height - 50.0,
          child: Padding(
            padding: EdgeInsets.all(70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _quotidian.quote.name,
                  style: TextStyle(
                    fontSize: 80.0,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Color(0xFF64C7FF),
                      thickness: 2.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Opacity(
                    opacity: .8,
                    child: Text(
                      _quotidian.quote.author.name,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  )
                ),

                if (_quotidian.quote.mainReference?.name != null &&
                  _quotidian.quote.mainReference.name.length > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Opacity(
                      opacity: .6,
                      child: Text(
                        _quotidian.quote.mainReference.name,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () { print('fav'); },
                icon: Icon(Icons.favorite_border),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IconButton(
                  onPressed: () { print('share'); },
                  icon: Icon(Icons.share),
                ),
              ),

              IconButton(
                onPressed: () { print('add list'); },
                icon: Icon(Icons.playlist_add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void fetchQuotidian() async {
    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirestoreApp.instance
        .collection('quotidians').doc('01:02:2020').get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        _quotidian = Quotidian.fromJSON(doc.data());
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
