import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/circle_author.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/screens/authors.dart';
import 'package:figstyle/types/author.dart';

List<Author> _authorsList = [];

class DiscoverAuthors extends StatefulWidget {
  @override
  _DiscoverAuthorsState createState() => _DiscoverAuthorsState();
}

class _DiscoverAuthorsState extends State<DiscoverAuthors> {
  bool isLoading = false;

  @override
  initState() {
    super.initState();

    if (_authorsList.length > 0) {
      return;
    }

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
          vertical: 90.0,
          horizontal: 80.0,
        ),
        foregroundDecoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.05),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                'DISCOVER',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(
              width: 50.0,
              child: Divider(
                thickness: 2.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Opacity(
                opacity: .6,
                child: Text('Do you know these authors?'),
              ),
            ),
            cardsItems(),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: allAuthorsButton(),
            ),
          ],
        ));
  }

  Widget allAuthorsButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Authors(),
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
        primary: Colors.black12,
      ),
      icon: Opacity(opacity: 0.6, child: Icon(Icons.list)),
      label: Opacity(
        opacity: .6,
        child: Text('All authors'),
      ),
    );
  }

  Widget cardsItems() {
    List<Widget> cards = [];
    int count = 0;

    for (var author in _authorsList) {
      count += 100;

      cards.add(
        FadeInX(
          beginX: 130.0,
          endX: 0.0,
          delay: Duration(milliseconds: count),
          child: CircleAuthor(
            author: author,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 80.0,
      runSpacing: 80.0,
      children: cards,
    );
  }

  void fetch() async {
    if (!this.mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('authors')
          .orderBy('updatedAt', descending: true)
          .limit(3)
          .get();

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          final author = Author.fromJSON(data);
          _authorsList.add(author);
        });
      }

      if (!this.mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
