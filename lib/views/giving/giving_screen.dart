import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key});

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  final List<Map<String, dynamic>> _givingOptions = [
    {
      'type': 'Tithes',
      'description': 'Give your regular tithe',
      'suggested': [50, 100, 200],
    },
    {
      'type': 'Offerings',
      'description': 'Support the ministry',
      'suggested': [25, 50, 100],
    },
    {
      'type': 'Building Fund',
      'description': 'Help build the sanctuary',
      'suggested': [100, 250, 500],
    },
    {
      'type': 'Missions',
      'description': 'Support global missions',
      'suggested': [50, 100, 250],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Giving'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.childGreen.withValues(alpha: 0.2),
                    AppColors.childBlue.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 64,
                    color: AppColors.childGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Online Giving',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Give joyfully as God has blessed you',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _givingOptions.length,
              itemBuilder: (context, index) {
                final option = _givingOptions[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.volunteer_activism,
                          size: 32,
                          color: AppColors.childGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          option['type'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['description'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _showGivingDialog(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.childGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: Text('Give \$${option['suggested'][0]}'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGivingDialog(Map<String, dynamic> option) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Online Giving'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 48,
              color: AppColors.childGreen,
            ),
            SizedBox(height: 16),
            Text(
              'Faith Klinik Ministries uses Givelify for secure online donations.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Download the Givelify app or visit their website to give.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final url = Uri.parse('https://www.givelify.com/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
                navigator.pop();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to open link: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.childGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Givelify'),
          ),
        ],
      ),
    );
  }
}


<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>
