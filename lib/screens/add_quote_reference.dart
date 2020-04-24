import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteReference extends StatefulWidget {
  final int step;
  final int maxSteps;
  final Function onNextStep;
  final Function onPreviousStep;

  AddQuoteReference({
    Key key,
    this.maxSteps,
    this.onNextStep,
    this.onPreviousStep,
    this.step
  }): super(key: key);

  @override
  _AddQuoteReferenceState createState() => _AddQuoteReferenceState();
}

class _AddQuoteReferenceState extends State<AddQuoteReference> {
  String tempImgUrl = '';
  List<String> langs = ['en', 'fr'];

  final amazonUrlController     = TextEditingController();
  final facebookUrlController   = TextEditingController();
  final nameController          = TextEditingController();
  final netflixUrlController    = TextEditingController();
  final primeVideoUrlController = TextEditingController();
  final secondaryTypeController = TextEditingController();
  final summaryController       = TextEditingController();
  final twitchUrlController     = TextEditingController();
  final twitterUrlController    = TextEditingController();
  final primaryTypeController   = TextEditingController();
  final websiteUrlController    = TextEditingController();
  final wikiUrlController       = TextEditingController();
  final youTubeUrlController    = TextEditingController();

  @override
  void initState() {
    setState(() {
      amazonUrlController.text      = AddQuoteInputs.reference.urls.amazon;
      facebookUrlController.text    = AddQuoteInputs.reference.urls.facebook;
      nameController.text           = AddQuoteInputs.reference.name;
      netflixUrlController.text     = AddQuoteInputs.reference.urls.netflix;
      primeVideoUrlController.text  = AddQuoteInputs.reference.urls.primeVideo;
      twitchUrlController.text      = AddQuoteInputs.reference.urls.twitch;
      twitterUrlController.text     = AddQuoteInputs.reference.urls.twitter;
      primaryTypeController.text    = AddQuoteInputs.reference.type.primary;
      secondaryTypeController.text  = AddQuoteInputs.reference.type.secondary;
      summaryController.text        = AddQuoteInputs.reference.summary;
      websiteUrlController.text     = AddQuoteInputs.reference.urls.website;
      wikiUrlController.text        = AddQuoteInputs.reference.urls.wikipedia;
      youTubeUrlController.text     = AddQuoteInputs.reference.urls.youTube;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            content(),
            backButton(),
            forwardButton(),
          ],
        )
      ],
    );
  }

  Widget content() {
    final themeColor = Provider.of<ThemeColor>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        header(),
        avatar(),
        nameField(),
        typesFields(),
        langAndSummary(themeColor),
        links(),
        clearButton(),
        helpButton(),

        Padding(padding: EdgeInsets.only(top: 100.0),),
      ],
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Text(
                'Add reference',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        Opacity(
          opacity: 0.6,
          child: Text(
            '${widget.step}/${widget.maxSteps}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget avatar() {
    final imageUrl = AddQuoteInputs.reference.urls.image;

    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
      child: InkWell(
        onTap: () {
          return showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Image URL'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.all(Radius.circular(5.0)),
                ),
                content: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: imageUrl.length > 0 ? imageUrl : 'Type a new URL',
                  ),
                  onChanged: (newValue) {
                    tempImgUrl = newValue;
                  },
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel', style: TextStyle(color: ThemeColor.error),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Save',),
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
        },
        child: imageUrl.length > 0 ?
        Card(
          child: Image.network(
            imageUrl,
            height: 250.0,
            width: 200.0,
          ),
        ) :
        Card(
          child: SizedBox(
            height: 250.0,
            width: 200.0,
            child: Icon(Icons.add, size: 50.0,),
          ),
        ),
      )
    );
  }

  Widget nameField() {
    return SizedBox(
      width: 200.0,
      child: TextField(
        controller: nameController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Name',
        ),
        onChanged: (newValue) {
          AddQuoteInputs.reference.name = newValue;
        },
      ),
    );
  }

  Widget typesFields() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: primaryTypeController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Primary type',
            ),
            onChanged: (newValue) {
              AddQuoteInputs.reference.type.primary = newValue;
            },
          ),
        ),
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: secondaryTypeController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Ssecondary type',
            ),
            onChanged: (newValue) {
              AddQuoteInputs.reference.type.secondary = newValue;
            },
          ),
        ),
      ],
    );
  }

  Widget langAndSummary(ThemeColor themeColor) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: DropdownButton<String>(
            value: AddQuoteInputs.reference.lang,
            style: TextStyle(
              color: themeColor.accent,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            underline: Container(
              color: themeColor.accent,
              height: 2.0,
            ),
            onChanged: (newValue) {
              setState(() {
                AddQuoteInputs.reference.lang = newValue;
              });
            },
            items: langs.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: summaryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Summary',
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: null,
              onChanged: (newValue) {
                AddQuoteInputs.reference.summary= newValue;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget links() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 300,
          child: TextField(
            controller: wikiUrlController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(IconsMore.wikipedia_w),
              labelText: 'Wikipedia'
            ),
            onChanged: (newValue) {
              AddQuoteInputs.reference.urls.wikipedia = newValue;
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: websiteUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(IconsMore.earth),
                labelText: 'Website'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.website = newValue;
              },
            ),
          ),
        ),


        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: amazonUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
                labelText: 'Amazon'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.amazon = newValue;
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: facebookUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(IconsMore.facebook),
                labelText: 'Facebook'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.facebook = newValue;
              },
            ),
          ),
        ),

        SizedBox(
          width: 300,
          child: TextField(
            controller: twitterUrlController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(IconsMore.twitter),
              labelText: 'Twitter'
            ),
            onChanged: (newValue) {
              AddQuoteInputs.reference.urls.twitter = newValue;
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 45.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: twitchUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.ondemand_video),
                labelText: 'Twitch'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.twitch = newValue;
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: netflixUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_label),
                labelText: 'Netflix'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.netflix = newValue;
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: primeVideoUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.personal_video),
                labelText: 'Prime Video'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.primeVideo = newValue;
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: youTubeUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
                labelText: 'YouTube'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.reference.urls.youTube = newValue;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget clearButton() {
    return FlatButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {
        AddQuoteInputs.clearReference();

        amazonUrlController.clear();
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
        youTubeUrlController.clear();

        setState(() {});
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear reference information',
        ),
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      top: 10.0,
      left: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          onPressed: () {
            if (widget.onPreviousStep != null) {
              widget.onPreviousStep();
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      )
    );
  }

  Widget forwardButton() {
    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          onPressed: () {
            if (widget.onNextStep != null) {
              widget.onNextStep();
            }
          },
          icon: Icon(Icons.arrow_forward),
        ),
      )
    );
  }

  Widget helpButton() {
    return IconButton(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ListView(
              padding: EdgeInsets.all(40.0),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Help',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- Reference information are optional',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- If you select the reference\'s name in the dropdown list, other fields can stay empty',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
      icon: Icon(Icons.help),
    );
  }
}
