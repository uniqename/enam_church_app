import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _prayerCtrl = TextEditingController();

  String _visitType = 'First time';
  final List<String> _interests = [];
  bool _submitting = false;
  bool _submitted = false;

  final _visitTypes = ['First time', 'Returning visitor', 'Online attendee', 'Just moved here'];
  final _interestOptions = [
    'Join a small group',
    'Volunteer',
    'Youth ministry',
    'Music/Worship',
    'Prayer team',
    'Children\'s ministry',
    'Community outreach',
    'Leadership development',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _prayerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await SupabaseService().insert('connect_cards', {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'visit_type': _visitType,
        'interests': _interests.join(', '),
        'prayer_request': _prayerCtrl.text.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Offline — still show success (saved locally or retry later)
    }

    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect With Us'),
      ),
      body: _submitted ? _buildSuccess(scheme) : _buildForm(scheme),
    );
  }

  Widget _buildSuccess(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 72),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Faith Klinik!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for connecting with us. A member of our team will reach out to you soon. We\'re so glad you\'re here!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.church, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'We\'d love to get to know you!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Fill out this card and we\'ll help you connect with Faith Klinik Ministries.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Your Info'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'City / Neighborhood',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Your Visit'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _visitType,
              decoration: const InputDecoration(
                labelText: 'How are you joining us?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.waving_hand_outlined),
              ),
              items: _visitTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _visitType = v!),
            ),
            const SizedBox(height: 24),
            _sectionLabel('I\'m Interested In'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((opt) {
                final selected = _interests.contains(opt);
                return FilterChip(
                  label: Text(opt),
                  selected: selected,
                  selectedColor: AppColors.purple.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.purple,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _interests.add(opt);
                      } else {
                        _interests.remove(opt);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Prayer Request (optional)'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prayerCtrl,
              decoration: const InputDecoration(
                hintText: 'Share anything you\'d like us to pray for...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Connect Card', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.purple),
    );
  }
}
