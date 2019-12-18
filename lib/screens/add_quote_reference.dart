import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';

class AddQuoteReference extends StatefulWidget {
  final int step;
  final int maxSteps;

  AddQuoteReference({
    Key key,
    this.maxSteps,
    this.step
  }): super(key: key);

  @override
  AddQuoteReferenceState createState() => AddQuoteReferenceState();
}

class AddQuoteReferenceState extends State<AddQuoteReference> {
  String _imgUrl  = '';
  String _lang    = 'en';
  String _name    = '';
  String _type     = '';
  String _subType = '';
  String _summary = '';
  String _url     = '';
  String _wikiUrl = '';

  String _tempImgUrl = '';

  List<String> langs = ['en', 'fr'];

  String get imgUrl   => _imgUrl;
  String get lang     => _lang;
  String get name     => _name;
  String get type     => _type;
  String get subType  => _subType;
  String get summary  => _summary;
  String get url      => _url;
  String get wikiUrl  => _wikiUrl;

  @override
  void initState() {
    setState(() {
      _imgUrl = AddQuoteInputs.refImgUrl;
    });

    super.initState();
  }

  @override
  dispose() {
    AddQuoteInputs.refImgUrl = _imgUrl;
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
                'Add reference',
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

                              AddQuoteInputs.refImgUrl = _imgUrl;
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
                Card(
                  child: SizedBox(
                    height: 300.0,
                    width: 250.0,
                    child: Icon(Icons.add, size: 50.0,),
                  ),
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
                  AddQuoteInputs.refName = newValue;
                },
              ),
            ),
            SizedBox(
              width: 200.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Type',
                ),
                onChanged: (newValue) {
                  _type = newValue;
                  AddQuoteInputs.refType = newValue;
                },
              ),
            ),
            SizedBox(
              width: 200.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Sub-Type',
                ),
                onChanged: (newValue) {
                  _subType = newValue;
                  AddQuoteInputs.refSubType = newValue;
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: DropdownButton<String>(
                value: _lang,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(
                  color: Colors.black,
                  height: 2.0,
                ),
                onChanged: (newValue) {
                  setState(() {
                    _lang = newValue;
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Summary',
                    alignLabelWithHint: true,
                  ),
                  minLines: 4,
                  maxLines: null,
                  onChanged: (newValue) {
                    _summary = newValue;
                    AddQuoteInputs.refSummary = newValue;
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
                  AddQuoteInputs.refUrl = newValue;
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
                    AddQuoteInputs.refPromoUrl = newValue;
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
