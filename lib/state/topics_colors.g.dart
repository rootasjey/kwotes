// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topics_colors.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicsColors on TopicsColorsBase, Store {
  final _$topicsColorsAtom = Atom(name: 'TopicsColorsBase.topicsColors');

  @override
  List<TopicColor> get topicsColors {
    _$topicsColorsAtom.context.enforceReadPolicy(_$topicsColorsAtom);
    _$topicsColorsAtom.reportObserved();
    return super.topicsColors;
  }

  @override
  set topicsColors(List<TopicColor> value) {
    _$topicsColorsAtom.context.conditionallyRunInAction(() {
      super.topicsColors = value;
      _$topicsColorsAtom.reportChanged();
    }, _$topicsColorsAtom, name: '${_$topicsColorsAtom.name}_set');
  }

  final _$fetchTopicsColorsAsyncAction = AsyncAction('fetchTopicsColors');

  @override
  Future<dynamic> fetchTopicsColors() {
    return _$fetchTopicsColorsAsyncAction.run(() => super.fetchTopicsColors());
  }

  final _$TopicsColorsBaseActionController =
      ActionController(name: 'TopicsColorsBase');

  @override
  void setColors(List<TopicColor> topics) {
    final _$actionInfo = _$TopicsColorsBaseActionController.startAction();
    try {
      return super.setColors(topics);
    } finally {
      _$TopicsColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'topicsColors: ${topicsColors.toString()}';
    return '{$string}';
  }
}
