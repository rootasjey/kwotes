import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/topic_card_color.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/state/topics_colors.dart';
import 'package:memorare/types/topic_color.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:supercharged/supercharged.dart';

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
  List<TopicColor> selectedTopics = [];
  List<TopicColor> allTopics = [];

  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (selectedTopics.length == 0) {
      populateSelectedTopics();
    }

    if (allTopics.length == 0) {
      fetchTopics();
     }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            body(),
            backButton(),
            forwardButton(),
          ],
        ),
      ],
    );
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        header(),

        if (selectedTopics.length == 0)
          emptyTopics(),

        if (selectedTopics.length > 0)
          selectedTopicsSection(),

        if (allTopics.length > 0)
          allTopicsSection(),

        helpButton(),

        Padding(padding: EdgeInsets.only(bottom: 100.0),),
      ],
    );
  }

  Widget header() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: delay + (1 * delayStep),
          beginY: beginY,
          child: Padding(
            padding: EdgeInsets.only(top: 45.0),
            child: Text(
              'Add topics',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        FadeInY(
          delay: delay + (2 * delayStep),
          beginY: beginY,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              '${widget.step}/${widget.maxSteps}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget emptyTopics() {
    return FadeInY(
      delay: delay + (1 * delayStep),
      beginY: beginY,
      child: Padding(
        padding: EdgeInsets.only(
          top: 80.0,
          left: 20.0,
          right: 20.0,
        ),
        child: Opacity(
          opacity: .6,
          child: Text(
            'You have not added any topic yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget selectedTopicsSection() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50.0,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 200.0,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: selectedTopics.length,
              itemBuilder: (context, index) {
                final topicColor = selectedTopics.elementAt(index);
                final name = topicColor.name;

                return FadeInY(
                  beginY: 100.0,
                  endY: 0.0,
                  delay: index * 1.0,
                  child: TopicCardColor(
                    onColorTap: () {
                      setState(() {
                        allTopics.add(topicColor);
                        selectedTopics.remove(topicColor);
                      });

                      AddQuoteInputs.quote.topics
                        .removeWhere((element) => element == topicColor.name);
                    },
                    size: 100.0,
                    elevation: 6.0,
                    color: Color(topicColor.decimal),
                    name: name,
                    displayName: name,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                );
              },
            ),
          ),

          FadeInY(
            beginY: 50.0,
            child: FlatButton(
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                setState(() {
                  AddQuoteInputs.clearTopics();
                  selectedTopics.clear();

                  allTopics.clear();
                  allTopics.addAll(appTopicsColors.topicsColors);
                });
              },
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Clear all topics',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget allTopicsSection() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          ControlledAnimation(
            duration: 1.seconds,
            delay: 1.seconds,
            tween: Tween(begin: 0.0, end: 500.0),
            builder: (_, value) {
              return SizedBox(
                width: value,
                child: Divider(height: 80.0,),
              );
            },
          ),

          FadeInY(
            beginY: beginY,
            delay: delay + (2 * delayStep),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                'All topics',
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
          ),

          FadeInY(
            beginY: beginY,
            delay: delay + (3 * delayStep),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Select some of the available topics to categorize the quote.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
          ),

          Observer(builder: (context) {
            if (allTopics.length == 0) {
              allTopics.addAll(appTopicsColors.topicsColors);
            }

            return SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allTopics.length,
                itemBuilder: (context, index) {
                  final topicColor = allTopics.elementAt(index);
                  final name = topicColor.name;

                  return FadeInY(
                    beginY: 100.0,
                    endY: 0.0,
                    delay: index * 1.0,
                    child: TopicCardColor(
                      onColorTap: () {
                        setState(() {
                          selectedTopics.add(topicColor);
                          allTopics.remove(topicColor);
                        });

                        AddQuoteInputs.quote.topics.add(topicColor.name);
                      },
                      size: 80.0,
                      elevation: 6.0,
                      color: Color(topicColor.decimal),
                      name: name,
                      displayName: name,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget backButton() {
    return Positioned(
      top: 30.0,
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
      top: 30.0,
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
      icon: Icon(Icons.help),
      iconSize: 40.0,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Center(
                      child: Text(
                        'Help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '• Topics should be in english plain words',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
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
                      '• Already used topics are preferred',
                      style: TextStyle(
                        fontSize: 17.0,
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

  void fetchTopics() {
    setState(() {
      allTopics = appTopicsColors.topicsColors.sublist(0);
    });
  }

  void populateSelectedTopics() {
    AddQuoteInputs.quote.topics.forEach((topicName) {
      selectedTopics.add(
        appTopicsColors.find(topicName)
      );
    });

    setState(() {});
  }
}
