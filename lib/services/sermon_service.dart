import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sermon.dart';

class SermonService {
  static const _kSermonsKey = 'local_sermons';
  static const _kSeededKey = 'sermons_jasper_seeded_v1';

  Future<List<Sermon>> getAllSermons() async {
    await _seedJasperSermon();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSermonsKey) ?? [];
    final sermons = raw
        .map((s) => Sermon.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sermons;
  }

  Future<Sermon> addSermon(Sermon sermon) async {
    final all = await _rawList();
    all.add(sermon);
    await _saveAll(all);
    return sermon;
  }

  Future<void> updateSermon(Sermon sermon) async {
    final all = await _rawList();
    final idx = all.indexWhere((s) => s.id == sermon.id);
    if (idx != -1) all[idx] = sermon;
    await _saveAll(all);
  }

  Future<void> deleteSermon(String id) async {
    final all = await _rawList();
    all.removeWhere((s) => s.id == id);
    await _saveAll(all);
  }

  Future<String> copyFileToSermonStorage(String sourcePath) async {
    final dir = await _sermonsDirectory();
    final fileName = sourcePath.split('/').last;
    final dest = '${dir.path}/$fileName';
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(dest);
    }
    return dest;
  }

  Future<Directory> _sermonsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/sermons');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _seedJasperSermon() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeededKey) == true) return;

    // Look for the file in common locations
    final candidates = [
      '/Users/enamegyir/Downloads/Bro JASPER.mp3',
    ];

    String localPath = '';
    for (final c in candidates) {
      if (await File(c).exists()) {
        try {
          localPath = await copyFileToSermonStorage(c);
        } catch (_) {
          localPath = c; // fallback: use original path
        }
        break;
      }
    }

    if (localPath.isEmpty) {
      // File not found yet — skip seed, try next launch
      return;
    }

    final sermon = Sermon.create(
      title: 'Sunday Sermon',
      speaker: 'Deacon Jasper',
      date: DateTime(2026, 3, 1),
      filePath: localPath,
      fileType: 'audio',
      description: '',
    );

    final all = await _rawList();
    all.add(sermon);
    await _saveAll(all);
    await prefs.setBool(_kSeededKey, true);
  }

  Future<List<Sermon>> _rawList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSermonsKey) ?? [];
    return raw.map((s) => Sermon.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _saveAll(List<Sermon> sermons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kSermonsKey,
      sermons.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
