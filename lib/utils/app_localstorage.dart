import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';

class AppLocalStorage {
  static LocalStorageInterface _localStorage;

  void clearDrafts() {
    List<String> drafts = [];
    _localStorage.setStringList('drafts', drafts);
  }

  Future clearUserAuthData() async {
    await _localStorage.remove('username');
    await _localStorage.remove('email');
    await _localStorage.remove('password');
    await _localStorage.remove('user_uid');
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

  List<String> getDrafts() {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];
    return drafts;
  }

  String getLang() => _localStorage.getString('lang') ?? 'en';

  String getQuotidiansLang() => _localStorage.getString('quotidians_lang') ?? 'en';
  bool getQuotidianNotif() => _localStorage.getBool('quotidian_notif') ?? false;

  String getUserName() => _localStorage.getString('username') ?? '';
  String getUserUid() => _localStorage.getString('user_uid') ?? '';

  Future initialize() async {
    if (_localStorage != null) { return; }
    _localStorage = await LocalStorage.getInstance();
  }

  void saveAutoBrightness(bool value) {
    _localStorage.setBool('autoBrightness', value);
  }

  void saveBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage.setString('strBrightness', strBrightness);
  }

  void saveCredentials({String email, String password}) {
    _localStorage.setString('email', email);
    _localStorage.setString('password', password);
  }

  void saveDraft({String draftString}) {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];

    drafts.add(draftString);
    _localStorage.setStringList('drafts', drafts);
  }

  void savedDraftsState(List<String> drafts) {
    _localStorage.setStringList('drafts', drafts);
  }

  void saveEmail(String email) => _localStorage.setString('email', email);
  void saveLang(String lang) => _localStorage.setString('lang', lang);

  void saveQuotidiansLang(String lang) => _localStorage.setString('quotidians_lang', lang);

  void saveQuotidianNotif(bool active) {
    _localStorage.setBool('quotidian_notif', active);
  }

  void saveUserName(String userName) => _localStorage.setString('username', userName);

  void saveUserUid(String userName) => _localStorage.setString('user_uid', userName);
}

final appLocalStorage = AppLocalStorage();
