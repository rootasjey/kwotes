import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/screens/web/add_quote_nav_buttons.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/utils/on_long_press_nav_back.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class AddQuoteAuthor extends StatefulWidget {
  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  final beginY        = 100.0;
  final delay         = 1.0;
  final delayStep     = 1.2;

  String tempImgUrl = '';

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

  final nameFocusNode = FocusNode();

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
    return AddQuoteLayout(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(
                onLongPress: () => onLongPressNavBack(context),
              ),
              body(),
            ],
          ),

          Positioned(
            right: 120.0,
            top: 85.0,
            child: IconButton(
              onPressed: () {
                FluroRouter.router.navigateTo(
                  context,
                  AddQuoteReferenceRoute,
                );
              },
              icon: Icon(
                Icons.arrow_forward,
              ),
            ),
          ),

          Positioned(
            right: 50.0,
            top: 70.0,
            child: helpButton(),
          )
        ],
      ),
    );
  }

  Widget avatar() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
      child: Material(
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
      ),
    );
  }

  Widget body() {
    return SizedBox(
      width: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FadeInY(
            beginY: beginY,
            child: title(),
          ),

          FadeInY(
            delay: delay + (1 * delayStep),
            beginY: beginY,
            child: avatar(),
          ),

          FadeInY(
            delay: delay + (2 * delayStep),
            beginY: beginY,
            child: nameAndJob(),
          ),

          FadeInY(
            delay: delay + (3 * delayStep),
            beginY: beginY,
            child: summaryField(),
          ),

          FadeInY(
            delay: delay + (4 * delayStep),
            beginY: beginY,
            child: links(),
          ),

          FadeInY(
            delay: delay + (5 * delayStep),
            beginY: beginY,
            child: clearButton(),
          ),

          FadeInY(
            delay: delay + (6 * delayStep),
            beginY: beginY,
            child: AddQuoteNavButtons(
              onPrevPressed: () => FluroRouter.router.pop(context),
              onNextPressed: () => FluroRouter.router.navigateTo(context, AddQuoteReferenceRoute),
            ),
          ),
        ],
      ),
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

        nameFocusNode.requestFocus();
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear author information',
        ),
      ),
    );
  }

  Widget helpButton() {
    return IconButton(
      iconSize: 40.0,
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help),
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 500.0,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        'Help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 500.0,
                    child: Opacity(
                      opacity: .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
            ),
            onChanged: (newValue) {
              AddQuoteInputs.author.job = newValue;
            },
          ),
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
          border: OutlineInputBorder(),
          labelText: 'Summary',
          alignLabelWithHint: true,
        ),
        minLines: 10,
        maxLines: null,
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
}
