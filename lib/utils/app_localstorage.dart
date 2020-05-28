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

  String getPageLang({String pageRoute}) {
    final key = '$pageRoute?lang';
    final lang = _localStorage.getString(key);
    return lang ?? 'en';
  }

  bool getPageOrder({String pageRoute}) {
    final key = '$pageRoute?order';
    final descending = _localStorage.getBool(key);
    return descending ?? true;
  }

  bool isQuotidianNotifActive() {
    return _localStorage.getBool('is_quotidian_notif_active') ?? true;
  }

  String getUserName() => _localStorage.getString('username') ?? '';
  String getUserUid() => _localStorage.getString('user_uid') ?? '';

  Future initialize() async {
    if (_localStorage != null) { return; }
    _localStorage = await LocalStorage.getInstance();
  }

  bool isDeviceSubNotifActive() {
    return _localStorage.getBool('is_device_sub_notif_active') ?? false;
  }

  void setAutoBrightness(bool value) {
    _localStorage.setBool('autoBrightness', value);
  }

  void setBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage.setString('brightness', strBrightness);
  }

  void setCredentials({String email, String password}) {
    _localStorage.setString('email', email);
    _localStorage.setString('password', password);
  }

  void setDeviceSubNotif(bool value) {
    _localStorage.setBool('is_device_sub_notif_active', value);
  }

  void saveDraft({String draftString}) {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];

    drafts.add(draftString);
    _localStorage.setStringList('drafts', drafts);
  }

  void setDrafts(List<String> drafts) {
    _localStorage.setStringList('drafts', drafts);
  }

  void setLang(String lang) => _localStorage.setString('lang', lang);

  void setPageLang({String lang, String pageRoute}) {
    final key = '$pageRoute?lang';
    _localStorage.setString(key, lang);
  }

  void setPageOrder({bool descending, String pageRoute}) {
    final key = '$pageRoute?order';
    _localStorage.setBool(key, descending);
  }

  void setQuotidianNotif(bool active) {
    _localStorage.setBool('is_quotidian_notif_active', active);
  }

  void setUserName(String userName) => _localStorage.setString('username', userName);

  void setUserUid(String userName) => _localStorage.setString('user_uid', userName);
}

final appLocalStorage = AppLocalStorage();
