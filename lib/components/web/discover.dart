import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/discover_card.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';

List<Reference> _references = [];
List<Author> _authors = [];

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  bool isLoading = false;

  @override
  initState() {
    super.initState();

    if (_references.length > 0) { return; }
    fetchAuthorsAndReferences();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      padding: EdgeInsets.symmetric(vertical: 90.0, horizontal: 80.0),
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
            child: Divider(thickness: 2.0,),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Learn knowledge about an author or a reference'
              ),
            ),
          ),

          cardsItems(),
        ],
      )
    );
  }

  Widget cardsItems() {
    List<Widget> cards = [];
    double count = 0;

    for (var author in _authors) {
      count += 1.0;

      cards.add(
        FadeInX(
          beginX: 130.0,
          endX: 0.0,
          delay: count,
          child: DiscoverCard(
            id: author.id,
            imageUrl: author.urls.image,
            name: author.name,
            summary: author.summary,
            type: 'author',
          ),
        )
      );
    }

    for (var reference in _references) {
      count += 1.0;

      cards.add(
        FadeInX(
          beginX: 130.0,
          endX: 0.0,
          delay: count,
          child: DiscoverCard(
            id: reference.id,
            imageUrl: reference.urls.image,
            name: reference.name,
            summary: reference.summary,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: cards,
    );
  }

  void fetchAuthorsAndReferences() async {
    if (!this.mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final refsSnapshot = await Firestore.instance
        .collection('references')
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .getDocuments();

      if (refsSnapshot.documents.isNotEmpty) {
        refsSnapshot.documents.forEach((doc) {
          final data = doc.data;
          data['id'] = doc.documentID;

          final ref = Reference.fromJSON(data);
          _references.add(ref);
        });
      }

      final authorsSnapshot = await Firestore.instance
        .collection('authors')
        .orderBy('updatedAt', descending: true)
        .limit(2)
        .getDocuments();

      if (authorsSnapshot.documents.isNotEmpty) {
        authorsSnapshot.documents.forEach((doc) {
          final data = doc.data;
          data['id'] = doc.documentID;

          final author = Author.fromJSON(data);
          _authors.add(author);
        });
      }

      if (!this.mounted) {
        return;
      }

      setState(() {
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
