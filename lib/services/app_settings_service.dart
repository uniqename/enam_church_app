import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings that admins can configure from within the app.
/// No API keys required — just URLs/links that admins paste in.
class AppSettingsService {
  static final AppSettingsService _i = AppSettingsService._();
  factory AppSettingsService() => _i;
  AppSettingsService._();

  static const _givelifyKey   = 'setting_givelify_url';
  static const _youtubeKey    = 'setting_youtube_url';
  static const _churchNameKey = 'setting_church_name';
  static const _churchWebKey  = 'setting_church_website';
  static const _zoomKey       = 'setting_default_zoom';
  static const _meetKey       = 'setting_default_gmeet';

  Future<String> givelifyUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_givelifyKey) ?? '';
  }

  Future<void> setGivelifyUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_givelifyKey, url);
  }

  Future<String> youtubeUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_youtubeKey) ?? '';
  }

  Future<void> setYoutubeUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_youtubeKey, url);
  }

  Future<String> churchName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_churchNameKey) ?? 'Faith Klinik Ministries';
  }

  Future<void> setChurchName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_churchNameKey, name);
  }

  Future<String> churchWebsite() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_churchWebKey) ?? '';
  }

  Future<void> setChurchWebsite(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_churchWebKey, url);
  }

  Future<String> defaultZoomLink() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_zoomKey) ?? 'https://zoom.us/j/6193422249';
  }

  Future<void> setDefaultZoomLink(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_zoomKey, url);
  }

  Future<String> defaultGoogleMeetLink() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_meetKey) ?? '';
  }

  Future<void> setDefaultGoogleMeetLink(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_meetKey, url);
  }

  /// Returns all settings as a map for the admin settings screen
  Future<Map<String, String>> getAllSettings() async {
    final p = await SharedPreferences.getInstance();
    return {
      'givelify_url':     p.getString(_givelifyKey)   ?? '',
      'youtube_url':      p.getString(_youtubeKey)    ?? '',
      'church_name':      p.getString(_churchNameKey) ?? 'Faith Klinik Ministries',
      'church_website':   p.getString(_churchWebKey)  ?? '',
      'default_zoom':     p.getString(_zoomKey)       ?? 'https://zoom.us/j/6193422249',
      'default_gmeet':    p.getString(_meetKey)       ?? '',
    };
  }

  Future<void> saveAllSettings(Map<String, String> settings) async {
    final p = await SharedPreferences.getInstance();
    for (final e in settings.entries) {
      await p.setString('setting_${e.key}', e.value);
    }
  }
}
