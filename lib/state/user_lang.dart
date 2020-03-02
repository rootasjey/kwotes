import 'package:mobx/mobx.dart';

part 'user_lang.g.dart';

class UserLang = UserLangBase with _$UserLang;

abstract class UserLangBase with Store {
  @observable
  String current = 'en';

  @action
  void setLang(String lang) {
    current = lang;
  }
}

final appUserLang = UserLang();
