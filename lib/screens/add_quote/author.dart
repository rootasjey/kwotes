import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/form_action_inputs.dart';
import 'package:figstyle/components/input_card.dart';
import 'package:figstyle/components/sheet_header.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/reference_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/author_suggestion.dart';
import 'package:figstyle/utils/search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class AddQuoteAuthor extends StatefulWidget {
  /// Gives information on data type we're editing
  /// on [addquote/author] page.
  /// e.g. if we're editing an author withing a quote
  /// or a published author (indepeendently of other data).
  final EditAuthorMode editMode;

  const AddQuoteAuthor({
    Key key,
    this.editMode = EditAuthorMode.addQuote,
  }) : super(key: key);

  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  bool prefilledInputs = false;
  bool isLoadingSuggestions = false;

  final double beginY = 10.0;

  TextEditingController cityController;
  TextEditingController countryController;
  TextEditingController linkInputController;
  TextEditingController textController;

  FocusNode textFocusNode;
  FocusNode cityFocusNode;
  FocusNode countryFocusNode;

  List<AuthorSuggestion> authorsSuggestions = [];
  List<ReferenceSuggestion> referencesSuggestions = [];

  String tapToEditStr = 'Tap to edit';
  String tempImgUrl = '';

  Timer searchTimer;

  @override
  void initState() {
    super.initState();
    initFocusNodes();
    initInputs();

    setState(() {
      prefilledInputs = DataQuoteInputs.author.id.isNotEmpty &&
          widget.editMode == EditAuthorMode.addQuote;
    });
  }

  @override
  void dispose() {
    searchTimer?.cancel();
    disposeInputs();
    disposeFocusNodes();
    super.dispose();
  }

  void initFocusNodes() {
    textFocusNode = FocusNode();
    cityFocusNode = FocusNode();
    countryFocusNode = FocusNode();
  }

  void initInputs() {
    cityController = TextEditingController();
    countryController = TextEditingController();
    linkInputController = TextEditingController();
    textController = TextEditingController();

    textController.text = DataQuoteInputs.author.name;
    cityController.text = DataQuoteInputs.author.born.city;
    countryController.text = DataQuoteInputs.author.born.country;
  }

  void disposeFocusNodes() {
    textFocusNode.dispose();
    cityFocusNode.dispose();
    countryFocusNode.dispose();
  }

  void disposeInputs() {
    textController.dispose();
    cityController.dispose();
    countryController.dispose();
    linkInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DataQuoteInputs.isEditingPubQuote &&
        DataQuoteInputs.author.id.isNotEmpty) {
      return editPubQuoteView();
    }

    return normalEditView();
  }

  Widget authorSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: authorsSuggestions.map((authorSuggestion) {
          ImageProvider image;
          final imageUrl = authorSuggestion.author.urls.image;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            image = NetworkImage(imageUrl);
          } else {
            image = AssetImage('assets/images/user-m.png');
          }

          return ListTile(
            onTap: () => onTapNameSuggestions(authorSuggestion),
            title: Text(authorSuggestion.getTitle()),
            contentPadding: const EdgeInsets.all(8.0),
            leading: Material(
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
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

  Widget avatar() {
    final imageUrl = DataQuoteInputs.author.urls.image;
    const size = 150.0;

    final _onTap =
        prefilledInputs ? showPrefilledAlert : () => showAvatarDialog();

    Widget imageChild;

    if (imageUrl.isEmpty) {
      imageChild = Ink(
        width: size,
        height: size,
        child: InkWell(
          onTap: _onTap,
          child: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Icon(
                UniconsLine.plus,
                size: 50.0,
                color: stateColors.primary,
              ),
            ),
            backgroundColor: Colors.black12,
            radius: 60.0,
          ),
        ),
      );
    } else {
      imageChild = Ink.image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        width: size,
        height: size,
        child: InkWell(
          onTap: _onTap,
        ),
      );
    }

    return Material(
      elevation: imageUrl.isEmpty ? 0.0 : 4.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: imageChild,
    );
  }

  Widget bornAndDeathCards() {
    final born = DataQuoteInputs.author.born;
    final death = DataQuoteInputs.author.death;

    double spacing = 20.0;
    double width = 150.0;

    String tapToEditLocalStr = tapToEditStr;

    if (MediaQuery.of(context).size.width < 600.0) {
      spacing = 0.0;
      width = 120.0;
      tapToEditLocalStr = 'Edit';
    }

    final bornStr = born != null && born.date != null
        ? born.date.toLocal().toString().split(' ')[0]
        : tapToEditLocalStr;

    final deathStr = death != null && death.date != null
        ? death.date.toLocal().toString().split(' ')[0]
        : tapToEditLocalStr;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          InputCard(
            elevation: 1.0,
            width: width,
            titleString: 'Born',
            subtitleString: bornStr,
            padding: EdgeInsets.zero,
            icon: Icon(UniconsLine.play),
            onTap: prefilledInputs
                ? showPrefilledAlert
                : () async {
                    await showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return bornInput(
                            scrollController: ModalScrollController.of(context),
                          );
                        });

                    setState(() {});
                  },
          ),
          InputCard(
            elevation: 1.0,
            width: width,
            titleString: 'Death',
            subtitleString: deathStr,
            padding: EdgeInsets.zero,
            icon: Icon(UniconsLine.square_shape),
            onTap: prefilledInputs
                ? showPrefilledAlert
                : () async {
                    await showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return deathInput();
                        });

                    setState(() {});
                  },
          ),
        ],
      ),
    );
  }

  Widget bornInput({ScrollController scrollController}) {
    cityController.text = DataQuoteInputs.author.born.city;
    countryController.text = DataQuoteInputs.author.born.country;

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
                  title: "Born",
                  subTitle: "When and where this author was born?",
                ),
                StatefulBuilder(builder: (context, childSetState) {
                  var selectedDate = DataQuoteInputs.author.born.date;

                  return Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialEntryMode: DatePickerEntryMode.input,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(0),
                              lastDate: DateTime.now(),
                            );

                            childSetState(() =>
                                DataQuoteInputs.author.born.date = picked);
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Icon(UniconsLine.calender),
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              selectedDate != null
                                  ? selectedDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                  : 'Select a new date',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 400.0,
                          child: CheckboxListTile(
                            title: Text('Before J-C (Jesus Christ)'),
                            subtitle: Text('(e.g. year -500)'),
                            value: DataQuoteInputs.author.born.beforeJC,
                            onChanged: (newValue) {
                              childSetState(() {
                                DataQuoteInputs.author.born.beforeJC = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: TextField(
                    autofocus: true,
                    controller: countryController,
                    focusNode: countryFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.map),
                      labelText: "Country (e.g. Italy)",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.author.born.country = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 32.0,
                  ),
                  child: TextField(
                    controller: cityController,
                    focusNode: cityFocusNode,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.map_marker),
                      labelText: "City (e.g. Rome)",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.author.born.city = newValue;
                    },
                    onSubmitted: (_) => context.router.pop(),
                  ),
                ),
                FormActionInputs(
                  cancelTextString: 'Clear inputs',
                  onCancel: () {
                    DataQuoteInputs.author.born.city = '';
                    DataQuoteInputs.author.born.country = '';
                    DataQuoteInputs.author.born.date = null;

                    cityController.clear();
                    countryController.clear();
                    cityFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget clearButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: FlatButton.icon(
        onPressed: () {
          DataQuoteInputs.clearAuthor();
          textController.clear();
          authorsSuggestions.clear();

          prefilledInputs = false;
          tapToEditStr = 'Tap to edit';
          isLoadingSuggestions = false;

          setState(() {});

          textFocusNode.requestFocus();
        },
        icon: Opacity(opacity: 0.6, child: Icon(Icons.clear)),
        label: Opacity(
          opacity: 0.6,
          child: Text(
            'Clear all inputs',
          ),
        ),
      ),
    );
  }

  Widget deathInput({ScrollController scrollController}) {
    cityController.text = DataQuoteInputs.author.death.city;
    countryController.text = DataQuoteInputs.author.death.country;

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
                  title: "Death",
                  subTitle: "When and where this author died?",
                ),
                StatefulBuilder(builder: (context, childSetState) {
                  final selectedDate = DataQuoteInputs.author.death.date;
                  return Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialEntryMode: DatePickerEntryMode.input,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(0),
                              lastDate: DateTime.now(),
                            );

                            childSetState(() =>
                                DataQuoteInputs.author.death.date = picked);
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(selectedDate != null
                                ? selectedDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]
                                : 'Select a new date'),
                          ),
                        ),
                        SizedBox(
                          width: 400.0,
                          child: CheckboxListTile(
                            title: Text('Before J-C (Jesus Christ)'),
                            subtitle: Text('(e.g. year -500)'),
                            value: DataQuoteInputs.author.death.beforeJC,
                            onChanged: (newValue) {
                              childSetState(() => DataQuoteInputs
                                  .author.death.beforeJC = newValue);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: TextField(
                    autofocus: true,
                    controller: countryController,
                    focusNode: countryFocusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.map),
                      labelText: "Country (e.g. Italy)",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.author.death.country = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 32.0,
                  ),
                  child: TextField(
                    controller: cityController,
                    focusNode: cityFocusNode,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.map_marker),
                      labelText: "City (e.g. Rome)",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.author.death.city = newValue;
                    },
                    onSubmitted: (_) => context.router.pop(),
                  ),
                ),
                FormActionInputs(
                  cancelTextString: 'Clear inputs',
                  onCancel: () {
                    DataQuoteInputs.author.death.city = '';
                    DataQuoteInputs.author.death.country = '';
                    DataQuoteInputs.author.death.date = null;

                    cityController.clear();
                    countryController.clear();
                    cityFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget normalEditView() {
    return Container(
      width: 600.0,
      child: Column(
        children: <Widget>[
          avatar(),
          nameCardInput(),
          jobCardInput(),
          clearButton(),
          bornAndDeathCards(),
          summaryCardInput(),
          fictionalCharacterBox(),
          referenceNameCardInput(),
          links(),
        ],
      ),
    );
  }

  Widget existingDataCard() {
    final authorName = DataQuoteInputs.author.name;

    return SizedBox(
      height: 150.0,
      child: Row(
        children: [
          InputCard(
            width: 250.0,
            titleString: 'Author',
            icon: Icon(UniconsLine.image),
            subtitleString: authorName,
            onTap: () {
              context.router.root.push(
                AuthorsDeepRoute(
                  children: [
                    AuthorPageRoute(
                      authorId: DataQuoteInputs.author.id,
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
                      textController.text = authorName ?? '';
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
                  DataQuoteInputs.clearAuthor();
                });
              },
              color: stateColors.deletion,
              icon: Icon(UniconsLine.times),
            ),
          ),
        ],
      ),
    );
  }

  Widget fictionalCharacterBox() {
    return SizedBox(
      width: 400.0,
      child: CheckboxListTile(
        title: Text('is fictional?'),
        subtitle: Text(
          "If true, a reference's id property "
          "will be added to this author.",
        ),
        value: DataQuoteInputs.author.isFictional,
        onChanged: onFictionalChanged,
      ),
    );
  }

  Widget jobCardInput() {
    final job = DataQuoteInputs.author.job;
    final isJobValid = job != null && job.isNotEmpty;

    return InputCard(
      titleString: 'Job',
      padding: EdgeInsets.zero,
      subtitleString: isJobValid ? job : tapToEditStr,
      icon: Icon(UniconsLine.bag),
      onTap: prefilledInputs
          ? showPrefilledAlert
          : () async {
              await showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return jobInput();
                  });

              setState(() {});
            },
    );
  }

  Widget jobInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.author.job;

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
                  title: "Job",
                  subTitle: "Job or role in real life or "
                      "in the artistic material",
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    focusNode: textFocusNode,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(UniconsLine.bag),
                      labelText: "e.g. Housekeeper, Lawyer, Student, Teacher",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      DataQuoteInputs.author.job = newValue;
                    },
                    onSubmitted: (_) => context.router.pop(),
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    DataQuoteInputs.author.job = '';
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

  Widget links() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 54.0,
        bottom: 80.0,
      ),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        children: <Widget>[
          linkCircleButton(
            delay: 100,
            name: 'Website',
            icon: Icon(
              UniconsLine.globe,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.website?.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Website',
                initialValue: DataQuoteInputs.author.urls.website,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.website = inputUrl;
                  });
                },
              );
            },
          ),
          Observer(
            builder: (_) {
              return linkCircleButton(
                delay: 200,
                name: 'Wikipedia',
                icon: FaIcon(
                  FontAwesomeIcons.wikipediaW,
                  color: stateColors.primary.withOpacity(0.6),
                ),
                active: DataQuoteInputs.author.urls.wikipedia.isNotEmpty,
                onTap: () {
                  showLinkInputSheet(
                    labelText: 'Wikipedia',
                    initialValue: DataQuoteInputs.author.urls.wikipedia,
                    onSave: (String inputUrl) {
                      setState(() {
                        DataQuoteInputs.author.urls.wikipedia = inputUrl;
                      });
                    },
                  );
                },
              );
            },
          ),
          linkCircleButton(
            delay: 300,
            name: 'Amazon',
            icon: Icon(
              UniconsLine.amazon,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.amazon.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Amazon',
                initialValue: DataQuoteInputs.author.urls.amazon,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.amazon = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 400,
            name: 'Facebook',
            icon: Icon(
              UniconsLine.facebook,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.facebook.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Facebook',
                initialValue: DataQuoteInputs.author.urls.facebook,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.facebook = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 500,
            name: 'Instagram',
            icon: Icon(
              UniconsLine.instagram,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.instagram.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Instagram',
                initialValue: DataQuoteInputs.author.urls.instagram,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.instagram = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 600,
            name: 'Netflix',
            icon: Image.asset(
              'assets/images/netflix.png',
              width: 20.0,
              height: 20.0,
              color: stateColors.primary,
            ),
            active: DataQuoteInputs.author.urls.netflix.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Netflix',
                initialValue: DataQuoteInputs.author.urls.netflix,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.netflix = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 700,
            name: 'Prime Video',
            icon: Icon(
              UniconsLine.video,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.primeVideo.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Prime Video',
                initialValue: DataQuoteInputs.author.urls.primeVideo,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.primeVideo = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 800,
            name: 'Twitch',
            icon: FaIcon(
              FontAwesomeIcons.twitch,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.twitch.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitch',
                initialValue: DataQuoteInputs.author.urls.twitch,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.twitch = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 900,
            name: 'Twitter',
            icon: Icon(
              UniconsLine.twitter,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.twitter.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitter',
                initialValue: DataQuoteInputs.author.urls.twitter,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.twitter = inputUrl;
                  });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 1000,
            name: 'YouTube',
            icon: Icon(
              UniconsLine.youtube,
              color: stateColors.primary.withOpacity(0.6),
            ),
            active: DataQuoteInputs.author.urls.youtube.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'YouTube',
                initialValue: DataQuoteInputs.author.urls.youtube,
                onSave: (String inputUrl) {
                  setState(() {
                    DataQuoteInputs.author.urls.youtube = inputUrl;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget linkCircleButton({
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
        child: Material(
          elevation: active ? 4.0 : 0.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: stateColors.softBackground,
          child: InkWell(
            onTap: prefilledInputs ? showPrefilledAlert : onTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: icon != null
                  ? icon
                  : Image.asset(
                      imageUrl,
                      width: 20.0,
                      height: 20.0,
                      color: active
                          ? stateColors.secondary
                          : stateColors.foreground,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nameCardInput() {
    final authorName = DataQuoteInputs.author.name;
    final isAuthorNameValid = authorName != null && authorName.isNotEmpty;

    return InputCard(
      titleString: 'Name',
      subtitleString: isAuthorNameValid ? authorName : tapToEditStr,
      icon: Icon(UniconsLine.user),
      onTap: () async {
        await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) {
              textController.text = isAuthorNameValid ? authorName : '';
              return nameInput();
            });

        setState(() {});
      },
    );
  }

  Widget nameInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.author.name;

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
                        padding: const EdgeInsets.only(top: 60.0),
                        child: TextField(
                          autofocus: true,
                          controller: textController,
                          focusNode: textFocusNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            icon: Icon(UniconsLine.user),
                            labelText: "e.g. Freud, Aristote",
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
                          DataQuoteInputs.author.name = '';
                          textController.clear();
                          textFocusNode.requestFocus();
                        },
                      ),
                      authorSuggestions(),
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

  /// Used when editing author.
  Widget referenceNameCardInput() {
    if (!DataQuoteInputs.author.isFictional ||
        !DataQuoteInputs.isEditingPubQuote) {
      return Container();
    }

    final referenceName = DataQuoteInputs.author.fromReference.name;
    final subtitleString =
        referenceName.isNotEmpty ? referenceName : tapToEditStr;

    return InputCard(
      width: 250.0,
      padding: const EdgeInsets.only(
        top: 16.0,
        // bottom: 20.0,
      ),
      titleString: 'Reference name',
      icon: Icon(UniconsLine.image),
      subtitleString: subtitleString,
      onTap: () async {
        textController.text = referenceName;
        await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => referenceNameInput(),
        );

        setState(() {});
      },
    );
  }

  /// Used when editing author.
  Widget referenceNameInput({ScrollController scrollController}) {
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
                  title: "Reference name",
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
                              onReferenceNameChanged(newValue, childSetState),
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
                      referenceSuggestions(),
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

  /// Used when editing author.
  Widget referenceSuggestions() {
    return Column(
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
            DataQuoteInputs.author.fromReference.id =
                referenceSuggestion.reference.id;

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
    );
  }

  Widget summaryCardInput() {
    final summary = DataQuoteInputs.author.summary;
    final summaryStr =
        summary != null && summary.isNotEmpty ? summary : tapToEditStr;

    return InputCard(
      titleString: 'Summary',
      subtitleString: summaryStr,
      width: 300.0,
      icon: Icon(UniconsLine.subject),
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      onTap: prefilledInputs
          ? showPrefilledAlert
          : () async {
              await showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return summaryInput();
                  });

              setState(() {});
            },
    );
  }

  Widget summaryInput({ScrollController scrollController}) {
    textController.text = DataQuoteInputs.author.summary;

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
                      DataQuoteInputs.author.summary = newValue;
                    },
                  ),
                ),
                FormActionInputs(
                  onCancel: () {
                    DataQuoteInputs.author.summary = '';
                    textController.clear();
                    textFocusNode.requestFocus();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add author',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            '3/5',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  void onNameChanged(String newValue, childSetState) {
    if (DataQuoteInputs.author.id.isNotEmpty &&
        DataQuoteInputs.author.name != newValue) {
      prefilledInputs = false;
      DataQuoteInputs.clearAuthor();
    }

    DataQuoteInputs.author.name = newValue;
    tapToEditStr = 'Tap to edit';

    if (searchTimer != null && searchTimer.isActive) {
      searchTimer.cancel();
    }

    searchTimer = Timer(1.seconds, () async {
      childSetState(() {
        isLoadingSuggestions = true;
        authorsSuggestions.clear();
      });

      final query = algolia.index('authors').search(newValue);
      final snapshot = await query.getObjects();

      if (snapshot.empty) {
        childSetState(() => isLoadingSuggestions = false);
        return;
      }

      for (final hit in snapshot.hits) {
        final data = hit.data;
        data['id'] = hit.objectID;

        final authorSuggestion = AuthorSuggestion.fromJSON(data);
        final fromReference = authorSuggestion.author.fromReference;

        if (fromReference != null &&
            fromReference.id != null &&
            fromReference.id.isNotEmpty) {
          try {
            final ref = await FirebaseFirestore.instance
                .collection('references')
                .doc(fromReference.id)
                .get();

            final refData = ref.data();
            refData['id'] = ref.id;

            authorSuggestion.parseReferenceJSON(refData);
          } catch (error) {}
        }

        authorsSuggestions.add(authorSuggestion);
      }

      childSetState(() => isLoadingSuggestions = false);
    });
  }

  void onFictionalChanged(bool isChecked) async {
    final isEditAuthorMode = widget.editMode == EditAuthorMode.editAuthor;

    if (prefilledInputs && !isEditAuthorMode) {
      return null;
    }

    if (isChecked && isEditAuthorMode) {
      await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) {
            textController.text = '';
            return referenceNameInput();
          });

      setState(() {
        DataQuoteInputs.author.isFictional =
            DataQuoteInputs.reference.id.isNotEmpty;

        DataQuoteInputs.author.fromReference.id = DataQuoteInputs.reference.id;
      });

      return;
    }

    if (!isChecked && isEditAuthorMode) {
      DataQuoteInputs.clearReference();

      setState(() {
        DataQuoteInputs.author.isFictional = isChecked;
      });

      return;
    }

    setState(() {
      DataQuoteInputs.author.isFictional = isChecked;
    });
  }

  /// Used when editing author.
  void onReferenceNameChanged(String newValue, childSetState) {
    DataQuoteInputs.reference.name = newValue;

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

        final referenceSuggestion = ReferenceSuggestion.fromJSON(data);
        referencesSuggestions.add(referenceSuggestion);
      }

      childSetState(() => isLoadingSuggestions = false);
    });
  }

  void onTapNameSuggestions(AuthorSuggestion authorSuggestion) {
    if (widget.editMode == EditAuthorMode.addQuote) {
      DataQuoteInputs.author = authorSuggestion.author;
      prefilledInputs = true;
      tapToEditStr = '-';

      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Can't perform this action",
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          children: <Widget>[
            Divider(
              color: stateColors.secondary,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "You can't select existing authors when already "
                  "editing one. Suggestions are show to avoid duplications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAvatarDialog() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) {
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
                          title: "Author illustration",
                          subTitle: "Enter a valid URL",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                        ),
                        TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                DataQuoteInputs.author.urls.image.length > 0
                                    ? DataQuoteInputs.author.urls.image
                                    : 'URL',
                          ),
                          onChanged: (newValue) {
                            tempImgUrl = newValue;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                FormActionInputs(
                  onCancel: context.router.pop,
                  cancelTextString: 'Cancel',
                  adaptivePadding: false,
                  padding: const EdgeInsets.only(
                    left: 40.0,
                    top: 20.0,
                  ),
                  onValidate: () {
                    setState(() {
                      DataQuoteInputs.author.urls.image = tempImgUrl;
                    });
                  },
                ),
              ],
            ),
          );
        });
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
                    onSubmitted: (_) {
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
                  onValidate: () {
                    onSave(initialValue);
                  },
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
              "Because you selected an exisisting author, "
              "you cannot edit this author's field. "
              "Author's fields have been filled out for you for available data.",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(20.0),
        );
      },
    );
  }
}
