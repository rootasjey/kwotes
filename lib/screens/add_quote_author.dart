import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';

class AddQuoteAuthor extends StatefulWidget {
  final int step;
  final int maxSteps;

  AddQuoteAuthor({Key key, this.maxSteps, this.step}): super(key: key);

  @override
  AddQuoteAuthorState createState() => AddQuoteAuthorState();
}

class AddQuoteAuthorState extends State<AddQuoteAuthor> {
  String _imgUrl  = '';
  String _name    = '';
  String _job     = '';
  String _summary = '';
  String _url     = '';
  String _wikiUrl = '';

  String _tempImgUrl = '';

  String get imgUrl   => _imgUrl;
  String get name     => _name;
  String get job      => _job;
  String get summary  => _summary;
  String get url      => _url;
  String get wikiUrl  => _wikiUrl;

  @override
  void initState() {
    setState(() {
      _imgUrl = AddQuoteInputs.authorImgUrl;
    });

    super.initState();
  }

  @override
  dispose() {
    AddQuoteInputs.authorImgUrl = _imgUrl;
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
                            labelText: _imgUrl.length > 0 ? _imgUrl : 'Type a new URL',
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
                                _imgUrl = _tempImgUrl;
                              });

                              AddQuoteInputs.authorImgUrl = _imgUrl;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
                child: _imgUrl.length > 0 ?
                CircleAvatar(
                  backgroundImage: NetworkImage(_imgUrl),
                  radius: 80.0,
                ) :
                CircleAvatar(
                  child: Icon(Icons.add, size: 50.0,),
                  radius: 80.0,
                ),
              )
            ),

            SizedBox(
              width: 200.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (newValue) {
                  _name = newValue;
                  AddQuoteInputs.authorName = newValue;
                },
              ),
            ),
            SizedBox(
              width: 200.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Job',
                ),
                onChanged: (newValue) {
                  _job = newValue;
                  AddQuoteInputs.authorJob = newValue;
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Summary',
                    alignLabelWithHint: true,
                  ),
                  minLines: 4,
                  maxLines: null,
                  onChanged: (newValue) {
                    _summary = newValue;
                    AddQuoteInputs.authorSummary = newValue;
                  },
                ),
              ),
            ),

            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(IconsMore.wikipedia_w),
                  labelText: 'Wikipedia URL'
                ),
                onChanged: (newValue) {
                  _wikiUrl = newValue;
                  AddQuoteInputs.authorWikiUrl = newValue;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 100.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(IconsMore.earth),
                    labelText: 'Website URL'
                  ),
                  onChanged: (newValue) {
                    _url = newValue;
                    AddQuoteInputs.authorUrl = newValue;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
