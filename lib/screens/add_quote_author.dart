import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteAuthor extends StatefulWidget {
  final int step;
  final int maxSteps;

  AddQuoteAuthor({Key key, this.maxSteps, this.step}): super(key: key);

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                'Add author',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${widget.step}/${widget.maxSteps}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
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
            ),

            SizedBox(
              width: 200.0,
              child: TextField(
                controller: _nameController,
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
                decoration: InputDecoration(
                  labelText: 'Job',
                ),
                onChanged: (newValue) {
                  job = newValue;
                  AddQuoteInputs.authorJob = newValue;
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _summaryController,
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
            ),

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

            FlatButton(
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
            ),

            Padding(padding: EdgeInsets.only(bottom: 100.0),)
          ],
        ),
      ],
    );
  }
}
