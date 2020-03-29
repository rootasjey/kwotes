// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_fav.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserFav on UserFavBase, Store {
  final _$updatedAtAtom = Atom(name: 'UserFavBase.updatedAt');

  @override
  DateTime get updatedAt {
    _$updatedAtAtom.context.enforceReadPolicy(_$updatedAtAtom);
    _$updatedAtAtom.reportObserved();
    return super.updatedAt;
  }

  @override
  set updatedAt(DateTime value) {
    _$updatedAtAtom.context.conditionallyRunInAction(() {
      super.updatedAt = value;
      _$updatedAtAtom.reportChanged();
    }, _$updatedAtAtom, name: '${_$updatedAtAtom.name}_set');
  }

  final _$UserFavBaseActionController = ActionController(name: 'UserFavBase');

  @override
  void updateDate() {
    final _$actionInfo = _$UserFavBaseActionController.startAction();
    try {
      return super.updateDate();
    } finally {
      _$UserFavBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'updatedAt: ${updatedAt.toString()}';
    return '{$string}';
  }
}
