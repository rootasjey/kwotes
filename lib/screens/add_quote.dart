import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/drafts.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/screens/add_quote_author.dart';
import 'package:memorare/screens/add_quote_comment.dart';
import 'package:memorare/screens/add_quote_content.dart';
import 'package:memorare/screens/add_quote_last_step.dart';
import 'package:memorare/screens/add_quote_reference.dart';
import 'package:memorare/screens/add_quote_topics.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/snack.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

enum ActionType {
  draft,
  offline,
  tempquote,
}

class AddQuote extends StatefulWidget {
  @override
  _AddQuoteState createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final int maxSteps  = 6;
  bool isFabVisible   = true;

  bool canManage      = false;
  bool isProposing    = false;
  bool isCompleted    = false;

  ActionType actionIntent;
  ActionType actionResult;

  final pageController = PageController(
    initialPage: 0,
  );

  @override
  initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onNextPage() async {
    if (pageController.page < (maxSteps - 1)) {
      pageController.jumpToPage(pageController.page.toInt() + 1);
    }
  }

  void onPreviousPage() async {
    if (pageController.page > 0) {
      pageController.jumpToPage(pageController.page.toInt() - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible ?
        InkWell(
          onLongPress: () => saveQuoteAsDraft(),
          child: FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              propose();
            },
            child: Icon(Icons.send,),
          ),
        ) :
        Padding(padding: EdgeInsets.zero,),

      body: body(),
    );
  }

  Widget body() {
    if (isProposing) {
      return LoadingAnimation(
        textTitle: AddQuoteInputs.quote.id.isEmpty ?
          'Proposing quote...' : 'Saving quote...',
      );
    }

    if (isCompleted) {
      return completedView();
    }

    return stepperPageView();
  }

  Widget completedView() {
    return Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FadeInY(
                  delay: 0.0,
                  beginY: 50.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 100.0,
                        bottom: 40.0,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80.0,
                      ),
                    ),
                  ),
                ),

                FadeInY(
                  delay: 1.5,
                  beginY: 50.0,
                  child: Text(
                    getResultMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),

                ControlledAnimation(
                  duration: 1.seconds,
                  tween: Tween(begin: 0.0, end: 100.0),
                  builder: (context, value) {
                    return Center(
                      child: SizedBox(
                        width: value,
                        child: Divider(height: 100.0,),
                      ),
                    );
                  },
                ),

                FadeInY(
                  delay: 2.0,
                  beginY: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Opacity(
                      opacity: .6,
                      child: Text(
                        getResultSubMessage(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 100.0,
              bottom: 200.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Column(
              children: <Widget>[
                FadeInY(
                  delay: 3.0,
                  beginY: 50.0,
                  child: navCard(
                    icon: Icon(Icons.dashboard, size: 40.0,),
                    title: 'Home',
                    onTap: () => FluroRouter.router.navigateTo(context, HomeRoute),
                  ),
                ),

                FadeInY(
                  delay: 3.5,
                  beginY: 50.0,
                  child: navCard(
                    icon: Icon(Icons.add, size: 40.0,),
                    title: 'New quote',
                    onTap: () {
                      AddQuoteInputs.clearQuoteData();
                      AddQuoteInputs.clearTopics();
                      AddQuoteInputs.clearComment();

                      setState(() {
                        isCompleted = false;
                        isFabVisible = true;
                      });
                    },
                  ),
                ),

                FadeInY(
                  delay: 4.0,
                  beginY: 50.0,
                  child: navCard(
                    icon: Icon(Icons.timer, size: 40.0,),
                    title: 'In validation',
                    onTap: () {
                      if (canManage) {
                        FluroRouter.router.navigateTo(context, AdminTempQuotesRoute);
                        return;
                      }

                      FluroRouter.router.navigateTo(context, TempQuotesRoute);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget navCard({
    Icon icon,
    Function onTap,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 300.0,
        height: 80.0,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            )
          ),
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Opacity(opacity: .5, child: icon),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Opacity(
                    opacity: .6,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget stepperPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (pageIndex) {
        if (pageIndex == (maxSteps - 1)) {
          setState(() {
            isFabVisible = false;
          });

          return;
        }

        setState(() {
          isFabVisible = true;
        });
      },
      children: <Widget>[
        AddQuoteContent(
          step: 1,
          maxSteps: maxSteps,
          onNextStep: () => onNextPage(),
          onSaveDraft: () => saveQuoteAsDraft(),
        ),

        AddQuoteTopics(
          step: 2,
          maxSteps: maxSteps,
          onNextStep: () => onNextPage(),
          onPreviousStep: () => onPreviousPage(),
        ),

        AddQuoteAuthor(
          step: 3,
          maxSteps: maxSteps,
          onNextStep: () => onNextPage(),
          onPreviousStep: () => onPreviousPage(),
        ),

        AddQuoteReference(
          step: 4,
          maxSteps: maxSteps,
          onNextStep: () => onNextPage(),
          onPreviousStep: () => onPreviousPage(),
        ),

        AddQuoteComment(
          step: 5,
          maxSteps: maxSteps,
          onNextStep: () => onNextPage(),
          onPreviousStep: () => onPreviousPage(),
        ),

        AddQuoteLastStep(
          step: 6,
          maxSteps: maxSteps,
          onPreviousStep: () => onPreviousPage(),
          onPropose: () => propose(),
          onSaveDraft: () => saveQuoteAsDraft(),
        ),
      ],
    );
  }

  void checkAuth() async {
    try {
      final userAuth = await userState.userAuth;

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
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  String getResultMessage() {
    if ((actionIntent == actionResult) && actionIntent == ActionType.tempquote) {
      return AddQuoteInputs.quote.id.isEmpty ?
        'Your quote has been successfully proposed' :
        'Your quote has been successfully saved';
    }

    if ((actionIntent == actionResult) && actionIntent == ActionType.draft) {
      return 'Your draft has been successfully saved';
    }

    if (actionIntent == ActionType.tempquote && actionResult == ActionType.draft) {
      return "We saved your draft";
    }

    if (actionIntent == ActionType.tempquote && actionResult == ActionType.offline) {
      return "We saved your offline draft";
    }

    if (actionIntent == ActionType.draft && actionResult == ActionType.offline) {
      return "We saved your offline draft";
    }

    return 'Your quote has been successfully saved';
  }

  String getResultSubMessage() {
    if ((actionIntent == actionResult) && actionIntent == ActionType.tempquote) {
      return AddQuoteInputs.quote.id.isEmpty ?
        'Soon, a moderator will review it and it will ba validated if everything is alright' :
        "It's time to let things happen";
    }

    if ((actionIntent == actionResult) && actionIntent == ActionType.draft) {
      return 'You can edit it later and propose it when you are ready';
    }

    if (actionIntent == ActionType.tempquote && actionResult == ActionType.draft) {
      return "We couldn't propose your quote at the moment (maybe you've reached your quota) but we saved it in your drafts";
    }

    if (actionIntent == ActionType.tempquote && actionResult == ActionType.offline) {
      return "It seems that you've no internet connection anymore, but we saved it in your offline drafts";
    }

    if (actionIntent == ActionType.draft && actionResult == ActionType.offline) {
      return "It seems that you've no internet connection anymore, but we saved it in your offline drafts";
    }

    return "It's time to let things happen";
  }

  void propose() async {
    actionIntent = ActionType.tempquote;

    setState(() {
      isProposing = true;
      isFabVisible = false;
    });

    final success = await proposeQuote(context: context);

    if (success) {
      setState(() {
        actionResult = ActionType.tempquote;
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
        actionResult = ActionType.draft;
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
        actionResult = ActionType.draft;
        isProposing = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(createdAt: AddQuoteInputs.draft.createdAt.toString());
      }

      return;
    }

    await saveOfflineDraft(context: context);
    actionResult = ActionType.offline;
  }

  void saveQuoteAsDraft() async {
    actionIntent = ActionType.draft;

    setState(() {
      isProposing = true;
      isCompleted = true;
      isFabVisible = false;
    });

    final success = await saveDraft(
      context: context,
    );

    if (success) {
      setState(() {
        actionResult = ActionType.draft;
        isProposing = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(createdAt: AddQuoteInputs.draft.createdAt.toString());
      }

      return;
    }

    final successOffline = await saveOfflineDraft(context: context);

    if (successOffline) {
      setState(() {
        actionResult = ActionType.offline;
        isProposing = false;
        isCompleted = true;
      });

      return;
    }

    showSnack(
      context: context,
      message: "Sorry, we couldn't save your quote as a draft. Try again in some minutes..",
      type: SnackType.error,
    );
  }
}
