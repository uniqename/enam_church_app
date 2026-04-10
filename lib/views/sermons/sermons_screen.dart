import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sermon.dart';
import '../../services/sermon_service.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final _service = SermonService();
  final _authService = AuthService();
  final _player = AudioPlayer();

  List<Sermon> _sermons = [];
  bool _loading = true;
  bool _isAdmin = false;

  String? _playingId;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Track expanded YouTube embeds and their WebView controllers
  final Map<String, bool> _expandedCards = {};
  final Map<String, WebViewController> _controllers = {};

  // ── URL helpers ─────────────────────────────────────────────────────────────
  static String? _youTubeVideoId(String url) {
    final patterns = [
      RegExp(r'youtube\.com/watch\?.*v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(url);
      if (m != null) return m.group(1);
    }
    return null;
  }

  static bool _isFacebookUrl(String url) =>
      url.contains('facebook.com') || url.contains('fb.watch');

  static bool _isInstagramUrl(String url) => url.contains('instagram.com');

  WebViewController _getController(String sermonId, String embedUrl) {
    return _controllers.putIfAbsent(sermonId, () {
      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(embedUrl));
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _playingId = null; _isPlaying = false; _position = Duration.zero; });
    });
  }

  Future<void> _init() async {
    final role = await _authService.getUserRole();
    final sermons = await _service.getAllSermons();
    if (mounted) {
      setState(() {
        _isAdmin = role == 'admin' || role == 'pastor';
        _sermons = sermons;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause(Sermon sermon) async {
    if (_playingId == sermon.id && _isPlaying) {
      await _player.pause();
      return;
    }
    if (_playingId == sermon.id && !_isPlaying) {
      await _player.resume();
      return;
    }

    // Switch to new sermon
    await _player.stop();
    setState(() { _playingId = sermon.id; _position = Duration.zero; });

    final file = File(sermon.filePath);
    if (await file.exists()) {
      await _player.play(DeviceFileSource(sermon.filePath));
    } else if (sermon.fileUrl.isNotEmpty) {
      await _player.play(UrlSource(sermon.fileUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio file not found')),
        );
      }
    }
  }

  Future<void> _showAddEditDialog({Sermon? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final speakerCtrl = TextEditingController(text: existing?.speaker ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final urlCtrl = TextEditingController(text: existing?.fileUrl ?? '');
    DateTime selectedDate = existing?.date ?? DateTime.now();
    String? pickedPath = existing?.filePath.isNotEmpty == true ? existing?.filePath : null;
    String fileType = existing?.fileType ?? 'audio';
    String audience = existing?.audience ?? 'all';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'Add Sermon' : 'Edit Sermon'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Sermon Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: speakerCtrl,
                  decoration: const InputDecoration(labelText: 'Speaker / Preacher'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.purple),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMMM d, yyyy').format(selectedDate)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setS(() => selectedDate = picked);
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Streaming URL (YouTube, SoundCloud, direct mp3…)',
                    hintText: 'https://…',
                    prefixIcon: Icon(Icons.link),
                    helperText: 'Add a URL so all members can access this sermon',
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (v) {
                    final trimmed = v.trim();
                    final ext = trimmed.split('?').first.split('.').last.toLowerCase();
                    if (_youTubeVideoId(trimmed) != null ||
                        _isFacebookUrl(trimmed) ||
                        _isInstagramUrl(trimmed) ||
                        ['mp4', 'mov', 'm4v'].contains(ext)) {
                      setS(() => fileType = 'video');
                    } else if (trimmed.isNotEmpty) {
                      setS(() => fileType = 'audio');
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: Text(pickedPath != null
                      ? pickedPath!.split('/').last
                      : 'Pick MP3 or MP4 file'),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['mp3', 'mp4', 'm4a', 'wav', 'aac'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final path = result.files.single.path!;
                      final ext = path.split('.').last.toLowerCase();
                      setS(() {
                        pickedPath = path;
                        fileType = (ext == 'mp4') ? 'video' : 'audio';
                      });
                    }
                  },
                ),
                if (pickedPath != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('✅ File will be uploaded to cloud — all members can access it.',
                        style: TextStyle(fontSize: 11, color: Colors.green)),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: audience,
                  decoration: const InputDecoration(labelText: 'Audience', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people)),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Everyone (Adults + Kids)')),
                    DropdownMenuItem(value: 'adults', child: Text('Adults Only')),
                  ],
                  onChanged: (v) => setS(() => audience = v ?? 'all'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final speaker = speakerCtrl.text.trim();
                final url = urlCtrl.text.trim();
                if (title.isEmpty || speaker.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and speaker are required')),
                  );
                  return;
                }
                if (url.isEmpty && pickedPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add a streaming URL or pick a local file')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                // Upload picked file to Supabase Storage so all members can access it
                String storedPath = '';
                String finalUrl = url;
                if (pickedPath != null) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(const SnackBar(content: Text('Uploading media…'), duration: Duration(seconds: 30)));
                  final ext = pickedPath!.split('.').last.toLowerCase();
                  final contentType = (ext == 'mp4' || ext == 'mov') ? 'video/mp4' : 'audio/mpeg';
                  final uploaded = await SupabaseService().uploadImage(
                    'sermon-media', '${const Uuid().v4()}.$ext', File(pickedPath!), contentType: contentType,
                  );
                  messenger.hideCurrentSnackBar();
                  if (uploaded != null) {
                    finalUrl = uploaded;
                    messenger.showSnackBar(const SnackBar(content: Text('Media uploaded — all members can access it'), backgroundColor: Colors.green));
                  } else {
                    try { storedPath = await _service.copyFileToSermonStorage(pickedPath!); } catch (_) { storedPath = pickedPath!; }
                    messenger.showSnackBar(const SnackBar(content: Text('Saved locally (only visible on this device)'), backgroundColor: Colors.orange));
                  }
                }

                if (existing == null) {
                  final s = Sermon.create(
                    title: title,
                    speaker: speaker,
                    date: selectedDate,
                    filePath: storedPath,
                    fileUrl: finalUrl,
                    fileType: fileType,
                    description: descCtrl.text.trim(),
                    audience: audience,
                  );
                  await _service.addSermon(s);
                } else {
                  await _service.updateSermon(existing.copyWith(
                    title: title,
                    speaker: speaker,
                    date: selectedDate,
                    filePath: storedPath.isNotEmpty ? storedPath : existing.filePath,
                    fileUrl: finalUrl,
                    fileType: fileType,
                    description: descCtrl.text.trim(),
                    audience: audience,
                  ));
                }
                await _init();
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Sermon sermon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sermon'),
        content: Text('Delete "${sermon.title}" by ${sermon.speaker}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (_playingId == sermon.id) await _player.stop();
      await _service.deleteSermon(sermon.id);
      await _init();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermons'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Sermon'),
              onPressed: () => _showAddEditDialog(),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sermons.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No sermons yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  itemCount: _sermons.length,
                  itemBuilder: (ctx, i) => _buildSermonCard(_sermons[i]),
                ),
    );
  }

  Widget _buildSermonCard(Sermon sermon) {
    final isThisPlaying = _playingId == sermon.id;
    final url = sermon.fileUrl;
    final ytId = _youTubeVideoId(url);
    final isFb = _isFacebookUrl(url);
    final isIg = _isInstagramUrl(url);
    final isStream = ytId != null || isFb || isIg;
    final isAudio = !isStream && sermon.fileType == 'audio';
    final isExpanded = _expandedCards[sermon.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isThisPlaying || isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isThisPlaying || isExpanded
            ? const BorderSide(color: AppColors.purple, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                  radius: 22,
                  child: Icon(
                    ytId != null
                        ? Icons.smart_display
                        : isFb
                            ? Icons.facebook
                            : isIg
                                ? Icons.camera_alt
                                : isAudio
                                    ? Icons.headphones
                                    : Icons.videocam,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sermon.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(sermon.speaker,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Text(
                        DateFormat('MMMM d, yyyy').format(sermon.date),
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: AppColors.purple,
                    onPressed: () => _showAddEditDialog(existing: sermon),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    onPressed: () => _confirmDelete(sermon),
                    tooltip: 'Delete',
                  ),
                ],
              ],
            ),
          ),
          if (sermon.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(sermon.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),

          // ── Playback area ────────────────────────────────────────────────
          if (ytId != null) ...[
            // YouTube: thumbnail thumbnail → expands to embed
            GestureDetector(
              onTap: () => setState(() =>
                  _expandedCards[sermon.id] = !isExpanded),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: isExpanded
                        ? BorderRadius.zero
                        : const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                    child: isExpanded
                        ? SizedBox(
                            height: 220,
                            child: WebViewWidget(
                              controller: _getController(
                                sermon.id,
                                'https://www.youtube.com/embed/$ytId?autoplay=1&playsinline=1',
                              ),
                            ),
                          )
                        : Image.network(
                            'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: Colors.black87,
                              child: const Icon(Icons.smart_display,
                                  color: Colors.white, size: 48),
                            ),
                          ),
                  ),
                  if (!isExpanded)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 36),
                    ),
                  if (isExpanded)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _expandedCards[sermon.id] = false),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else if (isFb || isIg) ...[
            // Facebook / Instagram — open externally
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(isFb ? Icons.facebook : Icons.camera_alt,
                      size: 18),
                  label: Text(
                      'Watch on ${isFb ? 'Facebook' : 'Instagram'}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    side: const BorderSide(color: AppColors.purple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(url);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
            ),
          ] else if (isAudio) ...[
            // Audio player
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isThisPlaying && _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 40,
                      color: AppColors.purple,
                    ),
                    onPressed: () => _playPause(sermon),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Slider(
                          value: isThisPlaying && _duration.inSeconds > 0
                              ? _position.inSeconds
                                  .toDouble()
                                  .clamp(0, _duration.inSeconds.toDouble())
                              : 0,
                          min: 0,
                          max: isThisPlaying && _duration.inSeconds > 0
                              ? _duration.inSeconds.toDouble()
                              : 1,
                          activeColor: AppColors.purple,
                          onChanged: isThisPlaying
                              ? (val) =>
                                  _player.seek(Duration(seconds: val.toInt()))
                              : null,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isThisPlaying
                                  ? _formatDuration(_position)
                                  : '0:00',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              isThisPlaying && _duration > Duration.zero
                                  ? _formatDuration(_duration)
                                  : '',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (url.isNotEmpty) ...[
            // Direct video URL — open in WebView
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Watch Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    side: const BorderSide(color: AppColors.purple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(url);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
