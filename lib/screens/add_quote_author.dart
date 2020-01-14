import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
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
  String imgUrl  = '';
  String name    = '';
  String job     = '';
  String summary = '';
  String url     = '';
  String wikiUrl = '';

  String _tempImgUrl = '';

  final _nameController     = TextEditingController();
  final _jobController      = TextEditingController();
  final _summaryController  = TextEditingController();
  final _urlController      = TextEditingController();
  final _wikiController     = TextEditingController();

  @override
  void initState() {
    setState(() {
      imgUrl = AddQuoteInputs.authorImgUrl;

      _nameController.text    = AddQuoteInputs.authorName;
      _jobController.text     = AddQuoteInputs.authorJob;
      _summaryController.text = AddQuoteInputs.authorSummary;
      _urlController.text     = AddQuoteInputs.authorUrl;
      _wikiController.text    = AddQuoteInputs.authorWikiUrl;
    });

    super.initState();
  }

  @override
  dispose() {
    AddQuoteInputs.authorImgUrl = imgUrl;
    super.dispose();
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
        ),
      ],
    );
  }

  Widget content() {
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

        Padding(padding: EdgeInsets.only(bottom: 100.0),)
      ],
    );
  }

  Widget avatar() {
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
                    _tempImgUrl = newValue;
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
                        imgUrl = _tempImgUrl;
                      });

                      AddQuoteInputs.authorImgUrl = imgUrl;
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
                'Add author',
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

  Widget nameAndJob() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
            onChanged: (newValue) {
              name = newValue;
              AddQuoteInputs.authorName = newValue;
            },
          ),
        ),
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _jobController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Job',
            ),
            onChanged: (newValue) {
              job = newValue;
              AddQuoteInputs.authorJob = newValue;
            },
          ),
        ),
      ],
    );
  }

  Widget summaryField() {
    return Padding(
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
            AddQuoteInputs.authorSummary = newValue;
          },
        ),
      ),
    );
  }

  Widget links() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 300,
          child: TextField(
            controller: _wikiController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(IconsMore.wikipedia_w),
              labelText: 'Wikipedia URL'
            ),
            onChanged: (newValue) {
              wikiUrl = newValue;
              AddQuoteInputs.authorWikiUrl = newValue;
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
                AddQuoteInputs.authorUrl = newValue;
              },
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

        imgUrl = '';

        _nameController.clear();
        _summaryController.clear();
        _jobController.clear();
        _urlController.clear();
        _wikiController.clear();
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
                    '- Author information are optional',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- If you select the author\'s name in the dropdown list, other fields can stay empty',
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
