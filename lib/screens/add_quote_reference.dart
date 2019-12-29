import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteReference extends StatefulWidget {
  final int step;
  final int maxSteps;

  AddQuoteReference({
    Key key,
    this.maxSteps,
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

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _subTypeController = TextEditingController();
  final _summaryController = TextEditingController();
  final _urlController = TextEditingController();
  final _wikiUrlController = TextEditingController();

  @override
  void initState() {
    setState(() {
      imgUrl = AddQuoteInputs.refImgUrl;
    });

    super.initState();
  }

  @override
  dispose() {
    AddQuoteInputs.refImgUrl = imgUrl;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeColor>(context);

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
                  AddQuoteInputs.refName = newValue;
                },
              ),
            ),
            SizedBox(
              width: 200.0,
              child: TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                ),
                onChanged: (newValue) {
                  type = newValue;
                  AddQuoteInputs.refType = newValue;
                },
              ),
            ),
            SizedBox(
              width: 200.0,
              child: TextField(
                controller: _subTypeController,
                decoration: InputDecoration(
                  labelText: 'Sub-Type',
                ),
                onChanged: (newValue) {
                  subType = newValue;
                  AddQuoteInputs.refSubType = newValue;
                },
              ),
            ),

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

            FlatButton(
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
            ),

            Padding(padding: EdgeInsets.only(bottom: 100.0)),
          ],
        ),
      ],
    );
  }
}
