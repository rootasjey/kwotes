import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/screens/add_quote/reference.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/reference.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditReference extends StatefulWidget {
  final String referenceId;
  final Reference reference;

  const EditReference({
    Key key,
    @required @PathParam() this.referenceId,
    this.reference,
  }) : super(key: key);

  @override
  _EditReferenceState createState() => _EditReferenceState();
}

class _EditReferenceState extends State<EditReference> {
  bool hasErrors = false;
  bool isLoading = false;
  bool isSaving = false;

  DocumentSnapshot referenceDoc;

  Reference reference;

  String errorDescription = '';

  @override
  initState() {
    super.initState();

    if (widget.reference == null) {
      fetch();
    } else {
      reference = widget.reference;
      fillDataInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFabVisible = !isLoading && !isSaving;

    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton.extended(
              onPressed: saveReference,
              label: Text('Save'),
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(UniconsLine.save),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          PageAppBar(
            textTitle: "Edit reference",
            textSubTitle: reference != null ? reference.name : "",
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
      return loadingView(message: "Saving reference data...");
    }

    if (hasErrors) {
      return errorView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AddQuoteReference(
        editMode: EditDataMode.editReference,
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

  Widget loadingView({String message = "Loading reference data..."}) {
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
      referenceDoc = await FirebaseFirestore.instance
          .collection('references')
          .doc(widget.referenceId)
          .get();

      if (!referenceDoc.exists) {
        setState(() {
          hasErrors = true;
          errorDescription = "The reference with the id ${widget.referenceId} "
              "doesn't exists. It may have been deleted";
        });
        return;
      }

      final referenceData = referenceDoc.data();
      referenceData['id'] = referenceDoc.id;
      reference = Reference.fromJSON(referenceData);

      setState(() {
        isLoading = false;
        fillDataInputs();
      });
    } catch (error) {
      appLogger.d(error);

      setState(() {
        isLoading = false;
        hasErrors = true;
        errorDescription = "There was an error while fetching reference data. "
            "Please try again later or contact us if the issue persists.";
      });
    }
  }

  void fillDataInputs() async {
    if (reference == null) {
      hasErrors = true;
      errorDescription = "There was an error while fetching reference data. "
          "Please try again later or contact us if the issue persists.";
      return;
    }

    DataQuoteInputs.reference = reference;
  }

  void saveReference() async {
    setState(() {
      isSaving = true;
      hasErrors = false;
    });

    try {
      if (referenceDoc == null) {
        await FirebaseFirestore.instance
            .collection('references')
            .doc(reference.id)
            .update(DataQuoteInputs.reference.toJSON());
      } else {
        await referenceDoc.reference.update(DataQuoteInputs.reference.toJSON());
      }
      setState(() => isSaving = false);

      Snack.s(
        context: context,
        message: "Reference's data was successfully saved.",
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

      Snack.e(
        context: context,
        message: "There was an issue while saving your modifications. "
            "Please try again or contact us if the issue persists.",
      );
    }
  }
}
