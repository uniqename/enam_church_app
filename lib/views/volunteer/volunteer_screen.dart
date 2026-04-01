import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  bool _isLoading = false;
  String? _appliedRole;

  static const _opportunities = [
    _VolunteerRole(
      title: 'Worship Team',
      description: 'Singers, musicians, and sound technicians to lead the congregation in worship every Sunday.',
      icon: Icons.music_note,
      color: Color(0xFF9C27B0),
      commitment: 'Sundays + rehearsals',
      skills: ['Singing', 'Instruments', 'Sound', 'Presentation'],
    ),
    _VolunteerRole(
      title: 'Ushers & Greeters',
      description: 'Be the first face members and visitors see. Welcome people, manage seating, and maintain order during service.',
      icon: Icons.waving_hand,
      color: Color(0xFF2196F3),
      commitment: 'Sundays',
      skills: ['Friendly', 'Punctual', 'Organized'],
    ),
    _VolunteerRole(
      title: 'Children\'s Ministry',
      description: 'Teach and care for children ages 2-12 during Sunday service. Help the next generation grow in faith.',
      icon: Icons.child_care,
      color: Color(0xFF4CAF50),
      commitment: 'Sundays',
      skills: ['Patience', 'Teaching', 'Creativity'],
    ),
    _VolunteerRole(
      title: 'Media & Tech Team',
      description: 'Operate cameras, manage live streaming, handle slides, and support digital ministry efforts.',
      icon: Icons.videocam,
      color: Color(0xFFFF5722),
      commitment: 'Sundays + special events',
      skills: ['Tech-savvy', 'Video', 'Social Media', 'Design'],
    ),
    _VolunteerRole(
      title: 'Prayer Ministry',
      description: 'Intercede for church members, lead prayer services, and minister to those who come forward for prayer.',
      icon: Icons.favorite,
      color: Color(0xFFE91E63),
      commitment: 'Fridays + Sundays',
      skills: ['Intercessory Prayer', 'Compassion', 'Discretion'],
    ),
    _VolunteerRole(
      title: 'Community Outreach',
      description: 'Organize and participate in community events, food drives, and local mission projects.',
      icon: Icons.volunteer_activism,
      color: Color(0xFF009688),
      commitment: 'Monthly events',
      skills: ['Compassion', 'Organization', 'Leadership'],
    ),
    _VolunteerRole(
      title: 'Security Team',
      description: 'Ensure the safety and security of all who attend services and events at Faith Klinik.',
      icon: Icons.security,
      color: Color(0xFF607D8B),
      commitment: 'Sundays + events',
      skills: ['Alert', 'Calm under pressure', 'Responsible'],
    ),
    _VolunteerRole(
      title: 'Hospitality Team',
      description: 'Prepare refreshments, coordinate fellowship events, and make members feel welcomed and valued.',
      icon: Icons.coffee,
      color: Color(0xFFFF9800),
      commitment: 'Sundays + events',
      skills: ['Cooking', 'Event Planning', 'Hospitality'],
    ),
  ];

  Future<void> _apply(BuildContext context, _VolunteerRole role) async {
    final authService = AuthService();
    final userName = await authService.getCurrentUserName() ?? 'Anonymous';
    final userEmail = await authService.getCurrentUserEmail() ?? '';

    setState(() => _isLoading = true);
    try {
      await SupabaseService().insert('volunteer_applications', {
        'role': role.title,
        'name': userName,
        'email': userEmail,
        'applied_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
      setState(() => _appliedRole = role.title);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Application for "${role.title}" submitted! We\'ll reach out soon.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not submit application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer'),
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
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.white, size: 36),
                  SizedBox(height: 10),
                  Text(
                    'Serve & Make a Difference',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Every member has a gift. Find where you fit and help build the kingdom.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Open Opportunities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._opportunities.map(
              (role) => _buildRoleCard(context, role),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, _VolunteerRole role) {
    final isApplied = _appliedRole == role.title;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: role.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(role.icon, color: role.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48)),
                          const SizedBox(width: 4),
                          Text(
                            role.commitment,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              role.description,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: role.skills
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: role.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: role.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isApplied || _isLoading
                    ? null
                    : () => _apply(context, role),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? AppColors.success : role.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isApplied ? 'Application Submitted!' : 'Apply to Serve',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolunteerRole {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String commitment;
  final List<String> skills;

  const _VolunteerRole({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.commitment,
    required this.skills,
  });
}
