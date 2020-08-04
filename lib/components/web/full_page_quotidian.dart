import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/favourites.dart';
import 'package:memorare/actions/share.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/colored_list_tile.dart';
import 'package:memorare/components/web/add_to_list_button.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/quotidian.dart';
import 'package:memorare/utils/animation.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

String _prevLang;

class FullPageQuotidian extends StatefulWidget {
  final bool noAuth;

  FullPageQuotidian({this.noAuth = false,});

  @override
  _FullPageQuotidianState createState() => _FullPageQuotidianState();
}

class _FullPageQuotidianState extends State<FullPageQuotidian> {
  bool isPrevFav = false;
  bool hasFetchedFav = false;
  bool isLoading = false;
  bool isMenuOn = false;

  Quotidian quotidian;

  ReactionDisposer disposeFav;
  ReactionDisposer disposeLang;

  TextDecoration dashboardLinkDecoration = TextDecoration.none;

  @override
  void initState() {
    super.initState();

    disposeLang = autorun((_) {
      if (quotidian != null && _prevLang == userState.lang) {
        return;
      }

      _prevLang = userState.lang;
      fetch();
    });

    disposeFav = autorun((_) {
      final updatedAt = userState.updatedFavAt;
      fetchIsFav(updatedAt: updatedAt);
    });
  }

  @override
  void dispose() {
    if (disposeLang != null) {
      disposeLang();
    }

    if (disposeFav != null) {
      disposeFav();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && quotidian == null) {
      return FullPageLoading(
        title: 'Loading quotidian...',
      );
    }

    if (quotidian == null) {
      return emptyContainer();
    }

    return OrientationBuilder(
      builder: (context, orientation) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 100.0,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  left: 60.0,
                  child: quoteActions(),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 70.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      quoteName(
                        screenWidth: MediaQuery.of(context).size.width,
                      ),

                      animatedDivider(),

                      authorName(),

                      if (quotidian.quote.mainReference?.name != null &&
                        quotidian.quote.mainReference.name.length > 0)
                        referenceName(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!widget.noAuth)
            userSection(),
          ],
        );
      },
    );
  }

  Widget animatedDivider() {
    final topicColor = appTopicsColors.find(quotidian.quote.topics.first);
    final color = topicColor != null ?
      Color(topicColor.decimal) :
      Colors.white;

    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 200.0),
      child: Divider(
          color: color,
          thickness: 2.0,
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: SizedBox(
            width: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget authorName() {
    return ControlledAnimation(
      delay: 1.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.8),
      builder: (context, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                final id = quotidian.quote.author.id;

                FluroRouter.router.navigateTo(
                  context,
                  AuthorRoute.replaceFirst(':id', id)
                );
              },
              child: Text(
                quotidian.quote.author.name,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            )
          )
        );
      },
    );
  }

  Widget emptyContainer() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.warning, size: 40.0,),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Sorry, an unexpected error happended :(',
              style: TextStyle(
                fontSize: 35.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteActions() {
    return Observer(
      builder: (context) {
        if (!userState.isUserConnected) {
          return Padding(padding: EdgeInsets.zero,);
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height - 200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  if (isPrevFav) {
                    removeQuotidianFromFav();
                    return;
                  }

                  addQuotidianToFav();
                },
                icon: isPrevFav ?
                  Icon(Icons.favorite) :
                  Icon(Icons.favorite_border),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: IconButton(
                  onPressed: () async {
                    shareTwitter(quote: quotidian.quote);
                  },
                  icon: Icon(Icons.share),
                ),
              ),

              AddToListButton(quote: quotidian.quote,),
            ],
          ),
        );
    });
  }

  Widget quoteName({double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.only(left: 60.0),
      child: GestureDetector(
        onTap: () {
          FluroRouter.router.navigateTo(
            context,
            QuotePageRoute.replaceFirst(':id', quotidian.quote.id),
          );
        },
        child: createHeroQuoteAnimation(
          quote: quotidian.quote,
          screenWidth: screenWidth,
        ),
      ),
    );
  }

  Widget referenceName() {
    return ControlledAnimation(
      delay: 2.seconds,
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 0.6),
      child: GestureDetector(
        onTap: () {
          final id = quotidian.quote.mainReference.id;

          FluroRouter.router.navigateTo(
            context,
            ReferenceRoute.replaceFirst(':id', id)
          );
        },
        child: Text(
          quotidian.quote.mainReference.name,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
      builderWithChild: (context, child, value) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Opacity(
            opacity: value,
            child: child,
          )
        );
      },
    );
  }

  Widget signinButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                SigninRoute,
              );
            },
            color: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
            child: Container(
              width: 200.0,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userSection() {
    return Observer(builder: (context) {
      if (userState.isUserConnected) {
        if (!hasFetchedFav) { fetchIsFav(); }

        hasFetchedFav = true;

        return dashboardQuickLinks();
      }

      hasFetchedFav = false;
      return signinButton();
    });
  }

  Widget dashboardQuickLinks() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Text(
              'QUICK LINKS',
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
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Opacity(
              opacity: .6,
              child: InkWell(
                onTap: () => FluroRouter.router.navigateTo(
                  context,
                  DashboardRoute,
                ),
                onHover: (isHover) {
                  setState(() {
                    dashboardLinkDecoration = isHover
                      ? TextDecoration.underline
                      : TextDecoration.none;
                  });
                },
                child: Text(
                  'Shortcuts to your dashboard',
                  style: TextStyle(
                    decoration: dashboardLinkDecoration,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz),
              tooltip: 'More quick links',
              onSelected: (value) {
                if (value == 'signout') {
                  userSignOut(context: context);
                  return;
                }

                FluroRouter.router.navigateTo(
                  context,
                  value,
                );
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem(
                  value: DraftsRoute,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text(
                      'Drafts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: PublishedQuotesRoute,
                  child: ListTile(
                    leading: Icon(Icons.cloud_done),
                    title: Text(
                      'Published',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: TempQuotesRoute,
                  child: ListTile(
                    leading: Icon(Icons.timelapse),
                    title: Text(
                      'In Validation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),

                const PopupMenuItem(
                  value: AccountRoute,
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: 'signout',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text(
                      'Sign out',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: 'dashboard',
                  child: ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),
              ],
            ),
          ),

          Wrap(
            spacing: 30.0,
            runSpacing: 30.0,
            children: <Widget>[
              ColoredListTile(
                icon: Icons.favorite,
                title: Text('Favourites'),
                hoverColor: Colors.red,
                onTap: () => FluroRouter.router.navigateTo(
                  context,
                  FavouritesRoute,
                ),
              ),

              ColoredListTile(
                icon: Icons.list,
                title: Text('Lists'),
                hoverColor: Colors.blue.shade700,
                onTap: () => FluroRouter.router.navigateTo(
                  context,
                  ListsRoute,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addQuotidianToFav() async {
    setState(() { // Optimistic result
      isPrevFav = true;
    });

    final result = await addToFavourites(
      context: context,
      quotidian: quotidian,
    );

    if (!result) {
      setState(() {
        isPrevFav = false;
      });
    }
  }

  void fetchIsFav({DateTime updatedAt}) async {
    final isCurrentFav = await isFavourite(
      quoteId: quotidian.quote.id,
    );

    if (isPrevFav != isCurrentFav) {
      isPrevFav = isCurrentFav;
      setState(() {});
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();

    String month = now.month.toString();
    month = month.length == 2 ? month : '0$month';

    String day = now.day.toString();
    day = day.length == 2 ? day : '0$day';

    try {
      final doc = await Firestore.instance
        .collection('quotidians')
        .document('${now.year}:$month:$day:$_prevLang')
        .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        quotidian = Quotidian.fromJSON(doc.data);
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

  void removeQuotidianFromFav() async {
    setState(() { // Optimistic result
      isPrevFav = false;
    });

    final result = await removeFromFavourites(
      context: context,
      quotidian: quotidian,
    );

    if (!result) {
      setState(() {
        isPrevFav = true;
      });
    }
  }
}
