import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../models/sermon.dart';
import '../../services/sermon_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import 'video_player_screen.dart';

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
    DateTime selectedDate = existing?.date ?? DateTime.now();
    String? pickedPath = existing?.filePath;
    String fileType = existing?.fileType ?? 'audio';

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
                if (title.isEmpty || speaker.isEmpty || pickedPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title, speaker and file are required')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                // Copy file to app storage
                String storedPath = pickedPath!;
                try {
                  storedPath = await _service.copyFileToSermonStorage(pickedPath!);
                } catch (_) {}

                if (existing == null) {
                  final s = Sermon.create(
                    title: title,
                    speaker: speaker,
                    date: selectedDate,
                    filePath: storedPath,
                    fileType: fileType,
                    description: descCtrl.text.trim(),
                  );
                  await _service.addSermon(s);
                } else {
                  await _service.updateSermon(existing.copyWith(
                    title: title,
                    speaker: speaker,
                    date: selectedDate,
                    filePath: storedPath,
                    fileType: fileType,
                    description: descCtrl.text.trim(),
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
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentPurple,
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
    final isAudio = sermon.fileType == 'audio';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isThisPlaying ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isThisPlaying
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  radius: 22,
                  child: Icon(
                    isAudio ? Icons.headphones : Icons.videocam,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sermon.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(sermon.speaker,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                      Text(
                        DateFormat('MMMM d, yyyy').format(sermon.date),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
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
            if (sermon.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(sermon.description,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
            ],
            if (isAudio) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isThisPlaying && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
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
                              ? _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble())
                              : 0,
                          min: 0,
                          max: isThisPlaying && _duration.inSeconds > 0
                              ? _duration.inSeconds.toDouble()
                              : 1,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: isThisPlaying
                              ? (val) => _player.seek(Duration(seconds: val.toInt()))
                              : null,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isThisPlaying ? _formatDuration(_position) : '0:00',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              isThisPlaying && _duration > Duration.zero
                                  ? _formatDuration(_duration)
                                  : '',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Open Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: sermon))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
