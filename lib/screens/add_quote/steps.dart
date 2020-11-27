import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/drafts.dart';
import 'package:figstyle/actions/temp_quotes.dart';
import 'package:figstyle/components/add_quote_app_bar.dart';
import 'package:figstyle/components/full_page_error.dart';
import 'package:figstyle/components/full_page_loading.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/screens/add_quote/help/author.dart';
import 'package:figstyle/screens/add_quote/help/comment.dart';
import 'package:figstyle/screens/add_quote/help/content.dart';
import 'package:figstyle/screens/add_quote/help/reference.dart';
import 'package:figstyle/screens/add_quote/help/topics.dart';
import 'package:figstyle/screens/add_quote/author.dart';
import 'package:figstyle/screens/add_quote/comment.dart';
import 'package:figstyle/screens/add_quote/content.dart';
import 'package:figstyle/screens/add_quote/reference.dart';
import 'package:figstyle/screens/add_quote/topics.dart';
import 'package:figstyle/screens/admin_temp_quotes.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/my_temp_quotes.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/snack.dart';

class AddQuoteSteps extends StatefulWidget {
  @override
  _AddQuoteStepsState createState() => _AddQuoteStepsState();
}

class _AddQuoteStepsState extends State<AddQuoteSteps> {
  AddQuoteType actionIntent;
  AddQuoteType actionResult;

  bool canManage = false;
  bool isCheckingAuth = false;
  bool isFabVisible = false;
  bool isSmallView = false;
  bool isSubmitting = false;
  bool stepChanged = false;

  Color fabBackgroundColor = stateColors.primary;

  Icon fabIcon = Icon(Icons.send);

  int currentStep = 0;

  List<Widget> helpSteps = [
    HelpContent(),
    HelpTopics(),
    HelpAuthor(),
    HelpReference(),
    HelpComment(),
  ];

  String errorMessage = '';
  String fabText = 'Submit quote';

  @override
  void initState() {
    super.initState();
    checkAuth();

    if (DataQuoteInputs.quote.id.isNotEmpty) {
      fabText = 'Save quote';
      fabIcon = Icon(Icons.save_alt);
      fabBackgroundColor = stateColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AddQuoteAppBar(
          title: 'Add quote',
          isNarrow: true,
          help: helpSteps[currentStep],
        ),
        preferredSize: Size.fromHeight(80.0),
      ),
      floatingActionButton: isFabVisible
          ? FloatingActionButton.extended(
              onPressed: () => propose(),
              backgroundColor: fabBackgroundColor,
              foregroundColor: Colors.white,
              icon: fabIcon,
              label: Text(
                fabText,
              ),
            )
          : Padding(
              padding: EdgeInsets.zero,
            ),
      body: body(),
    );
  }

  Widget actionButtonLabel({
    String labelText = '',
    Function onTap,
    Widget icon,
    Color backgroundIconColor,
  }) {
    return SizedBox(
      width: 120.0,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 3.0,
            color: backgroundIconColor,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: icon,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                labelText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionTile({
    String labelText = '',
    Function onTap,
    Color iconBackgroundColor,
    Widget icon,
  }) {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: iconBackgroundColor,
                foregroundColor: Colors.white,
                child: icon,
              ),
              Padding(padding: const EdgeInsets.only(left: 30.0)),
              Expanded(
                flex: 2,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    labelText,
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

  Widget body() {
    if (errorMessage.isNotEmpty) {
      return FullPageError(
        message: errorMessage,
      );
    }

    if (isCheckingAuth) {
      return FullPageLoading();
    }

    if (isSubmitting) {
      return FullPageLoading(
        title: DataQuoteInputs.quote.id.isEmpty
            ? 'Submitting quote...'
            : 'Saving quote...',
      );
    }

    return stepperSections();
  }

  StepState computeStepState({
    int stepIndex,
    Function compute,
  }) {
    if (currentStep == stepIndex) {
      return StepState.editing;
    }

    if (compute != null) {
      StepState computed = compute();
      return computed;
    }

    return StepState.indexed;
  }

  Widget dynamicStepContent({@required num}) {
    if (currentStep != num) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    switch (num) {
      case 0:
        return AddQuoteContent(
          onSaveDraft: () => saveQuoteDraft(),
        );
      case 1:
        return AddQuoteTopics();
      case 2:
        return AddQuoteAuthor();
      case 3:
        return AddQuoteReference();
      case 4:
        return AddQuoteComment();
      default:
        return Padding(
          padding: EdgeInsets.zero,
        );
    }
  }

  Widget horizontalActions() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 200.0,
      ),
      child: Wrap(
        spacing: 40.0,
        runSpacing: 20.0,
        children: <Widget>[
          actionButtonLabel(
            labelText: 'Home',
            icon: Icon(Icons.home, color: Colors.white),
            backgroundIconColor: Colors.green.shade400,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Home())),
          ),
          actionButtonLabel(
            labelText: 'Add another quote',
            icon: Icon(Icons.add, color: Colors.white),
            backgroundIconColor: stateColors.primary,
            onTap: () {
              DataQuoteInputs.clearQuoteData();
              DataQuoteInputs.clearTopics();
              DataQuoteInputs.clearComment();

              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AddQuoteSteps()));
            },
          ),
          actionButtonLabel(
            labelText:
                canManage ? 'Admin temporary quotes' : 'Temporary quotes',
            icon: Icon(Icons.timelapse, color: Colors.white),
            backgroundIconColor: Colors.orange,
            onTap: () {
              if (canManage) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AdminTempQuotes()));
                return;
              }

              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => MyTempQuotes()));
            },
          ),
        ],
      ),
    );
  }

  Widget stepperSections() {
    return Stepper(
      currentStep: currentStep,
      onStepContinue: next,
      onStepCancel: cancel,
      onStepTapped: (step) => goTo(step),
      steps: [
        Step(
          title: Text('Content'),
          subtitle: Text('Required'),
          content: dynamicStepContent(num: 0),
          state: computeStepState(
              stepIndex: 0,
              compute: () {
                return DataQuoteInputs.quote.name.isEmpty
                    ? StepState.error
                    : StepState.complete;
              }),
        ),
        Step(
          title: const Text('Topics'),
          subtitle: Text('Required'),
          content: dynamicStepContent(num: 1),
          state: computeStepState(
              stepIndex: 1,
              compute: () {
                if (!stepChanged) {
                  return StepState.indexed;
                }

                if (DataQuoteInputs.quote.topics.length == 0) {
                  return StepState.error;
                }

                return StepState.complete;
              }),
        ),
        Step(
          subtitle: Text('Optional'),
          title: const Text('Author'),
          content: dynamicStepContent(num: 2),
          state: computeStepState(
              stepIndex: 2,
              compute: () {
                return DataQuoteInputs.author.name.isEmpty
                    ? StepState.indexed
                    : StepState.complete;
              }),
        ),
        Step(
          subtitle: Text('Optional'),
          title: const Text('Reference'),
          content: dynamicStepContent(num: 3),
          state: computeStepState(
              stepIndex: 3,
              compute: () {
                return DataQuoteInputs.reference.name.isEmpty
                    ? StepState.indexed
                    : StepState.complete;
              }),
        ),
        Step(
          subtitle: Text('Optional'),
          title: const Text('Comments'),
          content: dynamicStepContent(num: 4),
          state: computeStepState(
              stepIndex: 2,
              compute: () {
                return DataQuoteInputs.comment.isEmpty
                    ? StepState.indexed
                    : StepState.complete;
              }),
        ),
      ],
    );
  }

  Widget verticalActions() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 200.0,
      ),
      child: Column(
        children: <Widget>[
          actionTile(
            labelText: 'Home',
            icon: Icon(
              Icons.home,
            ),
            iconBackgroundColor: Colors.green.shade400,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Home())),
          ),
          actionTile(
            labelText: 'Add another quote',
            icon: Icon(
              Icons.add,
            ),
            iconBackgroundColor: stateColors.primary,
            onTap: () {
              DataQuoteInputs.clearQuoteData();
              DataQuoteInputs.clearTopics();
              DataQuoteInputs.clearComment();

              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
            },
          ),
          actionTile(
            labelText:
                canManage ? 'Admin temporary quotes' : 'Temporary quotes',
            icon: Icon(
              Icons.timelapse,
            ),
            iconBackgroundColor: Colors.orange,
            onTap: () {
              if (canManage) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AdminTempQuotes()));
                return;
              }

              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => MyTempQuotes()));
            },
          ),
        ],
      ),
    );
  }

  bool badQuoteFormat() {
    if (DataQuoteInputs.quote.name.isEmpty) {
      showSnack(
        context: context,
        message: "The quote's content cannot be empty.",
        type: SnackType.error,
      );

      return true;
    }

    if (DataQuoteInputs.quote.topics.length == 0) {
      showSnack(
        context: context,
        message: 'You must select at least 1 topics for the quote.',
        type: SnackType.error,
      );

      return true;
    }

    return false;
  }

  void cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
      return;
    }

    Navigator.pop(context);
  }

  void checkAuth() {
    setState(() {
      isCheckingAuth = true;
      isFabVisible = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        final userAuth = await userState.userAuth;

        if (userAuth == null) {
          setState(() => isCheckingAuth = false);
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
          return;
        }

        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.uid)
            .get();

        if (!user.exists) {
          setState(() => isCheckingAuth = false);
          return;
        }

        setState(() {
          isCheckingAuth = false;
          isFabVisible = true;
          canManage = user.data()['rights']['user:managequote'] == true;
        });
      } catch (error) {
        debugPrint(error.toString());
        isCheckingAuth = false;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );
      }
    });
  }

  void goTo(int step) {
    stepChanged = true;
    setState(() => currentStep = step);
  }

  void next() {
    currentStep + 1 < 5 // (steps.length + 1) // + 1 dynamic step
        ? goTo(currentStep + 1)
        : propose();
  }

  void propose() async {
    if (badQuoteFormat()) {
      return;
    }

    actionIntent = AddQuoteType.tempquote;

    setState(() {
      isSubmitting = true;
      isFabVisible = false;
    });

    final success = await proposeQuote(context: context);

    showSnack(
      context: context,
      message: getResultMessage(
        actionIntent: actionIntent,
        actionResult: actionResult,
      ),
      type: SnackType.success,
    );

    if (success) {
      setState(() {
        actionResult = AddQuoteType.tempquote;
        isSubmitting = false;
        isFabVisible = true;

        DataQuoteInputs.clearQuoteData();
        currentStep = 0;
      });

      if (DataQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: DataQuoteInputs.draft.createdAt.toString(),
        );
      }

      if (DataQuoteInputs.draft != null) {
        await deleteDraft(
          context: context,
          draft: DataQuoteInputs.draft,
        );
      }

      fabIcon = Icon(Icons.send);
      return;
    }

    // Don't duplicate the draft (if it's already one)
    if (DataQuoteInputs.draft != null) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isFabVisible = true;
        isSubmitting = false;
        fabIcon = Icon(Icons.send);
      });

      return;
    }

    final successDraft = await saveDraft(
      context: context,
    );

    if (successDraft) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isSubmitting = false;
        isFabVisible = true;
        fabIcon = Icon(Icons.send);
      });

      if (DataQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: DataQuoteInputs.draft.createdAt.toString(),
        );
      }

      return;
    }

    await saveOfflineDraft(context: context);

    setState(() {
      actionResult = AddQuoteType.offline;
      fabIcon = Icon(Icons.send);
      isSubmitting = false;
      isFabVisible = true;
    });
  }

  void saveQuoteDraft() async {
    if (DataQuoteInputs.quote.name.isEmpty) {
      showSnack(
        context: context,
        message: "The quote's content cannot be empty.",
        type: SnackType.error,
      );

      return;
    }

    actionIntent = AddQuoteType.draft;

    final successDraft = await saveDraft(
      context: context,
    );

    if (successDraft) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isSubmitting = false;
      });

      if (DataQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: DataQuoteInputs.draft.createdAt.toString(),
        );
      }

      return;
    }

    await saveOfflineDraft(context: context);

    setState(() {
      actionResult = AddQuoteType.offline;
      isSubmitting = false;
    });
  }
}
