import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/error_container.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/types/quote.dart';
import 'package:memorare/types/reference.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String id;

  ReferencePage({this.id});

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  Reference reference;
  List<Quote> quotes = [];
  bool areQuotesLoading = false;
  bool areQuotesLoaded = false;

  bool isLoading = false;
  final double beginY = 100.0;

  TextOverflow nameEllipsis = TextOverflow.ellipsis;

  double avatarInitHeight = 250.0;
  double avatarInitWidth = 200.0;

  double avatarHeight = 250.0;
  double avatarWidth = 200.0;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
            return false;
          }

          return false;
        },
        child: CustomScrollView(
          slivers: <Widget>[
            HomeAppBar(
              title: reference != null
                ? reference.name
                : '',
              automaticallyImplyLeading: true,
            ),

            bodyContent(),
          ],
        ),
      ),
    );
  }

  Widget avatar({double scale = 1.0}) {
    final imageUrl = reference.urls.image;
    final imageUrlOk = imageUrl != null && imageUrl.length > 0;

    return AnimatedContainer(
      width: avatarWidth * scale,
      height: avatarHeight * scale,
      duration: 250.milliseconds,
      child: Card(
        elevation: imageUrlOk ? 5.0 : 0.0,
        child: imageUrlOk
          ? Ink.image(
              image: NetworkImage(
                reference.urls.image,
              ),
              fit: BoxFit.cover,
              child: InkWell(
                onHover: (isHover) {
                  if (isHover) {
                    setState(() {
                      avatarHeight = (avatarInitHeight) + 10.0;
                      avatarWidth = (avatarInitWidth) + 10.0;
                    });

                    return;
                  }

                  setState(() {
                    avatarHeight = avatarInitHeight;
                    avatarWidth = avatarInitWidth;
                  });

                  return;
                },
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Image(
                            image: NetworkImage(reference.urls.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    });
                },
              ),
            )
          : Center(
              child: Text(
                reference.name.substring(0, 2).toUpperCase(),
                style: TextStyle(
                  fontSize: 50.0,
                ),
              ),
            ),
      ),
    );
  }

  Widget backButton() {
    return Positioned(
        left: 40.0,
        top: 0.0,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
        ));
  }

  Widget bodyContent() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: LoadingAnimation(
              textTitle: 'Loading reference...',
            ),
          ),
        ]),
      );
    }

    if (reference == null) {
      return SliverList(
        delegate: SliverChildListDelegate([
          ErrorContainer(
            message: 'Oops! There was an error while loading the reference',
            onRefresh: () => fetch(),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        LayoutBuilder(
          builder: (context, constrains) {
            return constrains.maxWidth < 700
              ? smallView()
              : largeView();
          },
        ),
      ]),
    );
  }

  Widget largeView() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 120.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeInY(
                  beginY: beginY,
                  delay: 1.0,
                  child: avatar(scale: 1.5),
                ),

                ControlledAnimation(
                  delay: 1.seconds,
                  duration: 1.seconds,
                  tween: Tween(begin: 0.0, end: 100.0),
                  builder: (_, value) {
                    return SizedBox(
                      width: value,
                      child: Divider(
                        thickness: 1.0,
                        height: 50.0,
                      ),
                    );
                  },
                ),

                FadeInY(
                  beginY: beginY,
                  delay: 3.0,
                  child: types(),
                ),

                FadeInY(
                  beginY: beginY,
                  delay: 3.2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: RaisedButton.icon(
                      onPressed: () {
                        FluroRouter.router.navigateTo(
                          context,
                          ReferenceQuotesRoute.replaceFirst(':id', widget.id)
                        );
                      },
                      color: stateColors.primary,
                      textColor: Colors.white,
                      icon: Icon(Icons.chat_bubble_outline),
                      label: Text('Related quotes'),
                    ),
                  ),
                ),

                Padding(padding: const EdgeInsets.only(top: 40.0)),

                links(),
              ],
            ),
          ),

          Expanded(
            child: summaryLarge(),
          ),
        ],
      ),
    );
  }

  Widget heroSmall() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            delay: 1.0,
            child: avatar(),
          ),

          FadeInY(
            beginY: beginY,
            delay: 2.0,
            child: name(),
          ),

          ControlledAnimation(
            delay: 1.seconds,
            duration: 1.seconds,
            tween: Tween(begin: 0.0, end: 100.0),
            builder: (_, value) {
              return SizedBox(
                width: value,
                child: Divider(
                  thickness: 1.0,
                  height: 50.0,
                ),
              );
            },
          ),

          FadeInY(
            beginY: beginY,
            delay: 3.0,
            child: types(),
          ),

          FadeInY(
            beginY: beginY,
            delay: 3.4,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: RaisedButton.icon(
                onPressed: () {
                  FluroRouter.router.navigateTo(
                    context,
                    ReferenceQuotesRoute.replaceFirst(':id', widget.id)
                  );
                },
                color: stateColors.primary,
                textColor: Colors.white,
                icon: Icon(Icons.chat_bubble_outline),
                label: Text('Related quotes'),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 45.0,
            ),
            child: links(),
          ),
        ],
      ),
    );
  }

  Widget links() {
    final urls = reference.urls;

    if (urls.areLinksEmpty()) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: <Widget>[
        if (urls.website.isNotEmpty)
          linkSquareButton(
            delay: 1.0,
            name: 'Website',
            url: urls.website,
            imageUrl: 'assets/images/world-globe.png',
          ),

        if (urls.wikipedia.isNotEmpty)
          Observer(
            builder: (_) {
              return linkSquareButton(
                delay: 1.2,
                name: 'Wikipedia',
                url: urls.wikipedia,
                imageUrl:
                  'assets/images/wikipedia-${stateColors.iconExt}.png',
              );
            },
          ),

        if (urls.amazon.isNotEmpty)
          linkSquareButton(
            delay: 1.2,
            name: 'Amazon',
            url: urls.amazon,
            imageUrl: 'assets/images/amazon.png',
          ),

        if (urls.facebook.isNotEmpty)
          linkSquareButton(
            delay: 1.4,
            name: 'Facebook',
            url: urls.facebook,
            imageUrl: 'assets/images/facebook.png',
          ),

        if (urls.netflix.isNotEmpty)
          linkSquareButton(
            delay: 1.6,
            name: 'Netflix',
            url: urls.netflix,
            imageUrl: 'assets/images/netflix.png',
          ),

        if (urls.primeVideo.isNotEmpty)
          linkSquareButton(
            delay: 1.8,
            name: 'Prime Video',
            url: urls.primeVideo,
            imageUrl: 'assets/images/prime-video.png',
          ),

        if (urls.twitch.isNotEmpty)
          linkSquareButton(
            delay: 2.0,
            name: 'Twitch',
            url: urls.twitch,
            imageUrl: 'assets/images/twitch.png',
          ),

        if (urls.twitter.isNotEmpty)
          linkSquareButton(
            delay: 2.2,
            name: 'Twitter',
            url: urls.twitter,
            imageUrl: 'assets/images/twitter.png',
          ),

        if (urls.youtube.isNotEmpty)
          linkSquareButton(
            delay: 2.4,
            name: 'Youtube',
            url: urls.youtube,
            imageUrl: 'assets/images/youtube.png',
          ),
      ],
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: FlatButton(
        onPressed: () {
          setState(() {
            nameEllipsis = nameEllipsis == TextOverflow.ellipsis
                ? TextOverflow.visible
                : TextOverflow.ellipsis;
          });
        },
        child: Text(
          reference.name,
          textAlign: TextAlign.center,
          overflow: nameEllipsis,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget linkSquareButton({
    double delay = 0.0,
    String name,
    String url,
    String imageUrl,
  }) {

    return FadeInX(
      beginX: 50.0,
      delay: delay,
      child: Tooltip(
        message: name,
        child: SizedBox(
          height: 80.0,
          width: 80.0,
          child: Card(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => launch(url),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  imageUrl,
                  width: 30.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget smallView() {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsets.only(bottom: 200.0),
      child: Column(
        children: <Widget>[
          heroSmall(),

          FadeInY(
            beginY: beginY,
            delay: 4.0,
            child: summarySmall(),
          ),
        ],
      ),
    );
  }

  Widget summarySmall() {
    return Column(
      children: <Widget>[
        Divider(
          thickness: 1.0,
        ),

        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Opacity(
            opacity: .6,
            child: Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        ),

        SizedBox(
          width: 100.0,
          child: Divider(
            thickness: 1.0,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 70.0,
          ),
          width: 600.0,
          child: Text(
            reference.summary,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w100,
              height: 1.5,
            ),
          ),
        ),

        if (reference.urls.wikipedia?.isNotEmpty)
          OutlineButton(
            onPressed: () => launch(reference.urls.wikipedia),
            child: Text('More on Wikipedia'),
          ),
      ],
    );
  }

  Widget summaryLarge() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),

          SizedBox(
            width: 100.0,
            child: Divider(
              thickness: 1.0,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 60.0,
            ),
            width: 600.0,
            child: Opacity(
              opacity: 0.7,
              child: Text(
                reference.summary,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w100,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (reference.urls.wikipedia?.isNotEmpty)
            OutlineButton(
              onPressed: () => launch(reference.urls.wikipedia),
              child: Text('More on Wikipedia'),
            )
        ],
      ),
    );
  }

  Widget types() {
    final type = reference.type;

    return Column(
      children: <Widget>[
        Opacity(
          opacity: .7,
          child: Text(
            type.primary,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        if (type.secondary != null && type.secondary.length > 0)
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                type.secondary,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await Firestore.instance
        .collection('references')
        .document(widget.id)
        .get();

      if (!docSnap.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = docSnap.data;
      data['id'] = docSnap.documentID;

      setState(() {
        reference = Reference.fromJSON(data);

        nameEllipsis = reference.name.length > 42
          ? TextOverflow.ellipsis
          : TextOverflow.visible;

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
