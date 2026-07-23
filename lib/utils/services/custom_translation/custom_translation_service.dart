import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/custom_translation/i_custom_translation_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

class TbCustomTranslationService implements ICustomTranslationService {
  static final _i18nRegExp = RegExp(r'\{i18n:([^{}]+)\}');

  Map<String, dynamic> _translations = const {};

  @override
  Future<void> load({String? localeCode}) async {
    final code = (localeCode == null || localeCode.isEmpty) ? 'en_US' : localeCode;
    try {
      final response = await getIt<ITbClientService>()
          .client
          .get<Map<String, dynamic>>('/api/translation/full/$code');
      _translations = response.data ?? const {};
    } catch (e) {
      getIt<TbLogger>().debug('Failed to load custom translations: $e');
      _translations = const {};
    }
  }

  @override
  String translate(String? value) {
    if (value == null || value.isEmpty) {
      return value ?? '';
    }
    if (!value.contains('{i18n:')) {
      return value;
    }
    return value.replaceAllMapped(_i18nRegExp, (match) {
      final key = match.group(1);
      if (key == null || key.isEmpty) {
        return match.group(0)!;
      }
      final translated = _lookup(key);
      return translated ?? match.group(0)!;
    });
  }

  @override
  void clear() {
    _translations = const {};
  }

  String? _lookup(String key) {
    dynamic current = _translations;
    for (final part in key.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current is String ? current : null;
  }
}
