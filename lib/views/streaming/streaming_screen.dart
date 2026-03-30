import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/live_stream.dart';
import '../../services/stream_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  final _service = StreamService();
  final _auth = AuthService();
  List<LiveStream> _streams = [];
  bool _loading = true;
  bool _canManage = false;
  String _filter = 'all'; // all, live, upcoming, past

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait<dynamic>([
        _service.getAllStreams(),
        _auth.getUserRole(),
      ]);
      final role = results[1] as String?;
      setState(() {
        _streams = results[0] as List<LiveStream>;
        _canManage = role == 'admin' || role == 'pastor' ||
            role == 'dept_head' || role == 'media_team';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<LiveStream> get _filtered {
    if (_filter == 'all') return _streams;
    return _streams.where((s) => s.status.toLowerCase() == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Live & Streaming',
            style: TextStyle(
                color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.accentPurple),
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.accentPurple),
              onPressed: () => _showStreamDialog(null),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'Live', 'Upcoming', 'Past'].map((f) {
                  final selected = _filter == f || (_filter == 'all' && f == 'all');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f == 'all' ? 'all' : f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accentPurple.withOpacity(0.2)
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.accentPurple
                                : AppColors.darkBorder,
                          ),
                        ),
                        child: Text(
                          f == 'all' ? 'All' : f,
                          style: TextStyle(
                            color: selected
                                ? AppColors.accentPurple
                                : Colors.white54,
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accentPurple))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No streams found.',
                            style: TextStyle(color: Colors.white38)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.accentPurple,
                        backgroundColor: AppColors.darkSurface,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _StreamCard(
                            stream: _filtered[i],
                            canManage: _canManage,
                            onEdit: _canManage
                                ? () => _showStreamDialog(_filtered[i])
                                : null,
                            onDelete: _canManage
                                ? () => _deleteStream(_filtered[i])
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showStreamDialog(LiveStream? existing) {
    final titleC = TextEditingController(text: existing?.title);
    final urlC = TextEditingController(
        text: existing?.platformUrl.isNotEmpty == true
            ? existing!.platformUrl
            : existing?.streamUrl);
    final descC = TextEditingController(text: existing?.description);
    final timeC = TextEditingController(text: existing?.time ?? '9:00 AM');
    String platform = existing?.platform ?? 'youtube';
    String status = existing?.status ?? 'Upcoming';
    String category = existing?.category ?? 'Worship';
    DateTime date = existing?.date ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: Text(
          existing == null ? 'Schedule Stream' : 'Edit Stream',
          style: const TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(builder: (ctx2, setSt) {
          return SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Platform picker
                const Text('Platform',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _platformOptions.map((p) {
                    final selected = platform == p['id'];
                    final color = p['color'] as Color;
                    return GestureDetector(
                      onTap: () => setSt(() => platform = p['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.2)
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? color : AppColors.darkBorder,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(p['icon'] as IconData,
                              color: selected ? color : Colors.white38,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(p['label'] as String,
                              style: TextStyle(
                                color: selected ? color : Colors.white54,
                                fontSize: 13,
                              )),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _DarkField(controller: titleC, label: 'Title *'),
                const SizedBox(height: 10),
                _DarkField(controller: urlC, label: 'Stream URL / Meeting Link'),
                const SizedBox(height: 10),
                _DarkField(controller: descC, label: 'Description', maxLines: 2),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (_, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                  primary: AppColors.accentPurple),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) setSt(() => date = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.white54),
                          const SizedBox(width: 8),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _DarkField(controller: timeC, label: 'Time')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: AppColors.darkSurface2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkBorder)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkBorder)),
                      ),
                      items: ['Worship', 'Prayer', 'Teaching', 'Youth',
                        'Children', 'Special Event', 'Other']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setSt(() => category = v ?? 'Worship'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: AppColors.darkSurface2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkBorder)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkBorder)),
                      ),
                      items: ['Upcoming', 'Live', 'Past']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setSt(() => status = v ?? 'Upcoming'),
                    ),
                  ),
                ]),
              ]),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple),
            child: Text(existing == null ? 'Schedule' : 'Save'),
            onPressed: () async {
              if (titleC.text.trim().isEmpty) return;
              final url = urlC.text.trim();
              final stream = LiveStream(
                id: existing?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleC.text.trim(),
                date: date,
                time: timeC.text.trim(),
                status: status,
                viewers: existing?.viewers ?? 0,
                category: category,
                streamUrl: url,
                platform: platform,
                platformUrl: url,
                description: descC.text.trim(),
              );
              if (existing == null) {
                await _service.addStream(stream);
              } else {
                await _service.updateStream(stream);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStream(LiveStream s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Delete Stream?',
            style: TextStyle(color: Colors.white)),
        content: Text('Delete "${s.title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.deleteStream(s.id);
      _load();
    }
  }
}

// ── Platform definitions ───────────────────────────────────────────────────────
const _platformOptions = [
  {'id': 'youtube',    'label': 'YouTube',    'icon': Icons.play_circle_outline, 'color': AppColors.youtube},
  {'id': 'instagram',  'label': 'Instagram',  'icon': Icons.camera_alt_outlined,  'color': AppColors.instagram},
  {'id': 'facebook',   'label': 'Facebook',   'icon': Icons.facebook_outlined,    'color': AppColors.facebook},
  {'id': 'zoom',       'label': 'Zoom',       'icon': Icons.videocam_outlined,    'color': AppColors.zoom},
  {'id': 'google_meet','label': 'Meet',       'icon': Icons.video_call_outlined,  'color': AppColors.googleMeet},
  {'id': 'other',      'label': 'Other',      'icon': Icons.link_outlined,        'color': Colors.white54},
];

Color _platformColor(String p) {
  switch (p) {
    case 'youtube':     return AppColors.youtube;
    case 'instagram':   return AppColors.instagram;
    case 'facebook':    return AppColors.facebook;
    case 'zoom':        return AppColors.zoom;
    case 'google_meet': return AppColors.googleMeet;
    default:            return Colors.white54;
  }
}

IconData _platformIcon(String p) {
  switch (p) {
    case 'youtube':     return Icons.play_circle_outline;
    case 'instagram':   return Icons.camera_alt_outlined;
    case 'facebook':    return Icons.facebook_outlined;
    case 'zoom':        return Icons.videocam_outlined;
    case 'google_meet': return Icons.video_call_outlined;
    default:            return Icons.link_outlined;
  }
}

String _platformLabel(String p) {
  switch (p) {
    case 'youtube':     return 'YouTube';
    case 'instagram':   return 'Instagram';
    case 'facebook':    return 'Facebook';
    case 'zoom':        return 'Zoom';
    case 'google_meet': return 'Google Meet';
    default:            return 'Watch';
  }
}

// ── Stream Card ────────────────────────────────────────────────────────────────
class _StreamCard extends StatelessWidget {
  final LiveStream stream;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _StreamCard({
    required this.stream,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _openUrl(BuildContext ctx, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('No link provided yet.')));
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  Future<void> _copyLink(BuildContext ctx, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Link copied!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _platformColor(stream.platform);
    final isLive = stream.status == 'Live';
    final url = stream.platformUrl.isNotEmpty
        ? stream.platformUrl
        : stream.streamUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: pColor.withOpacity(isLive ? 0.25 : 0.08),
            blurRadius: isLive ? 18 : 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip with platform color
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: pColor.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(color: pColor.withOpacity(0.2))),
            ),
            child: Row(children: [
              Icon(_platformIcon(stream.platform), color: pColor, size: 20),
              const SizedBox(width: 8),
              Text(_platformLabel(stream.platform),
                  style: TextStyle(
                      color: pColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const Spacer(),
              _StatusBadge(status: stream.status),
              if (canManage) ...[
                const SizedBox(width: 4),
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined,
                        size: 16, color: Colors.white38),
                  ),
                const SizedBox(width: 8),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                  ),
              ],
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stream.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: Colors.white38),
                  const SizedBox(width: 5),
                  Text(
                    '${_dayLabel(stream.date)}, ${stream.time}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(stream.category,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ),
                ]),
                if (stream.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(stream.description,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),

                // Action buttons
                if (url.isNotEmpty)
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                            isLive
                                ? Icons.play_arrow
                                : Icons.open_in_new,
                            size: 18),
                        label: Text(isLive ? 'Watch Live' : 'Watch Now'),
                        onPressed: () => _openUrl(context, url),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: AppColors.darkBorder),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _copyLink(context, url),
                      child: const Icon(Icons.copy, size: 16),
                    ),
                  ])
                else if (canManage)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pColor,
                      side: BorderSide(color: pColor.withOpacity(0.4)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    icon: const Icon(Icons.add_link, size: 16),
                    label: const Text('Add Stream Link'),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final diff = d.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Live':
        color = AppColors.error;
        break;
      case 'Upcoming':
        color = AppColors.accentGold;
        break;
      default:
        color = Colors.white38;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (status == 'Live')
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          ),
        Text(status,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.darkSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentPurple),
        ),
      ),
    );
  }
}
