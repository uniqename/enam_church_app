import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class _StaffMember {
  final String name;
  final String title;
  final String bio;
  final String email;
  final IconData icon;
  final Color color;

  const _StaffMember({
    required this.name,
    required this.title,
    required this.bio,
    required this.email,
    required this.icon,
    required this.color,
  });
}

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  static const List<_StaffMember> _staff = [
    _StaffMember(
      name: 'Senior Pastor',
      title: 'Lead Pastor & Founder',
      bio:
          'The founding pastor of Faith Klinik Ministries, called to build a community rooted in faith, healing, and transformation in Columbus, Ohio.',
      email: 'pastor@faithklinikministries.com',
      icon: Icons.church,
      color: AppColors.purple,
    ),
    _StaffMember(
      name: 'Associate Pastor',
      title: 'Associate Pastor',
      bio:
          'Oversees congregational care, small groups, and pastoral counseling. Dedicated to shepherding members through every season of life.',
      email: 'associate@faithklinikministries.com',
      icon: Icons.people_alt,
      color: AppColors.blue,
    ),
    _StaffMember(
      name: 'Worship Director',
      title: 'Director of Worship',
      bio:
          'Leads the worship team and cultivates an atmosphere of genuine encounter with God through music, arts, and creative expression.',
      email: 'worship@faithklinikministries.com',
      icon: Icons.music_note,
      color: Color(0xFF6A0080),
    ),
    _StaffMember(
      name: 'Youth Director',
      title: 'Director of Youth & Young Adults',
      bio:
          'Passionate about equipping the next generation with a solid biblical foundation and empowering them to live out their faith boldly.',
      email: 'youth@faithklinikministries.com',
      icon: Icons.groups,
      color: AppColors.accentBlue,
    ),
    _StaffMember(
      name: 'Children\'s Ministry Director',
      title: 'Director of Children\'s Ministry',
      bio:
          'Leads a vibrant children\'s church experience where kids discover God\'s love through stories, worship, and age-appropriate discipleship.',
      email: 'kids@faithklinikministries.com',
      icon: Icons.child_care,
      color: AppColors.success,
    ),
    _StaffMember(
      name: 'Outreach Coordinator',
      title: 'Community Outreach & Evangelism',
      bio:
          'Coordinates food pantry, community events, and evangelism efforts — extending the love of Christ beyond the church walls into Columbus.',
      email: 'outreach@faithklinikministries.com',
      icon: Icons.volunteer_activism,
      color: AppColors.warning,
    ),
    _StaffMember(
      name: 'Media Team Lead',
      title: 'Media & Communications',
      bio:
          'Manages streaming, social media, photography, and all digital communications to help Faith Klinik reach people online and on-site.',
      email: 'media@faithklinikministries.com',
      icon: Icons.live_tv,
      color: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.people, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Meet Our Team',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  'Dedicated servants building faith, healing lives, and transforming our community.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._staff.map((s) => _StaffCard(member: s)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.mail_outline, color: AppColors.purple),
                const SizedBox(height: 8),
                const Text(
                  'General Inquiries',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'info@faithklinikministries.com',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final _StaffMember member;
  const _StaffCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: member.color.withValues(alpha: 0.12),
              child: Icon(member.icon, color: member.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.title,
                    style: TextStyle(fontSize: 13, color: member.color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.bio,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          member.email,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
