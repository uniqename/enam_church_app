import 'package:flutter/material.dart';
import '../utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faith Klinik Ministries Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us when you:\n\n'
              '• Create an account or profile\n'
              '• Submit prayer requests\n'
              '• Register for events\n'
              '• Make donations\n'
              '• Contact us for support\n\n'
              'This may include your name, email address, phone number, and other information you choose to provide.',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide, maintain, and improve our app services\n'
              '• Send you updates about church events and activities\n'
              '• Process your donations and provide receipts\n'
              '• Respond to your prayer requests and support inquiries\n'
              '• Communicate with you about church matters',
            ),
            _buildSection(
              'Data Security',
              'We take reasonable measures to protect your personal information from unauthorized access, use, or disclosure. However, no method of transmission over the Internet or electronic storage is 100% secure.',
            ),
            _buildSection(
              'Data Sharing',
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only:\n\n'
              '• With your consent\n'
              '• To comply with legal obligations\n'
              '• To protect our rights and safety',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal information\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Opt-out of communications\n'
              '• Export your data',
            ),
            _buildSection(
              'Data Retention',
              'We retain your personal information for as long as necessary to fulfill the purposes outlined in this privacy policy, unless a longer retention period is required by law.',
            ),
            _buildSection(
              'Children\'s Privacy',
              'Our app does not knowingly collect information from children under 13. If you believe we have collected information from a child, please contact us immediately.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy or wish to exercise your data rights, please contact us:\n\n'
              'Email: privacy@faithklinikministries.com\n'
              'Address: Faith Klinik Ministries\nColumbus, Ohio, USA',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
