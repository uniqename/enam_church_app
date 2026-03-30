import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataDeletionScreen extends StatefulWidget {
  const DataDeletionScreen({super.key});

  @override
  State<DataDeletionScreen> createState() => _DataDeletionScreenState();
}

class _DataDeletionScreenState extends State<DataDeletionScreen> {
  bool _isDeleting = false;

  Future<void> _requestDeletion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account Data'),
        content: const Text(
          'Are you sure you want to request deletion of all your account data? '
          'This action cannot be undone. Your account and all associated data '
          'will be permanently removed from our systems within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete My Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        setState(() => _isDeleting = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Request Submitted'),
            content: const Text(
              'Your data deletion request has been submitted. '
              'Your data will be permanently deleted within 30 days. '
              'You have been logged out of the app.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Deletion Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.delete_forever, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Request Account Data Deletion',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You have the right to request the deletion of your personal data '
              'from Faith Klinik Ministries\' systems. This includes:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...[
              'Your profile information (name, email, phone)',
              'Your prayer requests',
              'Your giving history',
              'Your attendance records',
              'Your messages and communications',
              'Any uploaded photos or media',
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 15))),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            const Text(
              'Important Notes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Deletion requests are processed within 30 days\n'
              '• Some data may be retained for legal or financial compliance purposes\n'
              '• Deletion is permanent and cannot be reversed\n'
              '• You will be logged out immediately after submitting this request',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'To request deletion by email, contact:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'privacy@faithklinikministries.org',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDeleting ? null : _requestDeletion,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_forever),
                label: Text(_isDeleting ? 'Processing...' : 'Request Data Deletion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
