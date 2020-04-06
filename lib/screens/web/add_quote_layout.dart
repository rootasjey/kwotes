import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class AddQuoteLayout extends StatefulWidget {
  final Widget child;

  AddQuoteLayout({this.child});

  @override
  _AddQuoteLayoutState createState() => _AddQuoteLayoutState();
}

class _AddQuoteLayoutState extends State<AddQuoteLayout> {
  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isProposing    = false;
  String errorMessage = '';

  FirebaseUser userAuth;
  bool canManage = false;

  String fabText = 'Propose';
  Icon fabIcon = Icon(Icons.send);

  @override
  void initState() {
    super.initState();
    checkAuth();

    if (AddQuoteInputs.id.isNotEmpty) {
      fabText = 'Save';
      fabIcon = Icon(Icons.save);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFABVisible = isProposing || isCompleted || isCheckingAuth;
    return Scaffold(
      floatingActionButton:
      isFABVisible ?
      Padding(padding: EdgeInsets.zero,) :
      FloatingActionButton.extended(
        onPressed: () {
          proposeQuote();
        },
        label: Text(fabText),
        foregroundColor: Colors.white,
        icon: fabIcon,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: <Widget>[
          body(),
          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (errorMessage.isNotEmpty) {
      return FullPageError(
        message: errorMessage,
      );
    }

    if (isCheckingAuth) {
      return FullPageLoading();
    }

    if (isProposing) {
      return FullPageLoading(
        title: AddQuoteInputs.id.isEmpty ?
          'Proposing quote...' : 'Saving quote...',
      );
    }

    if (isCompleted) {
      return completedContainer();
    }

    return widget.child;
  }

  Widget completedContainer() {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: <Widget>[
          AppIconHeader(),

          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
              'Your quote has been successfully proposed!',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Soon, a moderator will review it and it will ba validated if everything is alright.',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 100.0, bottom: 200.0),
            child: Wrap(
              spacing: 30.0,
              children: <Widget>[
                navCard(
                  icon: Icon(Icons.dashboard, size: 40.0,),
                  title: 'Dashboard',
                  onTap: () => FluroRouter.router.navigateTo(context, DashboardRoute),
                ),

                navCard(
                  icon: Icon(Icons.add, size: 40.0,),
                  title: 'Add another quote',
                  onTap: () {
                    AddQuoteInputs.clearQuoteName();
                    AddQuoteInputs.clearTopics();
                    AddQuoteInputs.clearQuoteId();
                    AddQuoteInputs.clearComment();
                    FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
                  },
                ),

                canManage ?
                  navCard(
                    icon: Icon(Icons.timer, size: 40.0,),
                    title: 'Temporary quotes',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, AdminTempQuotesRoute);
                    },
                  ):
                  navCard(
                    icon: Icon(Icons.home, size: 40.0,),
                    title: 'Home',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, RootRoute);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget navCard({Icon icon, Function onTap, String title,}) {
    return SizedBox(
      width: 200.0,
      height: 250.0,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Opacity(opacity: .8, child: icon),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future addNewTempQuote({
    List<String> comments,
    List<Map<String, dynamic>> references,
    Map<String, bool> topics,
  }) async {

    await Firestore.instance
      .collection('tempquotes')
      .add({
        'author'        : {
          'id'          : AddQuoteInputs.authorId,
          'job'         : AddQuoteInputs.authorJob,
          'jobLang'     : {},
          'name'        : AddQuoteInputs.authorName,
          'summary'     : AddQuoteInputs.authorSummary,
          'summaryLang' : {},
          'updatedAt'   : DateTime.now(),
          'urls': {
            'affiliate' : AddQuoteInputs.authorAffiliateUrl,
            'image'     : AddQuoteInputs.authorImgUrl,
            'website'   : AddQuoteInputs.authorUrl,
            'wikipedia' : AddQuoteInputs.authorWikiUrl,
          }
        },
        'comments'      : comments,
        'createdAt'     : DateTime.now(),
        'lang'          : AddQuoteInputs.lang,
        'name'          : AddQuoteInputs.name,
        'mainReference' : {
          'id'  : AddQuoteInputs.refId,
          'name': AddQuoteInputs.refName,
        },
        'references'    : references,
        'region'        : AddQuoteInputs.region,
        'topics'        : topics,
        'user': {
          'id': userAuth.uid,
        },
        'updatedAt'     : DateTime.now(),
        'validation'    : {
          'comment'     : {
            'name'      : '',
            'updatedAt' : DateTime.now(),
          },
          'status'      : 'proposed',
          'updatedAt'   : DateTime.now(),
        }
      });
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      userAuth = await getUserAuth();

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

      final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

      if (!user.exists) { return; }

      setState(() {
        canManage = user.data['rights']['user:managequote'] == true;
      });

    } catch (error) {
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void proposeQuote() async {
    if (AddQuoteInputs.name.isEmpty) {
      showSnack(
        context: context,
        message: "The quote's content cannot be empty.",
        type: SnackType.error,
      );

      return;
    }

    if (AddQuoteInputs.topics.length == 0) {
      showSnack(
        context: context,
        message: 'You must select at least 1 topics for the quote.',
        type: SnackType.error,
      );

      return;
    }

    setState(() {
      isProposing = true;
    });

    final comments = List<String>();

    if (AddQuoteInputs.comment.isNotEmpty) {
      comments.add(AddQuoteInputs.comment);
    }

    final references = List<Map<String, dynamic>>();

    if (AddQuoteInputs.refName.isNotEmpty) {
      references.add(
        {
          'imgUrl'      : AddQuoteInputs.refImgUrl,
          'lang'        : AddQuoteInputs.refLang,
          'links'       : [],
          'name'        : AddQuoteInputs.refName,
          'summary'     : AddQuoteInputs.refSummary,
          'type'        : {
            'primary'   : AddQuoteInputs.refPrimaryType,
            'secondary' : AddQuoteInputs.refSecondaryType,
          },
          'urls'        : {
            'affiliate' : AddQuoteInputs.refAffiliateUrl,
            'image'     : AddQuoteInputs.refImgUrl,
            'website'   : AddQuoteInputs.refUrl,
            'wikipedia' : AddQuoteInputs.refWikiUrl,
          },
        }
      );
    }

    final topics = Map<String, bool>();

    AddQuoteInputs.topics.forEach((topic) {
      topics[topic] = true;
    });

    try {
      // !NOTE: Use cloud function instead.
      final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

      int today = user.data['quota']['today'];
      today++;

      int proposed = user.data['stats']['proposed'];
      proposed++;

      await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .updateData({
          'quota.today': today,
          'stats.proposed': proposed,
        });

      if (AddQuoteInputs.id.isEmpty) {
        await addNewTempQuote(
          comments: comments,
          references: references,
          topics: topics,
        );

      } else {
        await saveExistingTempQuote(
          comments  : comments,
          references: references,
          topics    : topics,
        );
      }

      setState(() {
        isProposing = false;
        isCompleted = true;
      });

      showSnack(
        context: context,
        message: AddQuoteInputs.id.isEmpty ?
          'Your quote has been successfully proposed.' :
          'Your quote has been successfully edited',
        type: SnackType.success,
      );

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isProposing = false;
        errorMessage = error.toString();
        isCompleted = true;
      });

      showSnack(
        context: context,
        message: 'There was an issue while proposing your new quote.',
        type: SnackType.error,
      );
    }
  }

  Future saveExistingTempQuote({
    List<String> comments,
    List<Map<String, dynamic>> references,
    Map<String, bool> topics,
  }) async {

    await Firestore.instance
      .collection('tempquotes')
      .document(AddQuoteInputs.id)
      .setData({
        'author': {
          'id'          : AddQuoteInputs.authorId,
          'job'         : AddQuoteInputs.authorJob,
          'jobLang'     : {},
          'name'        : AddQuoteInputs.authorName,
          'summary'     : AddQuoteInputs.authorSummary,
          'summaryLang' : {},
          'updatedAt'   : DateTime.now(),
          'urls': {
            'affiliate' : AddQuoteInputs.authorAffiliateUrl,
            'image'     : AddQuoteInputs.authorImgUrl,
            'website'   : AddQuoteInputs.authorUrl,
            'wikipedia' : AddQuoteInputs.authorWikiUrl,
          }
        },
        'comments'      : comments,
        'createdAt'     : DateTime.now(),
        'lang'          : AddQuoteInputs.lang,
        'name'          : AddQuoteInputs.name,
        'mainReference' : {
          'id'  : AddQuoteInputs.refId,
          'name': AddQuoteInputs.refName,
        },
        'references'    : references,
        'region'        : AddQuoteInputs.region,
        'topics'        : topics,
        'user': {
          'id': userAuth.uid,
        },
        'updatedAt'     : DateTime.now(),
        'validation'    : {
          'comment': {
            'name'      : '',
            'updatedAt' : DateTime.now(),
          },
          'status'      : 'proposed',
          'updatedAt'   : DateTime.now(),
        }
      });
  }
}
