import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fig_style/actions/references.dart';
import 'package:fig_style/actions/share.dart';
import 'package:fig_style/components/data_quote_inputs.dart';
import 'package:fig_style/components/lang_popup_menu_button.dart';
import 'package:fig_style/components/page_app_bar.dart';
import 'package:fig_style/components/reference_avatar.dart';
import 'package:fig_style/components/square_action.dart';
import 'package:fig_style/router/app_router.gr.dart';
import 'package:fig_style/utils/app_logger.dart';
import 'package:fig_style/utils/constants.dart';
import 'package:fig_style/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fig_style/components/error_container.dart';
import 'package:fig_style/components/loading_animation.dart';
import 'package:fig_style/components/quote_row_with_actions.dart';
import 'package:fig_style/components/sliver_empty_view.dart';
import 'package:fig_style/components/fade_in_x.dart';
import 'package:fig_style/components/fade_in_y.dart';
import 'package:fig_style/components/desktop_app_bar.dart';
import 'package:fig_style/state/colors.dart';
import 'package:fig_style/state/user.dart';
import 'package:fig_style/types/quote.dart';
import 'package:fig_style/types/reference.dart';
import 'package:fig_style/utils/app_storage.dart';
import 'package:fig_style/utils/language.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatefulWidget {
  final String referenceId;
  final String referenceName;
  final String referenceImageUrl;

  ReferencePage({
    @required @PathParam('referenceId') this.referenceId,
    this.referenceName,
    this.referenceImageUrl,
  });

  @override
  ReferencePageState createState() => ReferencePageState();
}

class ReferencePageState extends State<ReferencePage> {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool descending = true;
  bool hasNext = true;
  bool isSummaryVisible = false;

  DocumentSnapshot lastFetchedDoc;

  final limit = 30;
  final double beginY = 20.0;
  final pageRoute = 'reference_page';
  final _pageScrollController = ScrollController();

  List<Quote> quotes = [];

  Reference reference;
  TextOverflow nameEllipsis = TextOverflow.ellipsis;

  String lang = 'en';

  @override
  void initState() {
    super.initState();
    initProps();
    fetch();
    fetchQuotes();
  }

  void initProps() {
    lang = appStorage.getPageLang(pageRoute: pageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          if (scrollNotif.metrics.pixels <
              scrollNotif.metrics.maxScrollExtent) {
            return false;
          }

          return false;
        },
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: <Widget>[
            appBar(),
            heroSection(),
            textsPanels(),
            userActions(),
            langDropdown(),
            quotesListView(),
            SliverPadding(
              padding: const EdgeInsets.only(
                bottom: 200.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return PageAppBar(
        expandedHeight: 70.0,
      );
    }

    return DesktopAppBar();
  }

  /// Reference's picture profile (avatar) and name.
  Widget heroSection() {
    String referenceName = widget.referenceName;
    String referenceImageUrl = widget.referenceImageUrl;

    if (referenceName == null || referenceName.isEmpty) {
      referenceName = reference?.name;
    }

    if (referenceImageUrl == null || referenceImageUrl.isEmpty) {
      referenceImageUrl = reference?.urls?.image;
    }

    referenceImageUrl = referenceImageUrl ?? '';
    referenceName = referenceName ?? '';

    final original = reference?.release?.original;

    return SliverPadding(
      padding: const EdgeInsets.only(top: 100.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              if (referenceImageUrl.isNotEmpty)
                Hero(
                  tag: widget.referenceId,
                  child: ReferenceAvatar(
                    imageUrl: referenceImageUrl,
                  ),
                ),
              if (referenceName.isNotEmpty)
                Hero(
                  tag: '${widget.referenceId}-name',
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          referenceName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (original != null) originalRelease(original),
            ],
          ),
        ]),
      ),
    );
  }

  Widget originalRelease(DateTime original) {
    return Opacity(
      opacity: 0.4,
      child: InkWell(
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => Material(
              child: Container(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(UniconsLine.clock),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        Jiffy(original).yMMMMd,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Text(
          original.year.toString(),
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Reference's job, links and summary.
  Widget textsPanels() {
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
        Container(
          alignment: AlignmentDirectional.center,
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                beginY: beginY,
                delay: 200.milliseconds,
                child: types(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 45.0,
                ),
                child: links(),
              ),
              if (isSummaryVisible)
                FadeInY(
                  beginY: -20.0,
                  endY: 0.0,
                  child: summaryTextBlock(),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget langDropdown() {
    if (isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([]),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Center(
            child: SizedBox(
              width: 80.0,
              child: Divider(thickness: 2.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 30.0,
            ),
          ),
          Center(
            child: LangPopupMenuButton(
              lang: lang,
              elevation: 2.0,
              onLangChanged: (newLang) {
                lang = newLang;

                fetchQuotes();

                appStorage.setPageLang(
                  lang: lang,
                  pageRoute: pageRoute,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget links() {
    final urls = reference.urls;

    if (urls.areLinksEmpty()) {
      return Padding(
        padding: EdgeInsets.zero,
        child: summaryButtonCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        children: <Widget>[
          summaryButtonCard(),
          if (urls.website.isNotEmpty)
            linkSquareButton(
              delay: 0,
              name: 'Website',
              url: urls.website,
              icon: Icon(UniconsLine.globe),
            ),
          if (urls.wikipedia.isNotEmpty)
            linkSquareButton(
              delay: 50,
              name: 'Wikipedia',
              url: urls.wikipedia,
              icon: FaIcon(FontAwesomeIcons.wikipediaW),
            ),
          if (urls.amazon.isNotEmpty)
            linkSquareButton(
              delay: 100,
              name: 'Amazon',
              url: urls.amazon,
              icon: Icon(UniconsLine.amazon),
            ),
          if (urls.facebook.isNotEmpty)
            linkSquareButton(
              delay: 150,
              name: 'Facebook',
              url: urls.facebook,
              icon: Icon(UniconsLine.facebook),
            ),
          if (urls.instagram.isNotEmpty)
            linkSquareButton(
              delay: 200,
              name: 'Instagram',
              url: urls.instagram,
              icon: Icon(UniconsLine.instagram),
            ),
          if (urls.netflix.isNotEmpty)
            linkSquareButton(
              delay: 250,
              name: 'Netflix',
              url: urls.netflix,
              icon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/images/netflix.png',
                  width: 16.0,
                  height: 16.0,
                  color: stateColors.foreground,
                ),
              ),
            ),
          if (urls.primeVideo.isNotEmpty)
            linkSquareButton(
              delay: 300,
              name: 'Prime Video',
              url: urls.primeVideo,
              icon: Icon(UniconsLine.video),
            ),
          if (urls.twitch.isNotEmpty)
            linkSquareButton(
              delay: 350,
              name: 'Twitch',
              url: urls.twitch,
              icon: FaIcon(FontAwesomeIcons.twitch),
            ),
          if (urls.twitter.isNotEmpty)
            linkSquareButton(
              delay: 400,
              name: 'Twitter',
              url: urls.twitter,
              icon: Icon(UniconsLine.twitter),
            ),
          if (urls.youtube.isNotEmpty)
            linkSquareButton(
              delay: 450,
              name: 'Youtube',
              url: urls.youtube,
              icon: Icon(UniconsLine.youtube),
            ),
        ],
      ),
    );
  }

  Widget linkSquareButton({
    int delay = 0,
    String name,
    String url,
    String imageUrl,
    Widget icon,
  }) {
    return FadeInX(
      beginX: 10.0,
      delay: Duration(milliseconds: delay),
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
                child: icon != null
                    ? icon
                    : Image.asset(
                        imageUrl,
                        width: 16.0,
                        color: stateColors.foreground,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget name() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextButton(
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
          style: FontsUtils.mainStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget quotesListView() {
    if (isLoading) {
      return SliverPadding(padding: EdgeInsets.zero);
    }

    if (quotes.isEmpty) {
      return SliverEmptyView(
        titleString: "No quote found",
        descriptionString: "Sorry, we didn't found any quote "
            "in ${Language.frontend(lang)} for ${reference.name}. "
            "You can try in another language.",
        onRefresh: () => fetchQuotes(),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final horPadding = width < 400.0 ? 10.0 : 20.0;

    return Observer(
      builder: (context) {
        final isConnected = stateUser.isUserConnected;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final quote = quotes.elementAt(index);

              return Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 700.0,
                    ),
                    child: QuoteRowWithActions(
                      quote: quote,
                      quoteFontSize: 18.0,
                      isConnected: isConnected,
                      key: ObjectKey(index),
                      useSwipeActions: width < Constants.maxMobileWidth,
                      color: stateColors.tileBackground,
                      padding: EdgeInsets.symmetric(
                        horizontal: horPadding,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ],
              );
            },
            childCount: quotes.length,
          ),
        );
      },
    );
  }

  Widget summaryButtonCard() {
    return Tooltip(
      message: 'summary',
      child: SizedBox(
        height: 80.0,
        width: 80.0,
        child: Card(
          elevation: 4.0,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              setState(() => isSummaryVisible = !isSummaryVisible);

              if (isSummaryVisible) {
                Future.delayed(
                  250.milliseconds,
                  () => _pageScrollController.animateTo(
                    500.0,
                    duration: 250.milliseconds,
                    curve: Curves.bounceIn,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Icon(
                UniconsLine.list_ul,
                size: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryTextBlock() {
    final width = MediaQuery.of(context).size.width < 600.0 ? 600.0 : 800;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
        ),
        Divider(thickness: 1.0),
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
          width: width,
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
          OutlinedButton(
            onPressed: () => launch(reference.urls.wikipedia),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('More on Wikipedia'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(UniconsLine.external_link_alt),
                  ),
                ],
              ),
            ),
          ),
        Divider(
          height: 80.0,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget types() {
    final type = reference.type;
    String primaryType = '';
    String secondaryType = '';

    if (type == null || type.primary == null) {
      return Container();
    }

    primaryType = type.primary ?? '';
    secondaryType = type.secondary ?? '';

    return Container(
      padding: const EdgeInsets.all(24.0),
      width: 400.0,
      child: Card(
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      UniconsLine.circle,
                      color: stateColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        primaryType,
                        overflow: TextOverflow.ellipsis,
                        style: FontsUtils.mainStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
              ),
              if (secondaryType.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        UniconsLine.pentagon,
                        color: stateColors.primary,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            secondaryType,
                            overflow: TextOverflow.ellipsis,
                            style: FontsUtils.mainStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userActions() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([]),
      );
    }

    final buttonsList = <Widget>[
      SquareAction(
        icon: Icon(UniconsLine.share),
        borderColor: Colors.blue,
        tooltip: 'Share this reference',
        onTap: () async {
          ShareActions.shareReference(
            context: context,
            reference: reference,
          );
        },
      ),
    ];

    if (stateUser.canManageReferences) {
      buttonsList.addAll([
        SquareAction(
          icon: Icon(UniconsLine.trash),
          borderColor: Colors.pink,
          tooltip: "Delete reference",
          onTap: () => confirmAndDeleteReference(),
        ),
        SquareAction(
          icon: Icon(UniconsLine.edit),
          borderColor: Colors.amber,
          tooltip: "Edit author",
          onTap: () {
            DataQuoteInputs.isEditingPubQuote = false;

            context.router.root.push(
              DashboardPageRoute(children: [
                AdminDeepRoute(children: [
                  AdminEditDeepRoute(
                    children: [
                      EditReferenceRoute(
                        referenceId: reference.id,
                        reference: reference,
                      ),
                    ],
                  )
                ])
              ]),
            );
          },
        ),
      ]);
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5.0,
            children: buttonsList,
          ),
        ),
      ]),
    );
  }

  void confirmAndDeleteReference() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        final focusNode = FocusNode();

        return RawKeyboardListener(
          autofocus: true,
          focusNode: focusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter) ||
                keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
              deleteReferenceAndNavBack();
              return;
            }
          },
          child: Material(
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    tileColor: stateColors.deletion,
                    onTap: deleteReferenceAndNavBack,
                  ),
                  ListTile(
                    title: Text('Cancel'),
                    trailing: Icon(Icons.close),
                    onTap: context.router.pop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void deleteReferenceAndNavBack() {
    context.router.pop();

    ReferencesActions.delete(
      reference: reference,
    );

    if (context.router.root.stack.length > 1) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        context.router.pop();
      });
      return;
    }

    context.router.root.push(HomeRoute());
  }

  void fetch() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .doc(widget.referenceId)
          .get();

      if (!snapshot.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = snapshot.data();
      data['id'] = snapshot.id;

      setState(() {
        reference = Reference.fromJSON(data);

        nameEllipsis = reference.name.length > 42
            ? TextOverflow.ellipsis
            : TextOverflow.visible;

        isLoading = false;
      });
    } catch (error) {
      appLogger.d(error);
      setState(() => isLoading = false);
    }
  }

  void fetchQuotes() async {
    quotes.clear();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('reference.id', isEqualTo: widget.referenceId)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => hasNext = false);
        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        lastFetchedDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      appLogger.d(error);
    }
  }

  void fetchMoreQuotes() async {
    if (!hasNext) {
      return;
    }

    isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('reference.id', isEqualTo: widget.referenceId)
          .where('lang', isEqualTo: lang)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastFetchedDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = Quote.fromJSON(data);
        quotes.add(quote);
      });

      setState(() {
        isLoadingMore = false;
        lastFetchedDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      appLogger.d(error);
      setState(() => isLoadingMore = false);
    }
  }
}
