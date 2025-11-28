import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';

class DataDeletionScreen extends StatefulWidget {
  const DataDeletionScreen({super.key});

  @override
  State<DataDeletionScreen> createState() => _DataDeletionScreenState();
}

class _DataDeletionScreenState extends State<DataDeletionScreen> {
  bool _confirmDeletion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete My Data'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Warning: This action cannot be undone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Request Data Deletion',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You have the right to request deletion of your personal data. When you request data deletion:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildBulletPoint('Your account and profile will be permanently deleted'),
            _buildBulletPoint('All your prayer requests and messages will be removed'),
            _buildBulletPoint('Your event registrations and attendance records will be deleted'),
            _buildBulletPoint('Your donation history may be retained for legal/tax purposes'),
            _buildBulletPoint('You will no longer receive communications from us'),
            const SizedBox(height: 24),
            const Text(
              'How to Request Deletion:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.email,
              title: 'Email Request',
              description: 'Send an email to: privacy@faithklinikministries.com',
              action: 'Copy Email Address',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'privacy@faithklinikministries.com'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email address copied to clipboard')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.phone,
              title: 'Phone Request',
              description: 'Call us at: +1 (614) XXX-XXXX',
              action: 'Copy Phone Number',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '+16140000000'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number copied to clipboard')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.delete_forever,
              title: 'In-App Deletion',
              description: 'Delete your account directly from this app',
              action: 'Request Deletion Now',
              onTap: () => _showDeletionDialog(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will process your deletion request within 30 days. You will receive a confirmation email once your data has been deleted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required String action,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.purple, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(action),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Data Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete all your data? This action cannot be undone.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _confirmDeletion,
                  onChanged: (value) {
                    setState(() {
                      _confirmDeletion = value ?? false;
                    });
                    Navigator.pop(context);
                    _showDeletionDialog();
                  },
                ),
                const Expanded(
                  child: Text(
                    'I understand this action is permanent',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _confirmDeletion = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _confirmDeletion
                ? () {
                    Navigator.pop(context);
                    _submitDeletionRequest();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete My Data'),
          ),
        ],
      ),
    );
  }

  void _submitDeletionRequest() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _confirmDeletion = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Submitted'),
        content: const Text(
          'Your data deletion request has been submitted. You will receive a confirmation email within 24 hours. Your data will be deleted within 30 days.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
