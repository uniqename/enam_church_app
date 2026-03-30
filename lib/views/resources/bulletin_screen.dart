import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import '../../services/supabase_service.dart';

class BulletinScreen extends StatefulWidget {
  const BulletinScreen({super.key});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bulletin;

  // Fallback static bulletin used when no Supabase data is available
  static final _staticBulletin = {
    'title': 'Sunday Service',
    'date': DateTime.now().toIso8601String(),
    'scripture': 'Psalm 100:2 — Serve the Lord with gladness; come before His presence with singing.',
    'items': [
      {'time': '9:00 AM', 'title': 'Praise & Worship', 'leader': 'Worship Team', 'icon': 'music_note'},
      {'time': '9:25 AM', 'title': 'Welcome & Announcements', 'leader': 'Host Pastor', 'icon': 'announcement'},
      {'time': '9:35 AM', 'title': 'Prayer & Intercession', 'leader': 'Prayer Team', 'icon': 'favorite'},
      {'time': '9:50 AM', 'title': 'Tithes & Offering', 'leader': 'Deacons', 'icon': 'monetization_on'},
      {'time': '10:00 AM', 'title': 'Word of God / Sermon', 'leader': 'Senior Pastor', 'icon': 'menu_book'},
      {'time': '10:45 AM', 'title': 'Altar Call & Ministry', 'leader': 'Ministry Team', 'icon': 'church'},
      {'time': '11:00 AM', 'title': 'Benediction & Dismissal', 'leader': 'Pastor', 'icon': 'handshake'},
    ],
    'announcements': [
      'New Members Class — Every 1st Sunday after service',
      'Mid-week Bible Study — Wednesdays at 7:00 PM',
      'Prayer Night — Fridays at 8:00 PM',
      'Youth Service — Saturdays at 4:00 PM',
    ],
  };

  static final Map<String, IconData> _iconMap = {
    'music_note': Icons.music_note,
    'announcement': Icons.campaign,
    'favorite': Icons.favorite,
    'monetization_on': Icons.monetization_on,
    'menu_book': Icons.menu_book,
    'church': Icons.church,
    'handshake': Icons.handshake,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Try to fetch the latest bulletin from Supabase
      final results = await SupabaseService().query('bulletins', column: 'active', value: true);
      if (results.isNotEmpty) {
        setState(() {
          _bulletin = results.first;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _bulletin = _staticBulletin;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Bulletin'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildOrderOfService(),
                    const SizedBox(height: 24),
                    _buildAnnouncements(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final dateStr = _bulletin?['date'] != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(
            DateTime.tryParse(_bulletin!['date'].toString()) ?? DateTime.now(),
          )
        : DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.church, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(
            _bulletin?['title'] as String? ?? 'Sunday Service',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (_bulletin?['scripture'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${_bulletin!['scripture']}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderOfService() {
    final items = _bulletin?['items'];
    if (items == null) return const SizedBox.shrink();

    final List<dynamic> serviceItems =
        items is List ? items : (items as Map).values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order of Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...serviceItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value as Map<dynamic, dynamic>;
          final iconName = item['icon'] as String? ?? 'church';
          final icon = _iconMap[iconName] ?? Icons.circle;
          final isLast = i == serviceItems.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline column
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(icon, size: 18, color: AppColors.purple),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.purple.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] as String? ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (item['time'] != null)
                              Text(
                                item['time'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (item['leader'] != null)
                          Text(
                            item['leader'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnnouncements() {
    final announcements = _bulletin?['announcements'];
    if (announcements == null) return const SizedBox.shrink();

    final List<dynamic> items =
        announcements is List ? announcements : (announcements as Map).values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Announcements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.campaign, color: AppColors.blue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    a.toString(),
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
