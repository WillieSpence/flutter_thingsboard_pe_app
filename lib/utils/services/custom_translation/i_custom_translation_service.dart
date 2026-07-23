abstract interface class ICustomTranslationService {
  Future<void> load({String? localeCode});

  String translate(String? value);

  void clear();
}
