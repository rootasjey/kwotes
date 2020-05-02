import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';

class AppLocalStorage {
  static LocalStorageInterface _localStorage;

  Future initialize() async {
    if (_localStorage != null) { return; }
    _localStorage = await LocalStorage.getInstance();
  }

  bool getAutoBrightness() {
    return _localStorage.getBool('autoBrightness') ?? true;
  }

  Brightness getBrightness() {
    final brightness = _localStorage.getString('brightness') == 'dark' ?
      Brightness.dark : Brightness.light;

    return brightness;
  }

  Map<String, String> getCredentials() {
    final credentials = Map<String, String>();

    credentials['email'] = _localStorage.getString('email');
    credentials['password'] = _localStorage.getString('password');

    return credentials;
  }

  String getLang() => _localStorage.getString('lang') ?? 'en';

  void saveAutoBrightness(bool value) {
    _localStorage.setBool('autoBrightness', value);
  }

  void saveBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage.setString('strBrightness', strBrightness);
  }

  void saveDraft({String draftString}) {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];

    drafts.add(draftString);
    _localStorage.setStringList('drafts', drafts);
  }

  void savedDraftsState(List<String> drafts) {
    _localStorage.setStringList('drafts', drafts);
  }

  void clearDrafts() {
    List<String> drafts = [];
    _localStorage.setStringList('drafts', drafts);
  }

  List<String> getDrafts() {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];
    return drafts;
  }

  void saveEmail(String email) => _localStorage.setString('email', email);
  void saveLang(String lang) => _localStorage.setString('lang', lang);

  void saveCredentials({String email, String password}) {
    _localStorage.setString('email', email);
    _localStorage.setString('password', password);
  }

  void saveQuotidiansLang(String lang) => _localStorage.setString('quotidians_lang', lang);

  String getQuotidiansLang() => _localStorage.getString('quotidians_lang') ?? 'en';

  void saveUserName(String userName) => _localStorage.setString('username', userName);

  String getUserName() => _localStorage.getString('username') ?? '';

  void saveUserUid(String userName) => _localStorage.setString('user_uid', userName);

  String getUserUid() => _localStorage.getString('user_uid') ?? '';

  Future clearUserAuthData() async {
    await _localStorage.remove('username');
    await _localStorage.remove('email');
    await _localStorage.remove('password');
    await _localStorage.remove('user_uid');
  }

  void saveQuotidianNotif(bool active) {
    _localStorage.setBool('quotidian_notif', active);
  }

  bool getQuotidianNotif() {
    return _localStorage.getBool('quotidian_notif') ?? false;
  }
}

final appLocalStorage = AppLocalStorage();
