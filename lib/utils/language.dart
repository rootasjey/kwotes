class Language {
  static String backend(String lang) {
    switch (lang) {
      case 'English':
        return 'en';
      case 'Français':
        return 'fr';
      default:
        return 'en';
    }
  }

  static String frontend(String lang) {
    switch (lang) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }
}
