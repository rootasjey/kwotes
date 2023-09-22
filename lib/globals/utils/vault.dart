import "package:glutton/glutton.dart";
import "package:kwotes/types/credentials.dart";
import "package:kwotes/globals/constants/storage_keys.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_search_entity.dart";

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

  Future<bool> saveLastSearchType(EnumSearchEntity searchEntity) async {
    return Glutton.eat(StorageKeys.lastSearchType, searchEntity.index);
  }

  Future<EnumSearchEntity> getLastSearchType() async {
    final int index = await Glutton.vomit(
      StorageKeys.lastSearchType,
      EnumSearchEntity.quote.index,
    );

    return EnumSearchEntity.values[index];
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
  Future<String> getLanguage() async {
    return await Glutton.vomit(StorageKeys.language, "en");
  }

  /// Saves the app language.
  void setLanguage(String locale) {
    Glutton.eat(StorageKeys.language, locale);
  }
}
