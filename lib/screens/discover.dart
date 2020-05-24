import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';

List<Reference> _references = [];
List<Author> _authors = [];

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String lang = 'en';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (_authors.length > 0 || _references.length > 0) {
      return;
    }

    fetchAuthorsAndReferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (isLoading) {
            return LoadingAnimation(
              textTitle: 'Loading Discover section...',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await fetchAuthorsAndReferences();
              return null;
            },
            child: ListView(
              padding: EdgeInsets.only(
                top: 50.0,
                bottom: 200.0,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Discover',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      'Uncover new authors and references.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  )
                ),

                Divider(height: 60.0,),

                Wrap(
                  alignment: WrapAlignment.center,
                  children: cardsList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> cardsList() {
    List<Widget> cards = [];
    double index = 0;

    for (var reference in _references) {
      cards.add(
        FadeInY(
          delay: index,
          beginY: 100.0,
          child: discoverCard(
            title: reference.name,
            imgUrl: reference.urls.image,
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                ReferenceRoute.replaceFirst(':id', reference.id),
              );
            }
          ),
          // child: DiscoverCard(
          //   id: reference.id,
          //   elevation: 5.0,
          //   imageUrl: reference.urls.image,
          //   type: 'reference',
          //   name: reference.name,
          //   summary: reference.summary,
          //   width: 170.0,
          //   height: 270.0,
          // ),
        )
      );

      index += 1.0;
    }

    for (var author in _authors) {
      cards.add(
        FadeInY(
          delay: index,
          beginY: 100.0,
          child: discoverCard(
            title: author.name,
            imgUrl: author.urls.image,
            onTap: () {
              FluroRouter.router.navigateTo(
                context,
                AuthorRoute.replaceFirst(':id', author.id),
              );
            }
          ),
          // child: DiscoverCard(
          //   id: author.id,
          //   elevation: 5.0,
          //   imageUrl: author.urls.image,
          //   type: 'author',
          //   name: author.name,
          //   summary: author.summary,
          //   width: 170.0,
          //   height: 270.0,
          // ),
        )
      );

      index += 1.0;
    }

    return cards;
  }

  Widget discoverCard({
    String title,
    String imgUrl,
    Function onTap,
    String type = 'author',
  }) {
    final isImageOk = imgUrl != null &&
      imgUrl.length > 0;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 170,
        height: 220,
        child: Card(
          elevation: 5.0,
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap();
              }
            },
            child: Stack(
              children: <Widget>[
                isImageOk ?
                  Opacity(
                    opacity: .3,
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      width: 170,
                      height: 220,
                    ),
                  ) :
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80.0,
                    ),
                    child: Observer(
                      builder: (context) {
                        return Image.asset(
                          type == 'reference' ?
                          'assets/images/textbook-${stateColors.iconExt}.png' :
                          'assets/images/profile-${stateColors.iconExt}.png',
                        );
                      }
                    )
                  ),

                Positioned.fill(
                  child: Container(
                    color: Color.fromRGBO(0, 0, 0, .5),
                  ),
                ),

                Positioned(
                  bottom: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      title.length > 65 ?
                      '${title.substring(0, 64)}...' :
                      title,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      )
    );
  }

  Future fetchAuthorsAndReferences() async {
    _authors.clear();
    _references.clear();

    setState(() {
      isLoading = true;
    });

    try {
      final refsSnapshot = await Firestore.instance
        .collection('references')
        .orderBy('updatedAt', descending: true)
        .limit(2)
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
        .limit(4)
        .getDocuments();

      final snapDocs = authorsSnapshot.documents.sublist(0);

      if (snapDocs.isNotEmpty) {
        snapDocs
          .removeWhere((element) {
            return _references.any((ref) {
              return ref.name == element.data['name'];
            });
          });

        snapDocs.take(2).forEach((doc) {
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
