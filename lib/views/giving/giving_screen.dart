import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_settings_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key});

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  final _settings = AppSettingsService();
  final _auth = AuthService();

  String _givelifyUrl = '';
  bool _canEdit = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait<dynamic>([
      _settings.givelifyUrl(),
      _auth.getUserRole(),
    ]);
    setState(() {
      _givelifyUrl = results[0] as String;
      final role = results[1] as String?;
      _canEdit = role == 'admin' || role == 'pastor';
      _loading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Giving link not set yet. Ask your admin to configure it.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open: $e')));
      }
    }
  }

  void _showEditDialog() {
    final ctrl = TextEditingController(text: _givelifyUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Set Giving Link',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your Givelify church giving link below.\n'
              'You can find this in your Givelify dashboard under "Share my page".',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Givelify URL',
                hintText: 'https://www.givelify.com/give/...',
                hintStyle: TextStyle(color: Colors.white24),
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppColors.darkSurface,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentPurple)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple),
            child: const Text('Save'),
            onPressed: () async {
              await _settings.setGivelifyUrl(ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = _givelifyUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Online Giving',
            style: TextStyle(
                color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.accentPurple),
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: AppColors.accentPurple),
              onPressed: _showEditDialog,
              tooltip: 'Set Giving Link',
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A0A2E), AppColors.darkBg],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accentPurple.withValues(alpha: 0.3)),
                      boxShadow: AppColors.glowPurple(radius: 20, opacity: 0.15),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.volunteer_activism,
                            size: 56, color: AppColors.accentGold),
                        const SizedBox(height: 14),
                        const Text(
                          'Give to Faith Klinik',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '"Each of you should give what you have decided in your heart to give, '
                          'not reluctantly or under compulsion, for God loves a cheerful giver."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontStyle: FontStyle.italic),
                        ),
                        const Text(
                          '— 2 Corinthians 9:7',
                          style: TextStyle(
                              color: AppColors.accentGold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giving categories
                  ...[
                    {'icon': Icons.church, 'title': 'Tithes', 'desc': 'Return 10% as an act of worship and obedience', 'color': AppColors.accentPurple},
                    {'icon': Icons.favorite_outline, 'title': 'Offerings', 'desc': 'Support the daily work of the ministry', 'color': AppColors.accentGold},
                    {'icon': Icons.home_work_outlined, 'title': 'Building Fund', 'desc': 'Help us build a permanent home for Faith Klinik', 'color': AppColors.accentTeal},
                    {'icon': Icons.language, 'title': 'Missions', 'desc': 'Support global and local outreach efforts', 'color': AppColors.accentRose},
                  ].map((item) => _GivingCategory(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    desc: item['desc'] as String,
                    color: item['color'] as Color,
                    onGive: () => _openUrl(_givelifyUrl),
                  )),

                  const SizedBox(height: 8),

                  // Main CTA button
                  if (hasLink)
                    Column(children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.open_in_new, size: 20),
                        label: const Text('Give Now via Givelify',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () => _openUrl(_givelifyUrl),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure giving powered by Givelify',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ])
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(children: [
                        const Icon(Icons.info_outline,
                            color: Colors.white38, size: 28),
                        const SizedBox(height: 8),
                        const Text(
                          'Online giving is coming soon.',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You can give in person at any service.\nAdmin will activate online giving shortly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                        if (_canEdit) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.settings,
                                size: 16, color: AppColors.accentPurple),
                            label: const Text('Set Givelify Link',
                                style: TextStyle(color: AppColors.accentPurple)),
                            onPressed: _showEditDialog,
                          ),
                        ],
                      ]),
                    ),

                  const SizedBox(height: 24),
                  // How to get Givelify info
                  if (_canEdit && !hasLink)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accentPurple.withValues(alpha: 0.25)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How to set up Givelify:',
                              style: TextStyle(
                                  color: AppColors.accentPurple,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                            '1. Go to givelify.com and create a free church account\n'
                            '2. Complete your church profile (name, logo, bank account)\n'
                            '3. From your dashboard → Share → Copy your giving page link\n'
                            '4. Tap the ⚙ settings icon above and paste the link\n\n'
                            'No API key is needed — just your Givelify giving page URL.',
                            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _GivingCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onGive;

  const _GivingCategory({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.onGive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Text(desc,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        )),
        GestureDetector(
          onTap: onGive,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text('Give',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}
