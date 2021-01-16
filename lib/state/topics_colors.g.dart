// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topics_colors.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicsColors on TopicsColorsBase, Store {
  final _$topicsColorsAtom = Atom(name: 'TopicsColorsBase.topicsColors');

  @override
  List<TopicColor> get topicsColors {
    _$topicsColorsAtom.reportRead();
    return super.topicsColors;
  }

  @override
  set topicsColors(List<TopicColor> value) {
    _$topicsColorsAtom.reportWrite(value, super.topicsColors, () {
      super.topicsColors = value;
    });
  }

  final _$fetchTopicsColorsAsyncAction =
      AsyncAction('TopicsColorsBase.fetchTopicsColors');

  @override
  Future<dynamic> fetchTopicsColors() {
    return _$fetchTopicsColorsAsyncAction.run(() => super.fetchTopicsColors());
  }

  final _$TopicsColorsBaseActionController =
      ActionController(name: 'TopicsColorsBase');

  @override
  void setColors(List<TopicColor> topics) {
    final _$actionInfo = _$TopicsColorsBaseActionController.startAction(
        name: 'TopicsColorsBase.setColors');
    try {
      return super.setColors(topics);
    } finally {
      _$TopicsColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
topicsColors: ${topicsColors}
    ''';
  }
}
