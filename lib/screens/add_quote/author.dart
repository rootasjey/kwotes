import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';

class AddQuoteAuthor extends StatefulWidget {
  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  String tempImgUrl = '';
  final beginY      = 10.0;

  final affiliateUrlController  = TextEditingController();
  final amazonUrlController     = TextEditingController();
  final facebookUrlController   = TextEditingController();
  final nameController          = TextEditingController();
  final jobController           = TextEditingController();
  final summaryController       = TextEditingController();
  final twitchUrlController     = TextEditingController();
  final twitterUrlController    = TextEditingController();
  final websiteUrlController    = TextEditingController();
  final wikiUrlController       = TextEditingController();
  final youtubeUrlController    = TextEditingController();

  final linkInputController     = TextEditingController();

  final nameFocusNode           = FocusNode();

  @override
  void initState() {
    setState(() {
      affiliateUrlController.text   = AddQuoteInputs.author.urls.affiliate;
      amazonUrlController.text      = AddQuoteInputs.author.urls.amazon;
      facebookUrlController.text    = AddQuoteInputs.author.urls.facebook;
      nameController.text           = AddQuoteInputs.author.name;
      jobController.text            = AddQuoteInputs.author.job;
      summaryController.text        = AddQuoteInputs.author.summary;
      twitchUrlController.text      = AddQuoteInputs.author.urls.twitch;
      twitterUrlController.text     = AddQuoteInputs.author.urls.twitter;
      websiteUrlController.text     = AddQuoteInputs.author.urls.website;
      wikiUrlController.text        = AddQuoteInputs.author.urls.wikipedia;
      youtubeUrlController.text     = AddQuoteInputs.author.urls.youtube;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.0,
      child: Column(
        children: <Widget>[
          Wrap(
            spacing: 40.0,
            runSpacing: 40.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              avatar(),
              nameAndJob(),
            ],
          ),

          FadeInY(
            delay: 0.6,
            beginY: beginY,
            child: summaryField(),
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
      elevation: 1.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: AddQuoteInputs.author.urls.image.length > 0 ?
        Ink.image(
          image: NetworkImage(AddQuoteInputs.author.urls.image),
          fit: BoxFit.cover,
          width: 200.0,
          height: 200.0,
          child: InkWell(
            onTap: () => showAvatarDialog(),
          ),
        ) :
        Ink(
          width: 200.0,
          height: 200.0,
          child: InkWell(
            onTap: () => showAvatarDialog(),
            child: CircleAvatar(
              child: Icon(
                Icons.add,
                size: 50.0,
                color: stateColors.primary,
              ),
              backgroundColor: Colors.black12,
              radius: 80.0,
            ),
          )
        ),
    );
  }

  Widget clearButton() {
    return FlatButton.icon(
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
          'Clear all data',
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
                }
              );
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
                      }
                    );
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
                }
              );
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
                }
              );
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
                }
              );
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
                }
              );
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
                }
              );
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
                }
              );
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
                }
              );
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
          elevation: active
            ? 4.0
            : 0.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                imageUrl,
                width: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nameAndJob() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: nameController,
            autofocus: true,
            focusNode: nameFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Name',
              icon: Icon(Icons.person_outline),
            ),
            onChanged: (newValue) {
              AddQuoteInputs.author.name = newValue;
            },
          ),
        ),

        SizedBox(
          width: 200.0,
          child: TextField(
            controller: jobController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Job',
              icon: Icon(Icons.work),
            ),
            onChanged: (newValue) {
              AddQuoteInputs.author.job = newValue;
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: clearButton(),
        ),
      ],
    );
  }

  Widget summaryField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 100.0),
      child: TextField(
        controller: summaryController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          icon: Icon(Icons.edit),
          labelText: "Type author's summary there...",
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.all(Radius.circular(5.0)),
          ),
          content: Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              width: 250.0,
              height: 150.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Author image's URL",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AddQuoteInputs.author.urls.image.length > 0 ?
                        AddQuoteInputs.author.urls.image : 'URL',
                    ),
                    onChanged: (newValue) {
                      tempImgUrl = newValue;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
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
        );
      }
    );
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
                width: 300.0,
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
