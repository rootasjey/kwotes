import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class AddQuoteTopics extends StatefulWidget {
  final int maxSteps;
  final int step;
  final Function onNextStep;
  final Function onPreviousStep;

  AddQuoteTopics({
    Key key,
    this.maxSteps,
    this.onNextStep,
    this.onPreviousStep,
    this.step,
  }): super(key: key);

  @override
  _AddQuoteTopicsState createState() => _AddQuoteTopicsState();
}

class _AddQuoteTopicsState extends State<AddQuoteTopics> {
  List<String> topics = [];
  List<String> sampleTopics = [];

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    setState(() {
      topics.addAll(AddQuoteInputs.topics);
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (sampleTopics.length > 0) { return; }

    fetchSampleTopics()
      .then((sampleResults) {
        setState(() {
          sampleTopics = sampleResults;
        });
      });

    super.didChangeDependencies();
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
    final themeColor = Provider.of<ThemeColor>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        header(),

        textInput(themeColor),

        if (topics.length == 0)
          emptyTopics(themeColor),

        if (topics.length > 0)
          addedTopics(themeColor),

        if (sampleTopics.length > 0)
          sampleTopicsSection(themeColor),

        helpButton(),
      ],
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Text(
            'Add topics',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget textInput(ThemeColor themeColor) {
    final color = themeColor.accent;

    return Padding(
      padding: EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        bottom: 40.0,
        top: 80.0,
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          final keyId = event.logicalKey.keyId;

          if (keyId == 4295426088 || keyId == 32 || keyId == 54 || keyId == 44) {
            final text = _textEditingController.text.trim();

            if (text.length == 0) {
              return;
            }

            onAddTopic(text);
            _textEditingController.clear();
          }
        },
        child: TextField(
          keyboardType: TextInputType.multiline,
          controller: _textEditingController,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            hintText: 'Add a new topic',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: color,
                width: 2.0,
              )
            ),
          ),
          onChanged: (value) {
            if (value.endsWith(',') || value.endsWith(';') || value.endsWith(' ')) {
              final computed = value.trim().replaceAll(',', '').replaceAll(';', '');
              onAddTopic(computed);
              _textEditingController.clear();
            }
          },
          onSubmitted: (value) {
            onAddTopic(value);
            _textEditingController.clear();
          },
        ),
      )
    );
  }

  Widget emptyTopics(ThemeColor themeColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Text(
        'You have not added any topic yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.0,
          color: themeColor.background,
        ),
      ),
    );
  }

  Widget addedTopics(ThemeColor themeColor) {
    return Column(
      children: <Widget>[
        Wrap(
          children: topics.map<Widget>((topic) {
            return Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: Chip(
                backgroundColor: ThemeColor.topicColor(topic),
                padding: EdgeInsets.all(5.0),
                label: Text(topic, style: TextStyle(color: Colors.white),),
                deleteIconColor: Colors.white,
                onDeleted: () {
                  setState(() {
                    topics.removeWhere((entry) => entry == topic);
                  });

                  AddQuoteInputs.topics = topics;
                },
              ),
            );
          }).toList(),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FlatButton(
            padding: EdgeInsets.all(10.0),
            onPressed: () {
              setState(() {
                AddQuoteInputs.clearTopics();
                topics.clear();
              });
            },
            child: Text(
              'Clear all topics',
              style: TextStyle(
                color: themeColor.background,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget sampleTopicsSection(ThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Divider(height: 60.0,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'Sample topics',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
          ),

          Text(
            'Select some of the following sample topics to categorize the quote.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeColor.background,
              fontSize: 20.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Wrap(
              children: sampleTopics.map<Widget>((topic) {
                return Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: ActionChip(
                    padding: EdgeInsets.all(5.0),
                    label: Text(topic),
                    onPressed: () {
                      setState(() {
                        topics.add(topic);
                        sampleTopics.removeWhere((entry) => entry == topic);
                      });

                      AddQuoteInputs.topics = topics;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: 30.0),
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
                    '- Topics should be in english plain words',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- Topics are used to categorize the quote',
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    '- Already used topics are preferred',
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

  void onAddTopic(String topic) {
    if (topic == null || topic.length == 0) {
      return;
    }

    if (topics.contains(topic)) { return; }

    setState(() {
      topics.add(topic);
    });

    AddQuoteInputs.topics = topics;
  }

  Future<List<String>> fetchSampleTopics() {
    List<String> sampleResults = [];

    final client = Provider.of<HttpClientsModel>(context).defaultClient;

    final String randomTopics = """
      query {
        randomTopics
      }
    """;

    return client.value.query(
      QueryOptions(
        documentNode: parseString(randomTopics),
      )
    ).then((queryResult) {
      if (queryResult.hasException) {
        return sampleResults;
      }

      final Map<String, dynamic> json = queryResult.data;

      for (var topic in json['randomTopics']) {
        sampleResults.add(topic);
      }

      return sampleResults;

    }).catchError((error) {
      return sampleResults;
    });
  }
}
