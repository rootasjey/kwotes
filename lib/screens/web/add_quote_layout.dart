import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/drafts.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

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

  bool canManage = false;

  String fabText = 'Propose';
  Icon fabIcon = Icon(Icons.send);
  bool isFabVisible = true;

  AddQuoteType actionIntent;
  AddQuoteType actionResult;

  @override
  void initState() {
    super.initState();
    checkAuth();

    if (AddQuoteInputs.quote.id.isNotEmpty) {
      fabText = 'Save';
      fabIcon = Icon(Icons.save);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
        isFabVisible ?
          FloatingActionButton.extended(
            onPressed: () => propose(),
            label: Text(fabText),
            foregroundColor: Colors.white,
            icon: fabIcon,
            backgroundColor: Colors.green,
          ) :
          Padding(padding: EdgeInsets.zero),

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
        title: AddQuoteInputs.quote.id.isEmpty ?
          'Proposing quote...' : 'Saving quote...',
      );
    }

    if (isCompleted) {
      return completedView();
    }

    return widget.child;
  }

  Widget completedView() {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: <Widget>[
          AppIconHeader(),

          Container(
            width: 500.0,
            padding: const EdgeInsets.only(top: 10.0),
            child: Opacity(
              opacity: .8,
              child: Text(
                getResultMessage(
                  actionIntent: actionIntent,
                  actionResult: actionResult,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
          ),

          Container(
            width: 500.0,
            padding: const EdgeInsets.only(top: 10.0),
            child: Opacity(
              opacity: .5,
              child: Text(
                getResultSubMessage(
                  actionIntent: actionIntent,
                  actionResult: actionResult,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
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
                  onTap: () {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/dashboard'),
                    );

                    FluroRouter.router.navigateTo(
                      context,
                      DashboardRoute,
                      replace: true,
                    );
                  },
                ),

                navCard(
                  icon: Icon(Icons.add, size: 40.0,),
                  title: 'Add another quote',
                  onTap: () {
                    AddQuoteInputs.clearQuoteData();
                    AddQuoteInputs.clearTopics();
                    AddQuoteInputs.clearComment();

                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/dashboard'),
                    );

                    FluroRouter.router.navigateTo(
                      context,
                      AddQuoteContentRoute,
                    );
                  },
                ),

                canManage ?
                  navCard(
                    icon: Icon(Icons.timer, size: 40.0,),
                    title: 'Temporary quotes',
                    onTap: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/dashboard'),
                      );

                      FluroRouter.router.navigateTo(
                        context,
                        AdminTempQuotesRoute,
                      );
                    },
                  ) :
                  navCard(
                    icon: Icon(Icons.home, size: 40.0,),
                    title: 'Home',
                    onTap: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/dashboard'),
                      );

                      FluroRouter.router.navigateTo(
                        context,
                        RootRoute,
                      );
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

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
      isFabVisible = false;
    });

    try {
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
        isFabVisible = true;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
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
      debugPrint(error.toString());
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void propose() async {
    actionIntent = AddQuoteType.tempquote;

    setState(() {
      isProposing = true;
      isFabVisible = false;
    });

    final success = await proposeQuote(context: context);

    if (success) {
      setState(() {
        actionResult = AddQuoteType.tempquote;
        isProposing = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(createdAt: AddQuoteInputs.draft.createdAt.toString());
      }

      if (AddQuoteInputs.draft != null) {
        await deleteDraft(
          context: context,
          draft: AddQuoteInputs.draft,
        );
      }

      return;
    }

      // Don't duplicate the draft (if it's already one)
    if (AddQuoteInputs.draft != null) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isProposing = false;
        isCompleted = true;
      });

      return;
    }

    final successDraft = await saveDraft(
      context: context,
    );

    if (successDraft) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isProposing = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: AddQuoteInputs.draft.createdAt.toString(),
        );
      }

      return;
    }

    await saveOfflineDraft(context: context);
    actionResult = AddQuoteType.offline;
  }
}
