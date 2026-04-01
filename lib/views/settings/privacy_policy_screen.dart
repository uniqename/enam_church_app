import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faith Klinik Ministries\nPrivacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: March 2026',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 24),
            _section(
              'Information We Collect',
              'We collect information you provide when you register for the Faith Klinik app, '
              'including your name, email address, phone number, and church membership details. '
              'We also collect data about your use of the app, including prayer requests, '
              'attendance records, giving history, and content you upload.',
            ),
            _section(
              'How We Use Your Information',
              'Your information is used to:\n'
              '• Provide and improve our church services\n'
              '• Send you notifications about events and announcements\n'
              '• Process your giving and financial transactions\n'
              '• Connect you with church community groups\n'
              '• Provide personalized spiritual content and devotionals',
            ),
            _section(
              'Data Storage and Security',
              'Your data is stored securely using Supabase cloud infrastructure with '
              'industry-standard encryption. We do not sell your personal information '
              'to third parties. Access to your data is restricted to authorized church '
              'staff members on a need-to-know basis.',
            ),
            _section(
              'Children\'s Privacy',
              'Our children\'s features are designed for use under parental supervision. '
              'Children\'s accounts require a parent or guardian to set up and manage. '
              'We do not knowingly collect personal information from children under 13 '
              'without parental consent.',
            ),
            _section(
              'Third-Party Services',
              'We use the following third-party services:\n'
              '• Supabase for database and authentication\n'
              '• Flutterwave for payment processing\n'
              '• Agora for live streaming features\n\n'
              'These services have their own privacy policies and data handling practices.',
            ),
            _section(
              'Your Rights',
              'You have the right to:\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Withdraw consent at any time\n'
              '• Export your data\n\n'
              'To exercise these rights, contact us or use the Data Deletion feature in Settings.',
            ),
            _section(
              'Data Retention',
              'We retain your data for as long as your account is active. '
              'When you request account deletion, your data will be permanently '
              'removed within 30 days, except where required by law.',
            ),
            _section(
              'Contact Us',
              'If you have questions about this Privacy Policy, contact:\n\n'
              'Faith Klinik Ministries\n'
              'Email: privacy@faithklinikministries.org\n'
              'Address: Columbus, Ohio, USA',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'By using the Faith Klinik app, you agree to this Privacy Policy. '
                'We may update this policy periodically and will notify you of significant changes.',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
