import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/screens/add_quote/author.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/author.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditAuthor extends StatefulWidget {
  final String authorId;
  final Author author;

  const EditAuthor({
    Key key,
    @required @PathParam() this.authorId,
    this.author,
  }) : super(key: key);

  @override
  _EditAuthorState createState() => _EditAuthorState();
}

class _EditAuthorState extends State<EditAuthor> {
  Author author;

  bool hasErrors = false;
  bool isLoading = false;
  bool isSaving = false;

  DocumentSnapshot authorDoc;

  String errorDescription = '';

  @override
  initState() {
    super.initState();

    if (widget.author == null) {
      fetch();
    } else {
      author = widget.author;
      fillDataInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFabVisible = !isLoading && !isSaving;

    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton.extended(
              onPressed: saveAuthor,
              label: Text('Save'),
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(UniconsLine.save),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          PageAppBar(
            textTitle: "Edit author",
            textSubTitle: author != null ? author.name : "",
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              body(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (isSaving) {
      return loadingView(message: "Saving author data...");
    }

    if (hasErrors) {
      return errorView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AddQuoteAuthor(
        editMode: EditAuthorMode.editAuthor,
      ),
    );
  }

  Widget errorView() {
    if (errorDescription.isEmpty) {
      errorDescription = "Sorry there was an unexpected error."
          "Please try again or contact us if the issue persists.";
    }

    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: [
          Opacity(
            opacity: 0.6,
            child: Icon(
              UniconsLine.exclamation_triangle,
              size: 42.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(errorDescription),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingView({String message = "Loading author data..."}) {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        children: [
          AnimatedAppIcon(),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      hasErrors = false;
    });

    try {
      authorDoc = await FirebaseFirestore.instance
          .collection('authors')
          .doc(widget.authorId)
          .get();

      if (!authorDoc.exists) {
        setState(() {
          hasErrors = true;
          errorDescription = "The author with the id ${widget.authorId} "
              "doesn't exists. They may have been deleted";
        });
        return;
      }

      final authorData = authorDoc.data();
      authorData['id'] = authorDoc.id;
      author = Author.fromJSON(authorData);

      setState(() {
        isLoading = false;
        fillDataInputs();
      });
    } catch (error) {
      appLogger.d(error);

      setState(() {
        isLoading = false;
        hasErrors = true;
        errorDescription = "There was an error while fetching author data. "
            "Please try again later or contact us if the issue persists.";
      });
    }
  }

  void fillDataInputs() async {
    if (author == null) {
      hasErrors = true;
      errorDescription = "There was an error while fetching author data. "
          "Please try again later or contact us if the issue persists.";
      return;
    }

    await fetchFromReference();

    DataQuoteInputs.author = author;
  }

  void saveAuthor() async {
    setState(() {
      isSaving = true;
      hasErrors = false;
    });

    try {
      await authorDoc.reference.update(DataQuoteInputs.author.toJSON());
      setState(() => isSaving = false);

      showSnack(
        context: context,
        message: "Author's data was successfully saved.",
        type: SnackType.success,
        primaryAction: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () {
              if (context.router.root.stack.length > 1) {
                context.router.pop();
                return;
              }

              context.router.root.push(HomeRoute());
            },
            child: Text("GO BACK"),
          ),
        ),
      );
    } catch (error) {
      appLogger.d(error);
      setState(() {
        hasErrors = true;
        isSaving = false;
      });

      showSnack(
        context: context,
        message: "There was an issue while saving your modifications. "
            "Please try again or contact us if the issue persists.",
        type: SnackType.error,
      );
    }
  }

  Future fetchFromReference() async {
    if (author.fromReference.id.isEmpty) {
      return;
    }

    final referenceDoc = await FirebaseFirestore.instance
        .collection('references')
        .doc(author.fromReference.id)
        .get();

    final referenceData = referenceDoc.data();

    if (referenceDoc.exists && referenceData != null) {
      author.fromReference.name = referenceData['name'];
    }
  }
}
