import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteAuthor extends StatefulWidget {
  final int step;
  final int maxSteps;
  final Function onNextStep;
  final Function onPreviousStep;

  AddQuoteAuthor({
    Key key,
    this.maxSteps,
    this.onNextStep,
    this.onPreviousStep,
    this.step
  }): super(key: key);

  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  String tempImgUrl = '';

  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  final amazonUrlController   = TextEditingController();
  final facebookUrlController = TextEditingController();
  final jobController         = TextEditingController();
  final nameController        = TextEditingController();
  final summaryController     = TextEditingController();
  final twitchUrlController   = TextEditingController();
  final twitterUrlController  = TextEditingController();
  final websiteUrlController  = TextEditingController();
  final wikiUrlController     = TextEditingController();
  final youtubeUrlController  = TextEditingController();

  @override
  void initState() {
    setState(() {
      amazonUrlController.text    = AddQuoteInputs.author.urls.amazon;
      facebookUrlController.text  = AddQuoteInputs.author.urls.facebook;
      jobController.text          = AddQuoteInputs.author.job;
      nameController.text         = AddQuoteInputs.author.name;
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
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            body(),
            backButton(),
            forwardButton(),
          ],
        ),
      ],
    );
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        header(),

        avatar(),
        nameAndJob(),

        summaryField(),
        links(),
        clearButton(),

        helpButton(),

        Padding(padding: EdgeInsets.only(bottom: 100.0),),
      ],
    );
  }

  Widget avatar() {
    final imageUrl = AddQuoteInputs.author.urls.image;

    return FadeInY(
      delay: delay + (3 * delayStep),
      beginY: beginY,
      child: Padding(
        padding: EdgeInsets.only(top: 60.0, bottom: 50.0),
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
                          AddQuoteInputs.author.urls.image = tempImgUrl;
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
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 80.0,
          ) :
          CircleAvatar(
            child: Icon(
              Icons.add,
              size: 50.0,
              color: Provider.of<ThemeColor>(context).accent,
            ),
            backgroundColor: Colors.black12,
            radius: 80.0,
          ),
        )
      ),
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeInY(
              delay: delay + (1 * delayStep),
              beginY: beginY,
              child: Padding(
                padding: EdgeInsets.only(top: 45.0),
                child: Text(
                  'Add author',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        FadeInY(
          delay: delay + (2 * delayStep),
          beginY: beginY,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              '${widget.step}/${widget.maxSteps}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget nameAndJob() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: delay + (4 * delayStep),
          beginY: beginY,
          child: SizedBox(
            width: 200.0,
            child: TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              onChanged: (newValue) {
                AddQuoteInputs.author.name = newValue;
              },
            ),
          ),
        ),

        FadeInY(
          delay: delay + (5 * delayStep),
          beginY: beginY,
          child: SizedBox(
            width: 200.0,
            child: TextField(
              controller: jobController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Job',
              ),
              onChanged: (newValue) {
                AddQuoteInputs.author.job = newValue;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget summaryField() {
    return FadeInY(
      delay: delay + (6 * delayStep),
      beginY: beginY,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 70.0),
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
              AddQuoteInputs.author.summary = newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget links() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: delay + (7 * delayStep),
          beginY: beginY,
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: wikiUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(IconsMore.wikipedia_w),
                labelText: 'Wikipedia'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.author.urls.wikipedia = newValue;
              },
            ),
          ),
        ),

        FadeInY(
          delay: delay + (8 * delayStep),
          beginY: beginY,
          child: Padding(
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
                  AddQuoteInputs.author.urls.website = newValue;
                },
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (9 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: twitchUrlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 6.0,
                      end: 3.0,
                    ),
                    child: Image.asset(
                      'assets/images/twitch.png',
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxWidth: 36.0,
                  ),
                  labelText: 'Twitch'
                ),
                onChanged: (newValue) {
                  AddQuoteInputs.author.urls.twitch = newValue;
                },
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (10 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: twitterUrlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 6.0,
                      end: 3.0,
                    ),
                    child: Image.asset(
                      'assets/images/twitter.png',
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxWidth: 36.0,
                  ),
                  labelText: 'Twitter'
                ),
                onChanged: (newValue) {
                  AddQuoteInputs.author.urls.twitter = newValue;
                },
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (11 * delayStep),
          beginY: beginY,
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: youtubeUrlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 6.0,
                    end: 3.0,
                  ),
                  child: Image.asset(
                    'assets/images/youtube.png',
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  maxWidth: 36.0,
                ),
                labelText: 'YouTube'
              ),
              onChanged: (newValue) {
                AddQuoteInputs.author.urls.youtube = newValue;
              },
            ),
          ),
        ),

        FadeInY(
          delay: delay + (12 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: facebookUrlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6.0,),
                    child: Image.asset(
                      'assets/images/facebook.png',
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxWidth: 36.0,
                  ),
                  labelText: 'Facebook'
                ),
                onChanged: (newValue) {
                  AddQuoteInputs.author.urls.facebook = newValue;
                },
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (13 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: amazonUrlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6.0,),
                    child: Image.asset(
                      'assets/images/amazon.png',
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxWidth: 36.0,
                  ),
                  labelText: 'Amazon'
                ),
                onChanged: (newValue) {
                  AddQuoteInputs.author.urls.amazon = newValue;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget clearButton() {
    return FlatButton(
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
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear author information',
        ),
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      top: 30.0,
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
      top: 30.0,
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
      icon: Icon(Icons.help),
      iconSize: 40.0,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Center(
                      child: Text(
                        'Help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '• Author information are optional',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '• If you select the author\'s name in the dropdown list, other fields can stay empty',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },

    );
  }
}
