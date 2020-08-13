import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/utils/language.dart';

class AddQuoteReference extends StatefulWidget {
  @override
  _AddQuoteReferenceState createState() => _AddQuoteReferenceState();
}

class _AddQuoteReferenceState extends State<AddQuoteReference> {
  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  String tempImgUrl = '';

  final nameFocusNode = FocusNode();

  final affiliateUrlController    = TextEditingController();
  final amazonUrlController       = TextEditingController();
  final facebookUrlController     = TextEditingController();
  final nameController            = TextEditingController();
  final netflixUrlController      = TextEditingController();
  final primaryTypeController     = TextEditingController();
  final primeVideoUrlController   = TextEditingController();
  final secondaryTypeController   = TextEditingController();
  final summaryController         = TextEditingController();
  final twitterUrlController      = TextEditingController();
  final twitchUrlController       = TextEditingController();
  final websiteUrlController      = TextEditingController();
  final wikiUrlController         = TextEditingController();
  final youtubeUrlController      = TextEditingController();

  final linkInputController       = TextEditingController();

  @override
  initState() {
    setState(() {
      affiliateUrlController.text   = AddQuoteInputs.reference.urls.affiliate;
      amazonUrlController.text      = AddQuoteInputs.reference.urls.amazon;
      facebookUrlController.text    = AddQuoteInputs.reference.urls.facebook;
      nameController.text           = AddQuoteInputs.reference.name;
      netflixUrlController.text     = AddQuoteInputs.reference.urls.netflix;
      primeVideoUrlController.text  = AddQuoteInputs.reference.urls.primeVideo;
      primaryTypeController.text    = AddQuoteInputs.reference.type.primary;
      secondaryTypeController.text  = AddQuoteInputs.reference.type.secondary;
      summaryController.text        = AddQuoteInputs.reference.summary;
      twitterUrlController.text     = AddQuoteInputs.reference.urls.twitter;
      twitchUrlController.text      = AddQuoteInputs.reference.urls.twitch;
      websiteUrlController.text     = AddQuoteInputs.reference.urls.website;
      wikiUrlController.text        = AddQuoteInputs.reference.urls.wikipedia;
      youtubeUrlController.text     = AddQuoteInputs.reference.urls.youtube;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          Wrap(
            children: <Widget>[
              avatar(),
              nameAndTypesFields(),
            ],
          ),

          FadeInY(
            delay: delay + (4 * delayStep),
            beginY: beginY,
            child: langAndSummary(),
          ),

          FadeInY(
            delay: delay + (5 * delayStep),
            beginY: beginY,
            child: links(),
          ),
        ],
      ),
    );
  }

  Widget clearButton() {
    return FlatButton.icon(
      onPressed: () {
        AddQuoteInputs.clearReference();

        amazonUrlController.clear();
        facebookUrlController.clear();
        nameController.clear();
        netflixUrlController.clear();
        primaryTypeController.clear();
        primeVideoUrlController.clear();
        secondaryTypeController.clear();
        summaryController.clear();
        twitchUrlController.clear();
        twitterUrlController.clear();
        websiteUrlController.clear();
        wikiUrlController.clear();
        youtubeUrlController.clear();

        setState(() {});

        nameFocusNode.requestFocus();
      },
      icon: Opacity(
        opacity: 0.6,
        child: Icon(Icons.clear),
      ),
      label: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear all data',
        ),
      ),
    );
  }

  Widget avatar() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30.0,
        right: 40.0,
      ),
      child: Card(
        child: AddQuoteInputs.reference.urls.image.length > 0 ?
          Ink.image(
            width: 200.0,
            height: 250.0,
            fit: BoxFit.cover,
            image: NetworkImage(AddQuoteInputs.reference.urls.image),
            child: InkWell(
              onTap: () => showImageDialog(),
            ),
          ) :
          SizedBox(
            width: 200.0,
            height: 250.0,
            child: InkWell(
              child: Opacity(
                opacity: .6,
                child: Icon(Icons.add, size: 50.0,)
              ),
              onTap: () => showImageDialog(),
            ),
          ),
      ),
    );
  }

  Widget langAndSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60.0,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 500,
            child: TextField(
              controller: summaryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                icon: Icon(Icons.edit),
                labelText: "Type reference's summary there...",
                alignLabelWithHint: true,
              ),
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                fontSize: 20.0,
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.summary = newValue;
              },
            ),
          ),

          Row(
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

              Padding(padding: const EdgeInsets.only(left: 20.0,),),

              DropdownButton<String>(
                value: AddQuoteInputs.reference.lang,
                iconEnabledColor: stateColors.primary,
                icon: Icon(Icons.language),
                style: TextStyle(
                  color: stateColors.primary,
                  fontSize: 20.0,
                ),
                onChanged: (newValue) {
                  setState(() {
                    AddQuoteInputs.reference.lang = newValue;
                  });
                },
                items: Language.available()
                  .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
              ),
            ],
          ),
        ],
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
            active: AddQuoteInputs.reference.urls.website.isNotEmpty,
            imageUrl: 'assets/images/world-globe.png',
            onTap: () {
              showLinkInputSheet(
                labelText: 'Website',
                initialValue: AddQuoteInputs.reference.urls.website,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.website = inputUrl;
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
                active: AddQuoteInputs.reference.urls.wikipedia.isNotEmpty,
                imageUrl: 'assets/images/wikipedia-${stateColors.iconExt}.png',
                onTap: () {
                    showLinkInputSheet(
                      labelText: 'Wikipedia',
                      initialValue: AddQuoteInputs.reference.urls.wikipedia,
                      onSave: (String inputUrl) {
                        setState(() {
                          AddQuoteInputs.reference.urls.wikipedia = inputUrl;
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
            active: AddQuoteInputs.reference.urls.amazon.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Amazon',
                initialValue: AddQuoteInputs.reference.urls.amazon,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.amazon = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 1.6,
            name: 'Facebook',
            imageUrl: 'assets/images/facebook.png',
            active: AddQuoteInputs.reference.urls.facebook.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Facebook',
                initialValue: AddQuoteInputs.reference.urls.facebook,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.facebook = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 1.8,
            name: 'Netflix',
            imageUrl: 'assets/images/netflix.png',
            active: AddQuoteInputs.reference.urls.netflix.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Netflix',
                initialValue: AddQuoteInputs.reference.urls.netflix,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.netflix = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 2.0,
            name: 'Prime Video',
            imageUrl: 'assets/images/prime-video.png',
            active: AddQuoteInputs.reference.urls.primeVideo.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Prime Video',
                initialValue: AddQuoteInputs.reference.urls.primeVideo,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.primeVideo = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 2.2,
            name: 'Twitch',
            imageUrl: 'assets/images/twitch.png',
            active: AddQuoteInputs.reference.urls.twitch.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitch',
                initialValue: AddQuoteInputs.reference.urls.twitch,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.twitch = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 2.4,
            name: 'Twitter',
            imageUrl: 'assets/images/twitter.png',
            active: AddQuoteInputs.reference.urls.twitter.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'Twitter',
                initialValue: AddQuoteInputs.reference.urls.twitter,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.twitter = inputUrl;
                  });
                }
              );
            },
          ),

          linkCircleButton(
            delay: 2.6,
            name: 'YouTube',
            imageUrl: 'assets/images/youtube.png',
            active: AddQuoteInputs.reference.urls.youtube.isNotEmpty,
            onTap: () {
              showLinkInputSheet(
                labelText: 'YouTube',
                initialValue: AddQuoteInputs.reference.urls.youtube,
                onSave: (String inputUrl) {
                  setState(() {
                    AddQuoteInputs.reference.urls.youtube = inputUrl;
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
              child: Image.network(
                imageUrl,
                width: 30.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nameAndTypesFields() {
    return Column(
      children: <Widget>[
        nameField(),
        typesFields(),
        clearButton(),
      ],
    );
  }

  Widget nameField() {
    return SizedBox(
      width: 200.0,
      child: TextField(
        autofocus: true,
        focusNode: nameFocusNode,
        controller: nameController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Name',
          icon: Icon(Icons.account_box)
        ),
        onChanged: (newValue) {
          AddQuoteInputs.reference.name = newValue;
        },
      ),
    );
  }

  Widget typesFields() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 20.0,
      ),
      child: SizedBox(
        width: 250.0,
        child: Column(
          children: <Widget>[
            TextField(
              controller: primaryTypeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '1st type (e.g. TV series)',
                icon: Icon(Icons.filter_1),
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.type.primary = newValue;
              },
            ),

            Padding(padding: const EdgeInsets.only(bottom: 10.0)),

            TextField(
              controller: secondaryTypeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '2nd type (e.g. Thriller)',
                icon: Icon(Icons.filter_2),
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.type.secondary  = newValue;
              },
            ),
          ],
        ),
      ),
    );
  }

  void showImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.all(
              Radius.circular(5.0)
            ),
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
                          "Reference image's URL",
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
                      labelText: AddQuoteInputs.reference.urls.image.length > 0 ?
                        AddQuoteInputs.reference.urls.image : 'URL',
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
                  AddQuoteInputs.reference.urls.image = tempImgUrl;
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
