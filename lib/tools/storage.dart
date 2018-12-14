import 'package:shared_preferences/shared_preferences.dart';

const String _kPrefix = '__tgm__';

class Storage {
  static final Storage _instance = Storage._();

  final _props = Map<String, String>();

  factory Storage() {
    return _instance;
  }

  Storage._();

  void set(String key, String value) {
    _props[key] = value;
  }

  String get(String key) {
    return _props[key];
  }

  void delete(String key) {
    _props.remove(key);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    keys.removeWhere((key) => key.indexOf(_kPrefix) == -1);

    keys.forEach((keyPrefixed) {
      final key = keyPrefixed.replaceAll(_kPrefix, '');
      _props[key] = prefs.getString(keyPrefixed);
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = _props.keys;

    for (String key in keys) {
      await prefs.setString('$_kPrefix$key', _props[key]);
    }
  }
}
