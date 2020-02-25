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
  String imgUrl  = '';
  String lang    = 'en';
  String name    = '';
  String type    = '';
  String subType = '';
  String summary = '';
  String url     = '';
  String wikiUrl = '';

  String tempImgUrl = '';

  List<String> langs = ['en', 'fr'];

  final _nameController     = TextEditingController();
  final _typeController     = TextEditingController();
  final _subTypeController  = TextEditingController();
  final _summaryController  = TextEditingController();
  final _urlController      = TextEditingController();
  final _wikiUrlController  = TextEditingController();

  @override
  void initState() {
    setState(() {
      imgUrl  = AddQuoteInputs.refImgUrl;
      lang    = AddQuoteInputs.refLang;

      _nameController.text    = AddQuoteInputs.refName;
      _subTypeController.text = AddQuoteInputs.refSecondaryType;
      _typeController.text    = AddQuoteInputs.refPrimaryType;
      _summaryController.text = AddQuoteInputs.refSummary;
      _urlController.text     = AddQuoteInputs.refUrl;
      _wikiUrlController.text = AddQuoteInputs.refWikiUrl;
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
        imagePreview(),
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

  Widget imagePreview() {
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
                    labelText: imgUrl.length > 0 ? imgUrl : 'Type a new URL',
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
        },
        child: imgUrl.length > 0 ?
        CircleAvatar(
          backgroundImage: NetworkImage(imgUrl),
          radius: 80.0,
        ) :
        Card(
          child: SizedBox(
            height: 300.0,
            width: 250.0,
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
    );
  }

  Widget typesFields() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _typeController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Type',
            ),
            onChanged: (newValue) {
              type = newValue;
              AddQuoteInputs.refPrimaryType= newValue;
            },
          ),
        ),
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _subTypeController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Sub-Type',
            ),
            onChanged: (newValue) {
              subType = newValue;
              AddQuoteInputs.refSecondaryType = newValue;
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
            width: 300,
            child: TextField(
              controller: _summaryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Summary',
                alignLabelWithHint: true,
              ),
              minLines: 4,
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

  Widget clearButton() {
    return FlatButton(
      padding: EdgeInsets.all(10.0),
      onPressed: () {
        AddQuoteInputs.clearReference();

        imgUrl = '';

        _nameController.clear();
        _typeController.clear();
        _subTypeController.clear();
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
