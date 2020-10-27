import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:mobx/mobx.dart';

part 'topics_colors.g.dart';

class TopicsColors = TopicsColorsBase with _$TopicsColors;

abstract class TopicsColorsBase with Store {
  @observable
  List<TopicColor> topicsColors = [];

  @action
  Future fetchTopicsColors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('topics').get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final List<TopicColor> list = [];

    snapshot.docs.forEach((doc) {
      final topicColor = TopicColor.fromJSON(doc.data());
      list.add(topicColor);
    });

    topicsColors = list;
  }

  TopicColor find(String topic) {
    final exists = topicsColors.any((element) => element.name == topic);

    if (!exists) {
      return null;
    }

    final topicColor =
        topicsColors.firstWhere((element) => element.name == topic);

    return topicColor;
  }

  Color getColorFor(String topic) {
    final topicColor = find(topic);

    if (topicColor == null) {
      return Color(0xFF58595B);
    }

    return Color(topicColor.decimal);
  }

  @action
  void setColors(List<TopicColor> topics) {
    topicsColors = topics;
  }

  List<TopicColor> shuffle({int max = 0}) {
    final copy = topicsColors.toList();
    copy.shuffle();

    if (max == 0) {
      return copy;
    }

    max = max > copy.length ? copy.length : max;

    return copy.sublist(0, max);
  }
}

final appTopicsColors = TopicsColors();
