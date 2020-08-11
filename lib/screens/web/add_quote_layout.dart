import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/drafts.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:supercharged/supercharged.dart';

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

  String fabText = 'Submit quote';
  Icon fabIcon = Icon(Icons.send);
  bool isFabVisible = true;

  AddQuoteType actionIntent;
  AddQuoteType actionResult;

  Map<int, Size> navCardSizes = Map();
  Map<int, double> navCardElevation = Map();

  @override
  void initState() {
    super.initState();
    checkAuth();

    if (AddQuoteInputs.quote.id.isNotEmpty) {
      fabText = 'Save quote';
      fabIcon = Icon(Icons.save);
    }

    navCardSizes[0] = Size(200.0, 250.0);
    navCardSizes[1] = Size(200.0, 250.0);
    navCardSizes[2] = Size(200.0, 250.0);

    navCardElevation[0] = 2.0;
    navCardElevation[1] = 2.0;
    navCardElevation[2] = 2.0;
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

      // body: ListView(
      //   children: <Widget>[
      //     body(),
      //     Footer(),
      //   ],
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          HomeAppBar(),
          body(),
          // Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (errorMessage.isNotEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageError(
            message: errorMessage,
          ),
        ]),
      );
    }

    if (isCheckingAuth) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageLoading(),
        ]),
      );
    }

    if (isProposing) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageLoading(
            title: AddQuoteInputs.quote.id.isEmpty
            ? 'Proposing quote...'
            : 'Saving quote...',
          ),
        ]),
      );
    }

    if (isCompleted) {
      return completedView();
    }

    return widget.child;
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
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
                      index: 0,
                      icon: Icon(Icons.home, size: 40.0,),
                      title: 'Home',
                      onTap: () {
                        FluroRouter.router.navigateTo(
                          context,
                          RootRoute,
                          replace: true,
                        );
                      },
                    ),

                    navCard(
                      index: 1,
                      icon: Icon(Icons.add, size: 40.0,),
                      title: 'Add another quote',
                      onTap: () {
                        AddQuoteInputs.clearQuoteData();
                        AddQuoteInputs.clearTopics();
                        AddQuoteInputs.clearComment();

                        FluroRouter.router.navigateTo(
                          context,
                          AddQuoteContentRoute,
                          replace: true,
                        );
                      },
                    ),

                    canManage ?
                      navCard(
                        index: 2,
                        icon: Icon(Icons.timer, size: 40.0,),
                        title: 'Admin Temporary quotes',
                        onTap: () {
                          FluroRouter.router.navigateTo(
                            context,
                            AdminTempQuotesRoute,
                            replace: true,
                          );
                        },
                      ) :
                      navCard(
                        index: 2,
                        icon: Icon(Icons.timer, size: 40.0,),
                        title: 'Temporary quotes',
                        onTap: () {
                          FluroRouter.router.navigateTo(
                            context,
                            TempQuotesRoute,
                            replace: true,
                          );
                        },
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget navCard({Icon icon, int index, Function onTap, String title,}) {
    return AnimatedContainer(
      width: navCardSizes[index].width,
      height: navCardSizes[index].height,
      duration: 200.milliseconds,
      child: Card(
        elevation: navCardElevation[index],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onHover: (isHover) {
            if (isHover) {
              setState(() {
                navCardElevation[index] = 4.0;
                navCardSizes[index] = Size(210.0, 260.0);
              });

              return;
            }

            setState(() {
              navCardElevation[index] = 2.0;
              navCardSizes[index] = Size(200.0, 250.0);
            });
          },
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
