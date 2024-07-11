import "package:flutter/foundation.dart";
import "package:glutton/glutton.dart";
import "package:kwotes/types/credentials.dart";
import "package:kwotes/globals/constants/storage_keys.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_search_category.dart";

class Vault {
  Future<bool> clearCredentials() {
    return Future.wait([
      Glutton.digest(StorageKeys.username),
      Glutton.digest(StorageKeys.email),
      Glutton.digest(StorageKeys.password),
      Glutton.digest(StorageKeys.userUid),
    ]).then((value) => value.every((bool success) => success));
  }

  Future<Credentials> getCredentials() async {
    String email = "";
    String password = "";

    if (await Glutton.have(StorageKeys.email)) {
      email = await Glutton.vomit(StorageKeys.email);
    }

    if (await Glutton.have(StorageKeys.password)) {
      password = await Glutton.vomit(StorageKeys.password);
    }

    return Credentials(
      email: email,
      password: password,
    );
  }

  void setCredentials({
    required String email,
    required String password,
  }) async {
    await Future.wait([
      Glutton.eat(StorageKeys.email, email),
      Glutton.eat(StorageKeys.password, password),
    ]);
  }

  Future<bool> setBool(String key, bool value) async {
    return await Glutton.eat(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return await Glutton.vomit(key, defaultValue);
  }

  void setPassword(String password) async {
    await Glutton.eat(StorageKeys.password, password);
  }

  Future<bool> getHeroImageControlsVisible() async {
    return await Glutton.vomit(StorageKeys.heroImageControlVivisible, true);
  }

  void setHeroImageControlsVisible(bool newValue) {
    Glutton.eat(StorageKeys.heroImageControlVivisible, newValue);
  }

  Future<bool> saveLastSearchCategory(EnumSearchCategory searchEntity) async {
    return Glutton.eat(StorageKeys.lastSearchType, searchEntity.index);
  }

  Future<EnumSearchCategory> getLastSearchCategory() async {
    final int index = await Glutton.vomit(
      StorageKeys.lastSearchType,
      EnumSearchCategory.quotes.index,
    );

    return EnumSearchCategory.values[index];
  }

  /// Return the saved value for language selection.
  /// Default to `auto detect`.
  Future<EnumLanguageSelection> getLanguageSelection() async {
    final int index = await Glutton.vomit(
      StorageKeys.quoteLanguageSelection,
      EnumLanguageSelection.autoDetect.index,
    );

    return EnumLanguageSelection.values[index];
  }

  /// Saves the language selection.
  void setQuoteLanguageSelection(EnumLanguageSelection languageSelection) {
    Glutton.eat(StorageKeys.quoteLanguageSelection, languageSelection.index);
  }

  /// Return the saved value for author quotes language selection.
  Future<EnumLanguageSelection> getAuthorQuotesLanguage() async {
    final int index = await Glutton.vomit(
      StorageKeys.authorQuotesLanguageSelection,
      EnumLanguageSelection.en.index,
    );

    return EnumLanguageSelection.values[index];
  }

  /// Saves the author quotes language selection.
  void setAuthorQuotesLanguage(EnumLanguageSelection languageSelection) {
    Glutton.eat(
      StorageKeys.authorQuotesLanguageSelection,
      languageSelection.index,
    );
  }

  /// Return the saved value for reference quotes language selection.
  Future<EnumLanguageSelection> getReferenceQuotesLanguage() async {
    final int index = await Glutton.vomit(
      StorageKeys.referenceQuotesLanguageSelection,
      EnumLanguageSelection.en.index,
    );

    return EnumLanguageSelection.values[index];
  }

  /// Saves the reference quotes language selection.
  void setReferenceQuotesLanguage(EnumLanguageSelection languageSelection) {
    Glutton.eat(
      StorageKeys.referenceQuotesLanguageSelection,
      languageSelection.index,
    );
  }

  /// Return the last saved value for app language.
  /// Retrieve the index of EnumLanguageSelection and return enum value.
  Future<EnumLanguageSelection> getLanguage() async {
    final int index = await Glutton.vomit(StorageKeys.language, 0);
    return EnumLanguageSelection.values[index];
  }

  /// Saves the app language.
  /// Use index of EnumLanguageSelection.
  void setLanguage(EnumLanguageSelection locale) {
    Glutton.eat(StorageKeys.language, locale.index);
  }

  /// Return the last saved value for page language (e.g. published quotes page).
  /// Default to `all`. Can also be `en`, `fr`, etc.
  Future<EnumLanguageSelection> getPageLanguage() async {
    final int index = await Glutton.vomit(StorageKeys.selectedPageLanguage, 0);
    return EnumLanguageSelection.values[index];
  }

  /// Saves page language (e.g. published quotes page).
  void setPageLanguage(EnumLanguageSelection locale) {
    Glutton.eat(StorageKeys.selectedPageLanguage, locale.index);
  }

  /// Return the last saved value for header page options visibility.
  Future<bool> geShowtHeaderPageOptions() async {
    return await Glutton.vomit(StorageKeys.showHeaderOptions, true);
  }

  /// Saves header options state.
  void setShowHeaderOptions(bool value) {
    Glutton.eat(StorageKeys.showHeaderOptions, value);
  }

  /// Return the last saved value for header options.
  Future<EnumDataOwnership> getDataOwnership() async {
    final int savedIndex = await Glutton.vomit(
        StorageKeys.dataOwnership, EnumDataOwnership.owned.index);

    return EnumDataOwnership.values[savedIndex];
  }

  /// Saves header options state.
  void setDataOwnership(EnumDataOwnership ownership) {
    Glutton.eat(StorageKeys.dataOwnership, ownership.index);
  }

  void setHomePageTabIndex(int index) {
    Glutton.eat(StorageKeys.homePageTabIndex, index);
  }

  Future<int> getHomePageTabIndex() async {
    return await Glutton.vomit(StorageKeys.homePageTabIndex, 0);
  }

  /// Return the last saved value for my quotes page tab index.
  Future<int> getMyQuotesPageTabIndex() async {
    return await Glutton.vomit(StorageKeys.myQuotesPageTabIndex, 0);
  }

  /// Saves my quotes page tab index.
  void setMyQuotesPageTabIndex(int index) {
    Glutton.eat(StorageKeys.myQuotesPageTabIndex, index);
  }

  void setAuthorMetadataOpened(bool isOpen) {
    Glutton.eat(StorageKeys.authorMetadataOpened, isOpen);
  }

  Future<bool> getAuthorMetadataOpened() async {
    return await Glutton.vomit(
      StorageKeys.authorMetadataOpened,
      true,
    );
  }

  void setReferenceMetadataOpened(bool isOpen) {
    Glutton.eat(StorageKeys.referenceMetadataOpened, isOpen);
  }

  Future<bool> getReferenceMetadataOpened() async {
    return await Glutton.vomit(
      StorageKeys.referenceMetadataOpened,
      true,
    );
  }

  void setAddAuthorMetadataOpened(bool isOpen) {
    Glutton.eat(StorageKeys.addAuthorMetadataOpened, isOpen);
  }

  Future<bool> getAddAuthorMetadataOpened() async {
    return await Glutton.vomit(
      StorageKeys.addAuthorMetadataOpened,
      true,
    );
  }

  void setAddReferenceMetadataOpened(bool isOpen) {
    Glutton.eat(StorageKeys.addAuthorMetadataOpened, isOpen);
  }

  Future<bool> getAddReferenceMetadataOpened() async {
    return await Glutton.vomit(
      StorageKeys.addAuthorMetadataOpened,
      true,
    );
  }

  void setBrightness(Brightness brightness) {
    Glutton.eat(StorageKeys.brightness, brightness.index);
  }

  Future<Brightness> getBrightness() async {
    final int index = await Glutton.vomit(
      StorageKeys.brightness,
      Brightness.light.index,
    );

    return Brightness.values[index];
  }

  /// Saves fullscreen quote page state.
  void setFullscreenQuotePage(bool isActive) {
    Glutton.eat(StorageKeys.fullscreenQuotePage, isActive);
  }

  /// Retrieves fullscreen quote page state.
  Future<bool> getFullscreenQuotePage() async {
    return await Glutton.vomit(
      StorageKeys.fullscreenQuotePage,
      true,
    );
  }

  /// Saves minimal quote actions state.
  void setMinimalQuoteActions(bool isActive) {
    Glutton.eat(StorageKeys.minimalQuoteActions, isActive);
  }

  /// Retrieves minimal quote actions state.
  Future<bool> getMinimalQuoteActions() async {
    return await Glutton.vomit(
      StorageKeys.minimalQuoteActions,
      false,
    );
  }

  /// Saves frame border color state.
  void setFrameBorderStyle(EnumFrameBorderStyle newValue) {
    Glutton.eat(StorageKeys.frameBorderStyle, newValue.index);
  }

  /// Retrieves frame border color state.
  Future<EnumFrameBorderStyle> getFrameBorderColored() async {
    final int index = await Glutton.vomit(
      StorageKeys.frameBorderStyle,
      EnumFrameBorderStyle.discrete.index,
    );

    return EnumFrameBorderStyle.values[index];
  }

  Future<bool> getShowSavedDraftTip() async {
    return await Glutton.vomit(StorageKeys.showSavedDraftTip, true);
  }

  void downtShowSaveDraftTip() {
    Glutton.eat(StorageKeys.showSavedDraftTip, true);
  }
}
