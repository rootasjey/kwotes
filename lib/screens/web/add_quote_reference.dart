import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/screens/web/add_quote_nav_buttons.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:provider/provider.dart';

class AddQuoteReference extends StatefulWidget {
  @override
  _AddQuoteReferenceState createState() => _AddQuoteReferenceState();
}

class _AddQuoteReferenceState extends State<AddQuoteReference> {
  String imgUrl         = '';
  String lang           = 'en';
  String name           = '';
  String primaryType    = '';
  String secondaryType  = '';
  String summary        = '';
  String url            = '';
  String wikiUrl        = '';

  String tempImgUrl = '';

  List<String> langs = ['en', 'fr'];

  final _nameController           = TextEditingController();
  final _primaryTypeController    = TextEditingController();
  final _secondaryTypeController  = TextEditingController();
  final _summaryController        = TextEditingController();
  final _urlController            = TextEditingController();
  final _wikiUrlController        = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AddQuoteLayout(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(),
              body(),
            ],
          ),

          Positioned(
            right: 50.0,
            top: 80.0,
            child: helpButton(),
          )
        ],
      ),
    );
  }

  Widget body() {
    final themeColor = Provider.of<ThemeColor>(context);

    return SizedBox(
      width: 500.0,
      child: Column(
        children: <Widget>[
          title(),
          imagePreview(),
          nameField(),
          typesFields(),
          langAndSummary(themeColor),
          links(),
          clearButton(),

          AddQuoteNavButtons(
            onPrevPressed: () => FluroRouter.router.pop(context),
            onNextPressed: () => FluroRouter.router.navigateTo(context, AddQuoteCommentRoute),
          ),
        ],
      ),
    );
  }

  Widget clearButton() {
    return FlatButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {
        AddQuoteInputs.clearReference();

        imgUrl = '';

        _nameController.clear();
        _primaryTypeController.clear();
        _secondaryTypeController.clear();
        _summaryController.clear();
        _urlController.clear();
        _wikiUrlController.clear();
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear reference information',
        ),
      ),
    );
  }

  Widget helpButton() {
    return IconButton(
      iconSize: 40.0,
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help,)
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
                              '• Reference information are optional',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• If you select the reference\'s name in the dropdown list, other fields can stay empty',
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

  Widget imagePreview() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
      child: Card(
        child: imgUrl.length > 0 ?
          Ink.image(
            width: 250.0,
            height: 300.0,
            fit: BoxFit.cover,
            image: NetworkImage(imgUrl),
            child: InkWell(
              onTap: () => showImageDialog(),
            ),
          ) :
          SizedBox(
            width: 250.0,
            height: 300.0,
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

  Widget langAndSummary(ThemeColor themeColor) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: DropdownButton<String>(
            value: lang,
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
                lang = newValue;
                AddQuoteInputs.refLang = newValue;
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
            width: 400,
            child: TextField(
              controller: _summaryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Summary',
                alignLabelWithHint: true,
              ),
              minLines: 10,
              maxLines: null,
              onChanged: (newValue) {
                summary = newValue;
                AddQuoteInputs.refSummary = newValue;
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
            controller: _wikiUrlController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(IconsMore.wikipedia_w),
              labelText: 'Wikipedia URL'
            ),
            onChanged: (newValue) {
              wikiUrl = newValue;
              AddQuoteInputs.refWikiUrl = newValue;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(IconsMore.earth),
                labelText: 'Website URL'
              ),
              onChanged: (newValue) {
                url = newValue;
                AddQuoteInputs.refUrl = newValue;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget nameField() {
    return SizedBox(
      width: 200.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: TextField(
          autofocus: true,
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Name',
          ),
          onChanged: (newValue) {
            name = newValue;
            AddQuoteInputs.refName = newValue;
          },
        ),
      ),
    );
  }

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add reference',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            '4/5',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget typesFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: SizedBox(
        width: 300.0,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _primaryTypeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Primary type (TV Show, Movie, ...)',
              ),
              onChanged: (newValue) {
                primaryType = newValue;
                AddQuoteInputs.refPrimaryType= newValue;
              },
            ),

            Padding(padding: const EdgeInsets.only(bottom: 10.0)),

            TextField(
              controller: _secondaryTypeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Secondary type (Horror, Thriller, ...)',
              ),
              onChanged: (newValue) {
                secondaryType = newValue;
                AddQuoteInputs.refSecondaryType = newValue;
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
                      labelText: imgUrl.length > 0 ? imgUrl : 'URL',
                    ),
                    onChanged: (newValue) {
                      tempImgUrl = newValue;
                    },
                    onSubmitted: (value) {
                      setState(() {
                        imgUrl = tempImgUrl;
                      });

                      AddQuoteInputs.refImgUrl = imgUrl;
                      Navigator.of(context).pop();
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
                style: TextStyle(
                  color: Provider.of<ThemeColor>(context).blackOrWhite,
                ),
               ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('SAVE',),
              onPressed: () {
                setState(() {
                  imgUrl = tempImgUrl;
                });

                AddQuoteInputs.refImgUrl = imgUrl;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }
}
