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
  final _supabase = SupabaseService();
  final _authService = AuthService();

  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _appliedRole;

  static const _defaultOpportunities = [
    {
      'id': 'default-1',
      'title': 'Worship Team',
      'description': 'Singers, musicians, and sound technicians to lead the congregation in worship every Sunday.',
      'icon_name': 'music_note',
      'color_hex': '9C27B0',
      'commitment': 'Sundays + rehearsals',
      'skills': 'Singing, Instruments, Sound, Presentation',
    },
    {
      'id': 'default-2',
      'title': 'Ushers & Greeters',
      'description': 'Be the first face members and visitors see. Welcome people, manage seating, and maintain order.',
      'icon_name': 'waving_hand',
      'color_hex': '2196F3',
      'commitment': 'Sundays',
      'skills': 'Friendly, Punctual, Organized',
    },
    {
      'id': 'default-3',
      'title': "Children's Ministry",
      'description': 'Teach and care for children ages 2-12 during Sunday service. Help the next generation grow in faith.',
      'icon_name': 'child_care',
      'color_hex': '4CAF50',
      'commitment': 'Sundays',
      'skills': 'Patience, Teaching, Creativity',
    },
    {
      'id': 'default-4',
      'title': 'Media & Tech Team',
      'description': 'Operate cameras, manage live streaming, handle slides, and support digital ministry efforts.',
      'icon_name': 'videocam',
      'color_hex': 'FF5722',
      'commitment': 'Sundays + special events',
      'skills': 'Tech-savvy, Video, Social Media, Design',
    },
    {
      'id': 'default-5',
      'title': 'Prayer Ministry',
      'description': 'Intercede for church members, lead prayer services, and minister to those who come forward for prayer.',
      'icon_name': 'favorite',
      'color_hex': 'E91E63',
      'commitment': 'Fridays + Sundays',
      'skills': 'Intercessory Prayer, Compassion, Discretion',
    },
    {
      'id': 'default-6',
      'title': 'Community Outreach',
      'description': 'Organize and participate in community events, food drives, and local mission projects.',
      'icon_name': 'volunteer_activism',
      'color_hex': '009688',
      'commitment': 'Monthly events',
      'skills': 'Compassion, Organization, Leadership',
    },
    {
      'id': 'default-7',
      'title': 'Security Team',
      'description': 'Ensure the safety and security of all who attend services and events at Faith Klinik.',
      'icon_name': 'security',
      'color_hex': '607D8B',
      'commitment': 'Sundays + events',
      'skills': 'Alert, Calm under pressure, Responsible',
    },
    {
      'id': 'default-8',
      'title': 'Hospitality Team',
      'description': 'Prepare refreshments, coordinate fellowship events, and make members feel welcomed and valued.',
      'icon_name': 'coffee',
      'color_hex': 'FF9800',
      'commitment': 'Sundays + events',
      'skills': 'Cooking, Event Planning, Hospitality',
    },
    {
      'id': 'default-9',
      'title': 'Youth Ministry',
      'description': 'Lead and mentor teenagers (13-18) through Bible study, activities, and discipleship.',
      'icon_name': 'groups',
      'color_hex': '3F51B5',
      'commitment': 'Saturdays + Sundays',
      'skills': 'Mentoring, Energy, Youth Culture',
    },
    {
      'id': 'default-10',
      'title': 'Dance Ministry',
      'description': 'Use creative movement and dance to worship God and minister to the congregation.',
      'icon_name': 'self_improvement',
      'color_hex': 'F06292',
      'commitment': 'Sundays + rehearsals',
      'skills': 'Dance, Worship, Creativity',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final role = await _authService.getUserRole();
    final isAdmin = role == 'admin' || role == 'pastor' || role == 'department_head';
    List<Map<String, dynamic>> ops = [];
    try {
      ops = await _supabase.getAll('volunteer_opportunities');
    } catch (_) {}
    if (ops.isEmpty) {
      ops = List<Map<String, dynamic>>.from(_defaultOpportunities);
    }
    setState(() {
      _opportunities = ops;
      _isAdmin = isAdmin;
      _isLoading = false;
    });
  }

  Future<void> _apply(BuildContext context, Map<String, dynamic> role) async {
    final userName = await _authService.getCurrentUserName() ?? 'Anonymous';
    final userEmail = await _authService.getCurrentUserEmail() ?? '';

    try {
      await _supabase.insert('volunteer_applications', {
        'role': role['title'] as String? ?? '',
        'name': userName,
        'email': userEmail,
        'applied_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
      setState(() => _appliedRole = role['title'] as String?);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Application for "${role['title']}" submitted! We\'ll reach out soon.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not submit application: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _showAddEditDialog([Map<String, dynamic>? existing]) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final commitmentCtrl = TextEditingController(text: existing?['commitment'] as String? ?? '');
    final skillsCtrl = TextEditingController(text: existing?['skills'] as String? ?? '');
    final isEdit = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Opportunity' : 'Add Volunteer Opportunity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commitmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Commitment (e.g. Sundays)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Skills (comma-separated)',
                  hintText: 'e.g. Singing, Creativity',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Title and description are required')),
                );
                return;
              }
              final navigator = Navigator.of(ctx);
              try {
                final data = {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'commitment': commitmentCtrl.text.trim(),
                  'skills': skillsCtrl.text.trim(),
                  'icon_name': existing?['icon_name'] ?? 'volunteer_activism',
                  'color_hex': existing?['color_hex'] ?? '4CAF50',
                };
                if (isEdit && !(existing!['id'] as String).startsWith('default-')) {
                  await _supabase.update('volunteer_opportunities', existing['id'] as String, data);
                } else {
                  await _supabase.insert('volunteer_opportunities', data);
                }
                navigator.pop();
                _loadData();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOpportunity(Map<String, dynamic> op) async {
    final id = op['id'] as String? ?? '';
    if (id.startsWith('default-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default opportunities cannot be deleted here. Add it to the database first to manage it.')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Opportunity?'),
        content: Text('Remove "${op['title']}" from the volunteer list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _supabase.delete('volunteer_opportunities', id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.brown;
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'music_note': return Icons.music_note;
      case 'waving_hand': return Icons.waving_hand;
      case 'child_care': return Icons.child_care;
      case 'videocam': return Icons.videocam;
      case 'favorite': return Icons.favorite;
      case 'security': return Icons.security;
      case 'coffee': return Icons.coffee;
      case 'groups': return Icons.groups;
      case 'self_improvement': return Icons.self_improvement;
      default: return Icons.volunteer_activism;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer'),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditDialog(),
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Opportunity'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Open Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (_isAdmin)
                          Text('${_opportunities.length} roles', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._opportunities.map((op) => _buildRoleCard(context, op)),
                    const SizedBox(height: 80), // FAB clearance
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Map<String, dynamic> op) {
    final title = op['title'] as String? ?? '';
    final description = op['description'] as String? ?? '';
    final commitment = op['commitment'] as String? ?? '';
    final skillsStr = op['skills'] as String? ?? '';
    final skills = skillsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final color = _hexToColor(op['color_hex'] as String? ?? '4CAF50');
    final icon = _iconFromName(op['icon_name'] as String? ?? 'volunteer_activism');
    final isApplied = _appliedRole == title;
    final isDefault = (op['id'] as String? ?? '').startsWith('default-');

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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (commitment.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(commitment, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: Colors.grey,
                    onPressed: () => _showAddEditDialog(op),
                    tooltip: 'Edit',
                  ),
                  if (!isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red.shade300,
                      onPressed: () => _deleteOpportunity(op),
                      tooltip: 'Delete',
                    ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55), height: 1.4),
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: skills.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isApplied ? null : () => _apply(context, op),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? AppColors.success : color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
