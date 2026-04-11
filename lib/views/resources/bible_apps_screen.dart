import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import 'church_library_screen.dart';

class BibleAppsScreen extends StatelessWidget {
  const BibleAppsScreen({super.key});

  static const _bibleApps = [
    {
      'name': 'YouVersion Bible',
      'description': 'Free Bible app with thousands of versions and reading plans',
      'url': 'https://www.youversion.com/',
      'icon': Icons.menu_book,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Bible Gateway',
      'description': 'Search and read the Bible online in many versions',
      'url': 'https://www.biblegateway.com/',
      'icon': Icons.search,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Blue Letter Bible',
      'description': 'In-depth Bible study tools and commentaries',
      'url': 'https://www.blueletterbible.org/',
      'icon': Icons.library_books,
      'color': Color(0xFF1565C0),
    },
    {
      'name': 'Bible.com',
      'description': 'Read, listen, and engage with Scripture every day',
      'url': 'https://www.bible.com/',
      'icon': Icons.book,
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Logos Bible Software',
      'description': 'Professional biblical research and study software',
      'url': 'https://www.logos.com/',
      'icon': Icons.school,
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Open Bible',
      'description': 'Topical Bible study and verse references',
      'url': 'https://www.openbible.info/',
      'icon': Icons.open_in_new,
      'color': Color(0xFF009688),
    },
  ];

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Resources'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.menu_book, size: 48, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    'Bible Study Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access trusted Bible apps and websites to deepen your faith',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommended Apps & Websites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_bibleApps.map((app) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (app['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        app['icon'] as IconData,
                        color: app['color'] as Color,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      app['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(app['description'] as String),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _launchUrl(context, app['url'] as String),
                    ),
                    onTap: () => _launchUrl(context, app['url'] as String),
                    isThreeLine: true,
                  ),
                ))),
            const SizedBox(height: 24),
            const Text(
              'Faith Klinik Resources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChurchLibraryScreen())),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.brown.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_library, color: AppColors.brown, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Church Library',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text(
                              'Books, reading plans, PDFs, audio sermons and more — curated by the team.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.brown),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
