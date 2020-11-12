import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/types/enums.dart';

class AppStorage {
  static LocalStorageInterface _localStorage;

  // / --------------- /
  // /     General     /
  // / --------------- /
  bool containsKey(String key) => _localStorage.containsKey(key);

  Future initialize() async {
    if (_localStorage != null) {
      return;
    }
    _localStorage = await LocalStorage.getInstance();
  }

  // / -----------------/
  // /   First launch   /
  // / -----------------/
  bool isFirstLanch() {
    return _localStorage.getBool(StorageKeys.firstLaunch) ?? true;
  }

  void setFirstLaunch({bool overrideValue}) {
    if (overrideValue != null) {
      _localStorage.setBool(StorageKeys.firstLaunch, overrideValue);
      return;
    }

    _localStorage.setBool(StorageKeys.firstLaunch, false);
  }

  // / --------------/
  // /     Drafts    /
  // /---------------/
  void clearDrafts() {
    List<String> drafts = [];
    _localStorage.setStringList(StorageKeys.drafts, drafts);
  }

  void saveDraft({String draftString}) {
    List<String> drafts = _localStorage.getStringList('drafts') ?? [];

    drafts.add(draftString);
    _localStorage.setStringList('drafts', drafts);
  }

  void setDrafts(List<String> drafts) {
    _localStorage.setStringList('drafts', drafts);
  }

  // / ---------------/
  // /      USER      /
  // /----------------/
  Future clearUserAuthData() async {
    await _localStorage.remove(StorageKeys.username);
    await _localStorage.remove(StorageKeys.email);
    await _localStorage.remove(StorageKeys.password);
    await _localStorage.remove(StorageKeys.userUid);
  }

  Map<String, String> getCredentials() {
    final credentials = Map<String, String>();

    credentials[StorageKeys.email] = _localStorage.getString(StorageKeys.email);
    credentials[StorageKeys.password] =
        _localStorage.getString(StorageKeys.password);

    return credentials;
  }

  String getLang() => _localStorage.getString(StorageKeys.lang) ?? 'en';

  bool isQuotidianNotifActive() {
    return _localStorage.getBool('is_quotidian_notif_active') ?? true;
  }

  String getUserName() => _localStorage.getString(StorageKeys.username) ?? '';
  String getUserUid() => _localStorage.getString(StorageKeys.userUid) ?? '';

  void setCredentials({String email, String password}) {
    _localStorage.setString(StorageKeys.email, email);
    _localStorage.setString(StorageKeys.password, password);
  }

  void setLang(String lang) => _localStorage.setString('lang', lang);

  void setQuotidianNotif(bool active) {
    _localStorage.setBool('is_quotidian_notif_active', active);
  }

  void setUserName(String userName) =>
      _localStorage.setString('username', userName);

  void setUserUid(String userName) =>
      _localStorage.setString('user_uid', userName);

  // / -------------------/
  // /     Brightness     /
  // / -------------------/
  bool getAutoBrightness() {
    return _localStorage.getBool(StorageKeys.autoBrightness) ?? true;
  }

  Brightness getBrightness() {
    final brightness = _localStorage.getString(StorageKeys.brightness) == 'dark'
        ? Brightness.dark
        : Brightness.light;

    return brightness;
  }

  void setAutoBrightness(bool value) {
    _localStorage.setBool(StorageKeys.autoBrightness, value);
  }

  void setBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage.setString(StorageKeys.brightness, strBrightness);
  }

  // / ----------------/
  // /      Layout     /
  // / ----------------/
  DiscoverType getDiscoverType() {
    final value = _localStorage.getString(StorageKeys.discoverType);
    return value == 'authors' ? DiscoverType.authors : DiscoverType.references;
  }

  List<String> getDrafts() {
    List<String> drafts = _localStorage.getStringList(StorageKeys.drafts) ?? [];
    return drafts;
  }

  ItemsLayout getItemsStyle(String pageRoute) {
    final itemsStyle =
        _localStorage.getString('${StorageKeys.itemsStyle}$pageRoute');

    switch (itemsStyle) {
      case StorageKeys.itemsLayoutGrid:
        return ItemsLayout.grid;
      case StorageKeys.itemsLayoutList:
        return ItemsLayout.list;
      default:
        return ItemsLayout.list;
    }
  }

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

  void saveDiscoverType(DiscoverType discoverType) {
    final value =
        discoverType == DiscoverType.authors ? 'authors' : 'references';

    _localStorage.setString('discover_type', value);
  }

  void saveItemsStyle({String pageRoute, ItemsLayout style}) {
    _localStorage.setString('items_style_$pageRoute', style.toString());
  }

  void setPageLang({String lang, String pageRoute}) {
    final key = '$pageRoute?lang';
    _localStorage.setString(key, lang);
  }

  void setPageOrder({bool descending, String pageRoute}) {
    final key = '$pageRoute?order';
    _localStorage.setBool(key, descending);
  }
}

final appStorage = AppStorage();
