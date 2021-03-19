import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/utils/storage_keys.dart';
import 'package:flutter/material.dart';

class AppStorage {
  static LocalStorageInterface _localStorage;

  // / --------------- /
  // /     General     /
  // / --------------- /
  bool containsKey(String key) => _localStorage.containsKey(key);

  String getString(String key) => _localStorage.getString(key);

  bool getBool(String key) => _localStorage.getBool(key);

  Future initialize() async {
    if (_localStorage != null) {
      return;
    }
    _localStorage = await LocalStorage.getInstance();
  }

  Future<bool> setBool(String key, bool value) =>
      _localStorage.setBool(key, value);

  Future<bool> setString(String key, String value) =>
      _localStorage.setString(key, value);

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

  int getMaxQuestions() => _localStorage.getInt(StorageKeys.maxQuestions) ?? 10;

  bool isQuotidianNotifActive() {
    return _localStorage.getBool('is_quotidian_notif_active') ?? true;
  }

  String getUserName() => _localStorage.getString(StorageKeys.username) ?? '';
  String getUserUid() => _localStorage.getString(StorageKeys.userUid) ?? '';

  void setCredentials({String email, String password}) {
    _localStorage.setString(StorageKeys.email, email);
    _localStorage.setString(StorageKeys.password, password);
  }

  void setEmail(String email) {
    _localStorage.setString(StorageKeys.email, email);
  }

  void setPassword(String password) {
    _localStorage.setString(StorageKeys.password, password);
  }

  void setLang(String lang) => _localStorage.setString(StorageKeys.lang, lang);

  void setMaxQuestions(int max) =>
      _localStorage.setInt(StorageKeys.maxQuestions, max);

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
