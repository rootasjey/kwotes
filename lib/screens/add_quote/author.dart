import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/circle_button.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddQuoteAuthor extends StatefulWidget {
  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  String tempImgUrl = '';
  final beginY = 10.0;

  final affiliateUrlController = TextEditingController();
  final amazonUrlController   = TextEditingController();
  final facebookUrlController = TextEditingController();
  final nameController        = TextEditingController();
  final instaController       = TextEditingController();
  final jobController         = TextEditingController();
  final summaryController     = TextEditingController();
  final twitchUrlController   = TextEditingController();
  final twitterUrlController  = TextEditingController();
  final websiteUrlController  = TextEditingController();
  final wikiUrlController     = TextEditingController();
  final youtubeUrlController  = TextEditingController();

  final linkInputController = TextEditingController();

  final nameFocusNode = FocusNode();
  final jobFocusNode = FocusNode();
  final summaryFocusNode = FocusNode();

  @override
  void initState() {
    setState(() {
      affiliateUrlController.text  = AddQuoteInputs.author.urls.affiliate;
      amazonUrlController.text    = AddQuoteInputs.author.urls.amazon;
      facebookUrlController.text  = AddQuoteInputs.author.urls.facebook;
      nameController.text         = AddQuoteInputs.author.name;
      jobController.text          = AddQuoteInputs.author.job;
      instaController.text        = AddQuoteInputs.author.urls.instagram;
      summaryController.text      = AddQuoteInputs.author.summary;
      twitchUrlController.text    = AddQuoteInputs.author.urls.twitch;
      twitterUrlController.text   = AddQuoteInputs.author.urls.twitter;
      websiteUrlController.text   = AddQuoteInputs.author.urls.website;
      wikiUrlController.text      = AddQuoteInputs.author.urls.wikipedia;
      youtubeUrlController.text   = AddQuoteInputs.author.urls.youtube;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.0,
      child: Column(
        children: <Widget>[
          avatar(),
          nameCardInput(),
          jobCardInput(),
          clearButton(),
          FadeInY(
            delay: 0.6,
            beginY: beginY,
            child: summaryCardInput(),
          ),
          FadeInY(
            delay: 0.8,
            beginY: beginY,
            child: links(),
          ),
        ],
      ),
    );
  }

  Widget avatar() {
    return Material(
      elevation: AddQuoteInputs.author.urls.image.isEmpty ? 0.0 : 4.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: AddQuoteInputs.author.urls.image.isNotEmpty
          ? Ink.image(
              image: NetworkImage(AddQuoteInputs.author.urls.image),
              fit: BoxFit.cover,
              width: 150.0,
              height: 150.0,
              child: InkWell(
                onTap: () => showAvatarDialog(),
              ),
            )
          : Ink(
              width: 150.0,
              height: 150.0,
              child: InkWell(
                onTap: () => showAvatarDialog(),
                child: CircleAvatar(
                  child: Icon(
                    Icons.add,
                    size: 50.0,
                    color: stateColors.primary,
                  ),
                  backgroundColor: Colors.black12,
                  radius: 60.0,
                ),
              )),
    );
  }

  Widget clearButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: FlatButton.icon(
        onPressed: () {
          AddQuoteInputs.clearAuthor();

          amazonUrlController.clear();
          facebookUrlController.clear();
          jobController.clear();
          nameController.clear();
          summaryController.clear();
          twitchUrlController.clear();
          twitterUrlController.clear();
          websiteUrlController.clear();
          wikiUrlController.clear();
          youtubeUrlController.clear();

          setState(() {});

          nameFocusNode.requestFocus();
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

  Widget links() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        children: <Widget>[
          linkCircleButton(
            delay: 1.0,
            name: 'Website',
            active: AddQuoteInputs.author.urls.website.isNotEmpty,
            imageUrl: 'assets/images/world-globe.png',
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Website',
                  initialValue: AddQuoteInputs.author.urls.website,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.website = inputUrl;
                    });
                  });
            },
          ),
          Observer(
            builder: (_) {
              return linkCircleButton(
                delay: 1.2,
                name: 'Wikipedia',
                active: AddQuoteInputs.author.urls.wikipedia.isNotEmpty,
                imageUrl: 'assets/images/wikipedia-${stateColors.iconExt}.png',
                onTap: () {
                  showLinkInputSheet(
                      labelText: 'Wikipedia',
                      initialValue: AddQuoteInputs.author.urls.wikipedia,
                      onSave: (String inputUrl) {
                        setState(() {
                          AddQuoteInputs.author.urls.wikipedia = inputUrl;
                        });
                      });
                },
              );
            },
          ),
          linkCircleButton(
            delay: 1.4,
            name: 'Amazon',
            imageUrl: 'assets/images/amazon.png',
            active: AddQuoteInputs.author.urls.amazon.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Amazon',
                  initialValue: AddQuoteInputs.author.urls.amazon,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.amazon = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 1.6,
            name: 'Facebook',
            imageUrl: 'assets/images/facebook.png',
            active: AddQuoteInputs.author.urls.facebook.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Facebook',
                  initialValue: AddQuoteInputs.author.urls.facebook,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.facebook = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 1.7,
            name: 'Instagram',
            imageUrl: 'assets/images/instagram.png',
            active: AddQuoteInputs.author.urls.instagram.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Instagram',
                  initialValue: AddQuoteInputs.author.urls.instagram,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.instagram = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 1.8,
            name: 'Netflix',
            imageUrl: 'assets/images/netflix.png',
            active: AddQuoteInputs.author.urls.netflix.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Netflix',
                  initialValue: AddQuoteInputs.author.urls.netflix,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.netflix = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 2.0,
            name: 'Prime Video',
            imageUrl: 'assets/images/prime-video.png',
            active: AddQuoteInputs.author.urls.primeVideo.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Prime Video',
                  initialValue: AddQuoteInputs.author.urls.primeVideo,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.primeVideo = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 2.2,
            name: 'Twitch',
            imageUrl: 'assets/images/twitch.png',
            active: AddQuoteInputs.author.urls.twitch.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Twitch',
                  initialValue: AddQuoteInputs.author.urls.twitch,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.twitch = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 2.4,
            name: 'Twitter',
            imageUrl: 'assets/images/twitter.png',
            active: AddQuoteInputs.author.urls.twitter.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'Twitter',
                  initialValue: AddQuoteInputs.author.urls.twitter,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.twitter = inputUrl;
                    });
                  });
            },
          ),
          linkCircleButton(
            delay: 2.6,
            name: 'YouTube',
            imageUrl: 'assets/images/youtube.png',
            active: AddQuoteInputs.author.urls.youtube.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                  labelText: 'YouTube',
                  initialValue: AddQuoteInputs.author.urls.youtube,
                  onSave: (String inputUrl) {
                    setState(() {
                      AddQuoteInputs.author.urls.youtube = inputUrl;
                    });
                  });
            },
          ),
        ],
      ),
    );
  }

  Widget linkCircleButton({
    bool active = false,
    double delay = 0.0,
    String imageUrl,
    String name,
    Function onTap,
  }) {
    return FadeInX(
      beginX: 50.0,
      delay: delay,
      child: Tooltip(
        message: name,
        child: Material(
          elevation: active ? 4.0 : 0.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.black12,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                imageUrl,
                width: 30.0,
                color: stateColors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nameCardInput() {
    final authorName = AddQuoteInputs.author.name;

    return Container(
      width: 250.0,
      padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: () async {
            await showCupertinoModalBottomSheet(
                context: context,
                builder: (context, scrollController) {
                  return nameInput();
                });

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      authorName != null && authorName.isNotEmpty
                          ? authorName
                          : 'Tap to edit',
                    ),
                  ],
                ),
              ),
              Icon(Icons.person),
            ]),
          ),
        ),
      ),
    );
  }

  Widget nameInput({ScrollController scrollController}) {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleButton(
                      onTap: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        size: 20.0,
                        color: stateColors.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Opacity(
                              opacity: 0.6,
                              child: Text(
                                "Name",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "Auto suggestions will show when you'll start typing.",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: nameController,
                    focusNode: nameFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person_outline),
                      labelText: "e.g. Freud, Aristote",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      AddQuoteInputs.author.name = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 40.0,
                  ),
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          AddQuoteInputs.author.name = '';
                          nameController.clear();
                          nameFocusNode.requestFocus();
                        },
                        icon: Opacity(
                          opacity: 0.6,
                          child: Icon(Icons.clear),
                        ),
                        label: Opacity(
                          opacity: 0.8,
                          child: Text(
                            'Clear input',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          primary: stateColors.foreground,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Opacity(
                          opacity: 0.6,
                          child: Icon(Icons.check),
                        ),
                        label: Opacity(
                          opacity: 0.8,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget jobCardInput() {
    final job = AddQuoteInputs.author.job;

    return SizedBox(
      width: 250.0,
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: () async {
            await showCupertinoModalBottomSheet(
                context: context,
                builder: (context, scrollController) {
                  return jobInput();
                });

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Job',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      job != null && job.isNotEmpty ? job : 'Tap to edit',
                    ),
                  ],
                ),
              ),
              Icon(Icons.work),
            ]),
          ),
        ),
      ),
    );
  }

  Widget jobInput({ScrollController scrollController}) {
    return Scaffold(
      body: ListView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleButton(
                    onTap: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 20.0,
                      color: stateColors.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Opacity(
                            opacity: 0.6,
                            child: Text(
                              "Job",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "This author job or role in real life or in the artistic material (film, book, ...).",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: TextField(
                  autofocus: true,
                  controller: jobController,
                  focusNode: jobFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    icon: Icon(Icons.work),
                    labelText: "e.g. Housekeeper, Lawyer, Student, Teacher",
                    alignLabelWithHint: true,
                  ),
                  minLines: 1,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  onChanged: (newValue) {
                    AddQuoteInputs.author.job = newValue;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 40.0,
                ),
                child: Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        AddQuoteInputs.author.job = '';
                        jobController.clear();
                        jobFocusNode.requestFocus();
                      },
                      icon: Opacity(
                        opacity: 0.6,
                        child: Icon(Icons.clear),
                      ),
                      label: Opacity(
                        opacity: 0.6,
                        child: Text(
                          'Clear input',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        primary: stateColors.foreground,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
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
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget summaryCardInput() {
    final summary = AddQuoteInputs.author.summary;

    return Container(
      width: 300.0,
      padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: () async {
            await showCupertinoModalBottomSheet(
                context: context,
                builder: (context, scrollController) {
                  return summaryInput();
                });

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      summary != null && summary.isNotEmpty
                          ? summary
                          : 'Tap to edit',
                    ),
                  ],
                ),
              ),
              Icon(Icons.short_text),
            ]),
          ),
        ),
      ),
    );
  }

  Widget summaryInput({ScrollController scrollController}) {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleButton(
                      onTap: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        size: 20.0,
                        color: stateColors.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Opacity(
                              opacity: 0.6,
                              child: Text(
                                "Summary",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "Write a short summary about this author. It can be the first Wikipedia paragraph.",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: TextField(
                    autofocus: true,
                    controller: summaryController,
                    focusNode: summaryFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      labelText: "Once upon a time...",
                      alignLabelWithHint: true,
                    ),
                    minLines: 1,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    onChanged: (newValue) {
                      AddQuoteInputs.author.summary = newValue;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 40.0,
                  ),
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          AddQuoteInputs.author.summary = '';
                          summaryController.clear();
                          summaryFocusNode.requestFocus();
                        },
                        icon: Opacity(
                          opacity: 0.6,
                          child: Icon(Icons.clear),
                        ),
                        label: Opacity(
                          opacity: 0.6,
                          child: Text(
                            'Clear input',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          primary: stateColors.foreground,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
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
                ),
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

  void showAvatarDialog() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context, scrollController) {
          return Scaffold(
            body: ListView(
              physics: ClampingScrollPhysics(),
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: SizedBox(
                    width: 250.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleButton(
                              onTap: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                size: 20.0,
                                color: stateColors.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        "Author illustration",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "You can either provide an online link or upload a new picture.",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                        ),
                        TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                AddQuoteInputs.author.urls.image.length > 0
                                    ? AddQuoteInputs.author.urls.image
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'CANCEL',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            AddQuoteInputs.author.urls.image = tempImgUrl;
                          });

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
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
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String inputUrl;
        linkInputController.text = initialValue;

        return Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 250.0,
                child: TextField(
                  autofocus: true,
                  controller: linkInputController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: labelText,
                    icon: Icon(Icons.link),
                  ),
                  onChanged: (newValue) {
                    inputUrl = newValue;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40.0,
                  right: 10.0,
                ),
                child: RaisedButton(
                  onPressed: onSave != null
                      ? () {
                          Navigator.pop(context);
                          onSave(inputUrl);
                        }
                      : null,
                  color: stateColors.primary,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              )
            ],
          ),
        );
      },
    );
  }
}
