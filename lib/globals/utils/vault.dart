import "package:flutter/foundation.dart";
import "package:glutton/glutton.dart";
import "package:kwotes/types/credentials.dart";
import "package:kwotes/globals/constants/storage_keys.dart";
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
      EnumSearchCategory.quote.index,
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

  /// Return the last saved value for app language.
  Future<EnumLanguageSelection> getLanguage() async {
    // return await Glutton.vomit(StorageKeys.language, "en");
    final int index = await Glutton.vomit(StorageKeys.language, 0);
    return EnumLanguageSelection.values[index];
  }

  /// Saves the app language.
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

  /// Return the last saved value for header options.
  Future<bool> geShowtHeaderOptions() async {
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
}
