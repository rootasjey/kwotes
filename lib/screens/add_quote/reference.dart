import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:figstyle/components/form_action_inputs.dart';
import 'package:figstyle/components/input_card.dart';
import 'package:figstyle/components/sheet_header.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/enums.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/reference_suggestion.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class AddQuoteReference extends StatefulWidget {
  final EditDataMode editMode;

  const AddQuoteReference({
    Key key,
    this.editMode = EditDataMode.addQuote,
  }) : super(key: key);

  @override
  _AddQuoteReferenceState createState() => _AddQuoteReferenceState();
}

class _AddQuoteReferenceState extends State<AddQuoteReference> {
  bool prefilledInputs = false;
  bool isLoadingSuggestions = false;
  final beginY = 10.0;

  FocusNode textFocusNode;

  TextEditingController linkInputController;
  TextEditingController textController;

  List<ReferenceSuggestion> referencesSuggestions = [];

  String tapToEditStr = 'Tap to edit';
  String tempImgUrl = '';

  Timer searchTimer;

  @override
  initState() {
    initFocusNodes();
    initInputs();

    setState(() {});

    super.initState();
  }

  @override
  dispose() {
    disposeFocusNodes();
    disposeInputs();
    super.dispose();
  }

  void initFocusNodes() {
    textFocusNode = FocusNode();
  }

  void initInputs() {
    linkInputController = TextEditingController();
    textController = TextEditingController();

    prefilledInputs = DataQuoteInputs.reference.id.isNotEmpty &&
        widget.editMode == EditDataMode.addQuote;

    textController.text = DataQuoteInputs.reference.name;
  }

  void disposeFocusNodes() {
    textFocusNode.dispose();
  }

  void disposeInputs() {
    textController.dispose();
    linkInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DataQuoteInputs.isEditingPubQuote &&
        DataQuoteInputs.reference.id.isNotEmpty) {
      return editPubQuoteView();
    }

    return normalEditView();
  }

  Widget editPubQuoteView() {
    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          existingDataCard(),
        ],
      ),
    );
  }

  Widget existingDataCard() {
    final referenceName = DataQuoteInputs.reference.name;

    return Row(
      children: [
        InputCard(
          width: 250.0,
          padding: const EdgeInsets.only(
            top: 40.0,
            bottom: 20.0,
          ),
          titleString: 'Reference',
          icon: Icon(UniconsLine.image),
          subtitleString: referenceName,
          onTap: () {
            context.router.root.push(
              ReferencesDeepRoute(
                children: [
                  ReferencePageRoute(
                    referenceId: DataQuoteInputs.reference.id,
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            onPressed: () async {
              await showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    textController.text = referenceName ?? '';
                    return nameInput();
                  });

              setState(() {});
            },
            color: stateColors.secondary,
            icon: Icon(UniconsLine.edit),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                DataQuoteInputs.clearReference();
              });
            },
            color: stateColors.deletion,
            icon: Icon(UniconsLine.times),
          ),
        ),
      ],
    );
  }

  Widget normalEditView() {
    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          avatar(),
          nameCardInput(),
          primaryTypeCardInput(),
          secondaryTypeCardInput(),
          releaseDate(),
          clearButton(),
          langSelector(),
          summaryCardInput(),
          FadeInY(
            delay: 0.milliseconds,
            beginY: beginY,
            child: links(),
          ),
        ],
      ),
    );
  }

  Widget actionsInput({
    VoidCallback onClearInput,
    VoidCallback onSaveInput,
    String clearInputText = 'Clear input',
  }) {
    double left = 40.0;
    double spacing = 20.0;

    if (MediaQuery.of(context).size.width < 600.0) {
      spacing = 5.0;
      left = 0.0;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 20.0,
        left: left,
      ),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          OutlinedButton.icon(
            onPressed: onClearInput,
            icon: Opacity(
              opacity: 0.6,
              child: Icon(Icons.clear),
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                clearInputText,
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: stateColors.foreground,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              if (onSaveInput != null) {
                onSaveInput();
              }

              Navigator.of(context).pop();
            },
            icon: Opacity(
              opacity: 0.6,
              child: Icon(Icons.check),
            ),
            label: Opacity(
              opacity: 0.6,
              child: Text(
                'Save',
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: stateColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget avatar() {
    final _onTap =
        prefilledInputs ? showPrefilledAlert : () => showAvatarDialog();

    final imageUrl = DataQuoteInputs.reference.urls.image;

    Widget child;

    if (imageUrl.isEmpty) {
      child = SizedBox(
        width: 150.0,
        height: 200.0,
        child: InkWell(
          child: Opacity(
              opacity: 0.6,
              child: Icon(
                UniconsLine.plus,
                size: 50.0,
                color: stateColors.primary,
              )),
          onTap: _onTap,
        ),
      );
    } else {
      child = Ink.image(
        width: 150.0,
        height: 200.0,
        fit: BoxFit.cover,
        image: NetworkImage(imageUrl),
        child: InkWell(
          onTap: _onTap,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 30.0,
      ),
      child: Card(
        color: Colors.black12,
        elevation: imageUrl.isEmpty ? 0.0 : 2.0,
        child: child,
      ),
    );
  }

  Widget clearButton() {
    return FlatButton.icon(
      onPressed: () {
        DataQuoteInputs.clearReference();
        textController.clear();
        referencesSuggestions.clear();

        prefilledInputs = false;
        tapToEditStr = 'Tap to edit';
        isLoadingSuggestions = false;

        setState(() {});

        textFocusNode.requestFocus();
      },
      icon: Opacity(
        opacity: 0.6,
        child: Icon(Icons.delete_sweep),
      ),
      label: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear all inputs',
        ),
      ),
    );
  }

  Widget langSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            opacity: 0.6,
            child: Text(
              'Reference language: ',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
            ),
          ),
          DropdownButton<String>(
            value: DataQuoteInputs.reference.lang,
            iconEnabledColor: stateColors.primary,
            icon: Icon(Icons.language),
            style: TextStyle(
              color: stateColors.primary,
              fontSize: 20.0,
            ),
            onChanged: prefilledInputs
                ? null
                : (newValue) {
                    setState(() {
                      DataQuoteInputs.reference.lang = newValue;
                    });
                  },
            items: Language.available().map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget links() {
    double spacing = 20.0;

    if (MediaQuery.of(context).size.width < 600.0) {
      spacing = 5.0;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: <Widget>[
          linkSquareButton(
            delay: 100,
            name: 'Website',
            active: DataQuoteInputs.reference.urls.website.isNotEmpty,
            icon: Icon(UniconsLine.globe),
            onTap: () {
              showLinkInputSheet(
                labelText: 'Website',
                initialValue: DataQuoteInputs.reference.urls.website,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.website = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 200,
            name: 'Wikipedia',
            active: DataQuoteInputs.reference.urls.wikipedia.isNotEmpty,
            icon: FaIcon(FontAwesomeIcons.wikipediaW),
            onTap: () {
              showLinkInputSheet(
                labelText: 'Wikipedia',
                initialValue: DataQuoteInputs.reference.urls.wikipedia,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.wikipedia = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 300,
            name: 'Amazon',
            icon: Icon(UniconsLine.amazon),
            active: DataQuoteInputs.reference.urls.amazon.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Amazon',
                initialValue: DataQuoteInputs.reference.urls.amazon,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.amazon = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 400,
            name: 'Facebook',
            icon: Icon(UniconsLine.facebook),
            active: DataQuoteInputs.reference.urls.facebook.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Facebook',
                initialValue: DataQuoteInputs.reference.urls.facebook,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.facebook = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 500,
            name: 'IMDB',
            icon: Icon(UniconsLine.film),
            active: DataQuoteInputs.reference.urls.imdb.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'IMDB',
                initialValue: DataQuoteInputs.reference.urls.imdb,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.imdb = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 600,
            name: 'Instagram',
            icon: Icon(UniconsLine.instagram),
            active: DataQuoteInputs.reference.urls.instagram.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Instagram',
                initialValue: DataQuoteInputs.reference.urls.instagram,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.instagram = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 700,
            name: 'Netflix',
            imageUrl: 'assets/images/netflix.png',
            active: DataQuoteInputs.reference.urls.netflix.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Netflix',
                initialValue: DataQuoteInputs.reference.urls.netflix,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.netflix = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 800,
            name: 'Prime Video',
            icon: Icon(UniconsLine.video),
            active: DataQuoteInputs.reference.urls.primeVideo.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Prime Video',
                initialValue: DataQuoteInputs.reference.urls.primeVideo,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.primeVideo = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 900,
            name: 'Twitch',
            icon: FaIcon(FontAwesomeIcons.twitch),
            active: DataQuoteInputs.reference.urls.twitch.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitch',
                initialValue: DataQuoteInputs.reference.urls.twitch,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.twitch = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 1000,
            name: 'Twitter',
            icon: Icon(UniconsLine.twitter),
            active: DataQuoteInputs.reference.urls.twitter.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitter',
                initialValue: DataQuoteInputs.reference.urls.twitter,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.twitter = inputUrl;
                  });
                },
              );
            },
          ),
          linkSquareButton(
            delay: 1100,
            name: 'YouTube',
            icon: Icon(UniconsLine.youtube),
            active: DataQuoteInputs.reference.urls.youtube.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'YouTube',
                initialValue: DataQuoteInputs.reference.urls.youtube,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.reference.urls.youtube = inputUrl;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget linkSquareButton({
    bool active = false,
    int delay = 0,
    String imageUrl,
    Widget icon,
    String name,
    Function onTap,
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
            elevation: active ? 4.0 : 0.0,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide.none,
            ),
            child: InkWell(
              onTap: prefilledInputs ? showPrefilledAlert : onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: active ? 0.8 : 0.3,
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
                  if (active)
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: ClipOval(
                        child: Material(
                          color: stateColors.primary,
                          child: SizedBox(
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nameCardInput() {
    final referenceName = DataQuoteInputs.reference.name;
    final subtitleString =
        referenceName.isNotEmpty ? referenceName : tapToEditStr;

    return InputCard(
      width: 250.0,
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 20.0,
      ),
      titleString: 'Name',
      icon: Icon(UniconsLine.user),
      subtitleString: subtitleString,
      onTap: () async {
        await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => nameInput(),
        );

        setState(() {});
      },
    );
  }

  Widget nameInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.reference.name;

    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Name",
                  subTitle: "Suggestions will show when you'll start typing",
                ),
                StatefulBuilder(builder: (context, childSetState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: TextField(
                          autofocus: true,
                          controller: textController,
                          focusNode: textFocusNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            icon: Icon(UniconsLine.user),
                            labelText: "e.g. 1984, Interstellar",
                            alignLabelWithHint: true,
                          ),
                          minLines: 1,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          onChanged: (newValue) =>
                              onNameChanged(newValue, childSetState),
                          onSubmitted: (newValue) {
                            context.router.pop();
                          },
                        ),
                      ),
                      if (isLoadingSuggestions)
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: LinearProgressIndicator(),
                        ),
                      FormActionInputs(
                        onCancel: () {
                          DataQuoteInputs.reference.name = '';
                          textController.clear();
                          textFocusNode.requestFocus();
                        },
                      ),
                      suggestions(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget primaryTypeCardInput() {
    final primaryType = DataQuoteInputs.reference.type.primary;
    final subtitleString = primaryType.isNotEmpty ? primaryType : tapToEditStr;

    final _onTap = prefilledInputs
        ? showPrefilledAlert
        : () async {
            await showCupertinoModalBottomSheet(
                context: context,
                builder: (context) {
                  return primaryTypeInput();
                });

            setState(() {});
          };

    return InputCard(
      width: 300.0,
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 10.0,
      ),
      titleString: 'Primary type (e.g. TV series)',
      icon: Icon(UniconsLine.circle),
      subtitleString: subtitleString,
      onTap: _onTap,
    );
  }

  Widget primaryTypeInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.reference.type.primary;

    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Primary type",
                  subTitle: "Main category",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    focusNode: textFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.circle),
                      labelText: "e.g. TV series, Book",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.reference.type.primary = newValue;
                    },
                    onSubmitted: (_) => context.router.pop(),
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    DataQuoteInputs.reference.type.primary = '';
                    textController.clear();
                    textFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget releaseDate() {
    final selectedDate = DataQuoteInputs.reference.release.original;
    final beforeJC = DataQuoteInputs.reference.release.beforeJC ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: prefilledInputs
                ? showPrefilledAlert
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.input,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(0),
                      lastDate: DateTime.now(),
                    );

                    setState(() =>
                        DataQuoteInputs.reference.release.original = picked);
                  },
            icon: Icon(Icons.calendar_today),
            label: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(selectedDate != null
                  ? selectedDate.toLocal().toString().split(' ')[0]
                  : 'Select a new date'),
            ),
          ),
          Container(
            width: 300.0,
            padding: const EdgeInsets.only(top: 12.0),
            child: CheckboxListTile(
              title: Text('Before J-C (Jesus Christ)',
                  style: TextStyle(fontSize: 16)),
              subtitle:
                  Text('(e.g. year -500)', style: TextStyle(fontSize: 13)),
              value: beforeJC,
              onChanged: prefilledInputs
                  ? null
                  : (newValue) {
                      setState(() => DataQuoteInputs
                          .reference.release.beforeJC = newValue);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget secondaryTypeCardInput() {
    final secondaryType = DataQuoteInputs.reference.type.secondary;
    final subtitleString =
        secondaryType.isNotEmpty ? secondaryType : tapToEditStr;

    Function _onTap;

    if (prefilledInputs) {
      _onTap = showPrefilledAlert;
    } else {
      _onTap = () async {
        await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) {
              return secondaryTypeInput();
            });

        setState(() {});
      };
    }

    return InputCard(
      width: 300.0,
      padding: const EdgeInsets.only(
        bottom: 20.0,
      ),
      titleString: 'Secondary type (e.g. Thriller)',
      icon: Icon(UniconsLine.pentagon),
      subtitleString: subtitleString,
      onTap: _onTap,
    );
  }

  Widget secondaryTypeInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.reference.type.secondary;

    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Secondary type",
                  subTitle: "Sub-category bringing more precision",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    focusNode: textFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.pentagon),
                      labelText: "e.g. Thriller, Drama",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.reference.type.secondary = newValue;
                    },
                    onSubmitted: (_) => context.router.pop(),
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    DataQuoteInputs.reference.type.secondary = '';
                    textController.clear();
                    textFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget suggestions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: referencesSuggestions.map((referenceSuggestion) {
          ImageProvider image;
          final imageUrl = referenceSuggestion.reference.urls.image;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            image = NetworkImage(imageUrl);
          } else {
            image = AssetImage('assets/images/reference.png');
          }

          return ListTile(
            onTap: () {
              DataQuoteInputs.reference = referenceSuggestion.reference;
              prefilledInputs = true;
              tapToEditStr = '-';
              Navigator.of(context).pop();
            },
            title: Text(referenceSuggestion.getTitle()),
            contentPadding: const EdgeInsets.all(8.0),
            leading: Card(
              child: Image(
                image: image,
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget summaryCardInput() {
    final summary = DataQuoteInputs.reference.summary;
    final subtitleString = summary.isNotEmpty ? summary : tapToEditStr;

    Function _onTap;

    if (prefilledInputs) {
      _onTap = showPrefilledAlert;
    } else {
      _onTap = () async {
        await showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return summaryInput();
            });

        setState(() {});
      };
    }

    return InputCard(
      width: 300.0,
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 40.0,
      ),
      titleString: 'Summary',
      icon: Icon(UniconsLine.subject),
      subtitleString: subtitleString,
      onTap: _onTap,
    );
  }

  Widget summaryInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.reference.summary;

    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Summary",
                  subTitle: "It can be the first Wikipedia paragraph",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    focusNode: textFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.subject),
                      labelText: "Once upon a time...",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.reference.summary = newValue;
                    },
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    DataQuoteInputs.reference.summary = '';
                    textController.clear();
                    textFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onNameChanged(String newValue, childSetState) {
    if (widget.editMode != EditDataMode.editReference &&
        DataQuoteInputs.reference.id.isNotEmpty &&
        DataQuoteInputs.reference.name != newValue) {
      prefilledInputs = false;
      DataQuoteInputs.clearReference();
    }

    DataQuoteInputs.reference.name = newValue;
    tapToEditStr = 'Tap to edit';

    if (searchTimer != null && searchTimer.isActive) {
      searchTimer.cancel();
    }

    searchTimer = Timer(1.seconds, () async {
      setState(() {
        isLoadingSuggestions = true;
        referencesSuggestions.clear();
      });

      final query = algolia.index('references').search(newValue);
      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        childSetState(() => isLoadingSuggestions = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final suggestion = ReferenceSuggestion.fromJSON(data);
        referencesSuggestions.add(suggestion);
      }

      childSetState(() => isLoadingSuggestions = false);
    });
  }

  void showAvatarDialog() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        linkInputController.text = DataQuoteInputs.reference.urls.image;

        return Scaffold(
          body: ListView(
            physics: ClampingScrollPhysics(),
            controller: ModalScrollController.of(context),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 40.0,
                  right: 40.0,
                  top: 40.0,
                  bottom: 20.0,
                ),
                child: SizedBox(
                  width: 250.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SheetHeader(
                        title: "Reference illustration",
                        subTitle: "Enter a valid URL",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                      ),
                      TextField(
                        autofocus: true,
                        controller: linkInputController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "https://example.com/image.png",
                        ),
                        onChanged: (newValue) {
                          tempImgUrl = newValue;
                        },
                        onSubmitted: (newValue) {
                          setState(() {
                            DataQuoteInputs.reference.urls.image = tempImgUrl;
                          });

                          context.router.pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              FormActionInputs(
                adaptivePadding: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                ),
                onCancel: () {
                  linkInputController.clear();
                  tempImgUrl = '';
                  DataQuoteInputs.reference.urls.image = '';
                },
                onValidate: () {
                  setState(() {
                    DataQuoteInputs.reference.urls.image = tempImgUrl;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showLinkInputSheet({
    String labelText = '',
    String initialValue = '',
    Function onSave,
  }) {
    linkInputController.clear();

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        if (linkInputController.text.isEmpty) {
          linkInputController.text = initialValue;
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetHeader(
                  title: "Link",
                  subTitle: "Enter a valid URL",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: linkInputController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: labelText,
                      icon: Icon(Icons.link),
                    ),
                    onChanged: (newValue) {
                      initialValue = newValue;
                    },
                    onSubmitted: (newValue) {
                      onSave(initialValue);
                      context.router.pop();
                    },
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    linkInputController.clear();
                    initialValue = '';
                  },
                  onValidate: () => onSave(initialValue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showPrefilledAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Opacity(
              opacity: 0.6,
              child: Text(
                "Because you selected an exisisting reference, "
                "you cannot edit this reference's fields. "
                "Reference's fields have been filled out for you for available data.",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            titlePadding: const EdgeInsets.all(20.0),
          );
        });
  }
}
