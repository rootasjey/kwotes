import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/screens/web/add_quote_nav_buttons.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:provider/provider.dart';

class AddQuoteTopics extends StatefulWidget {
  @override
  _AddQuoteTopicsState createState() => _AddQuoteTopicsState();
}

class _AddQuoteTopicsState extends State<AddQuoteTopics> {
  List<TopicColor> selectedTopics = [];
  List<TopicColor> availableTopics = [];

  FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode();

    populateSelectedTopics();
  }

  @override
  void dispose() {
    if (_keyboardFocusNode != null) {
      _keyboardFocusNode.dispose();
    }

    super.dispose();
  }

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

  Widget addedTopics(ThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70.0),
      child: Column(
        children: <Widget>[
          Wrap(
            spacing: 20.0,
            children: selectedTopics.map<Widget>((topic) {
              return Chip(
                backgroundColor: Color(topic.decimal),
                padding: EdgeInsets.all(5.0),
                label: Text(topic.name, style: TextStyle(color: Colors.white),),
                deleteIconColor: Colors.white,
                onDeleted: () {
                  setState(() {
                    availableTopics.add(topic);
                    selectedTopics.remove(topic);
                  });

                  AddQuoteInputs.topics.removeWhere((element) => element == topic.name);
                },
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
                  selectedTopics.clear();

                  availableTopics.clear();
                  availableTopics.addAll(ThemeColor.topicsColors);
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
      ),
    );
  }

  Widget availableTopicsSection(ThemeColor themeColor) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Divider(height: 120.0,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'Topics',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
          ),

          Text(
            'Select some of the available topics to categorize the quote.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeColor.background,
              fontSize: 20.0,
            ),
          ),

          Observer(builder: (context) {
            if (availableTopics.length == 0) {
              availableTopics.addAll(appTopicsColors.topicsColors);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: Wrap(
                children: availableTopics.map<Widget>((topic) {
                  return Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: ActionChip(
                      padding: EdgeInsets.all(5.0),
                      label: Text(topic.name),
                      onPressed: () {
                        setState(() {
                          selectedTopics.add(topic);
                          availableTopics.remove(topic);
                        });

                        AddQuoteInputs.topics.add(topic.name);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget body() {
    final themeColor = Provider.of<ThemeColor>(context);

    return SizedBox(
      width: 500.0,
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: _keyboardFocusNode,
        onKey: keyHandler,
        child: Column(
          children: <Widget>[
            title(),

            selectedTopics.length == 0 ?
              emptyTopics(themeColor) :
              addedTopics(themeColor),

            availableTopicsSection(themeColor),

            AddQuoteNavButtons(
              onPrevPressed: () => FluroRouter.router.pop(context),
              onNextPressed: () => FluroRouter.router.navigateTo(context, AddQuoteAuthorRoute),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyTopics(ThemeColor themeColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 40.0),
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

  Widget helpButton() {
    return IconButton(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help)
      ),
      iconSize: 40.0,
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
                              '• Topics are used to categorize the quote',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• You can select one or more topics',
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

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add topics',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            '2/5',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  void keyHandler (RawKeyEvent keyEvent) {
    if (keyEvent.runtimeType.toString() == 'RawKeyDownEvent') {
      return;
    }

    if (keyEvent.logicalKey.keyId == LogicalKeyboardKey.enter.keyId) {
      FluroRouter.router.navigateTo(context, AddQuoteAuthorRoute);
      return;
    }
  }

  void populateSelectedTopics() {
    AddQuoteInputs.topics.forEach((topicName) {
      selectedTopics.add(
        appTopicsColors.find(topicName)
      );
    });

    setState(() {});
  }
}
