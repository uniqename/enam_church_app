import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _announcementService = AnnouncementService();
  final _authService = AuthService();
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isDeptHead = false;
  String _userName = '';
  String _userDept = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userRole = await _authService.getUserRole();
      final userName = await _authService.getCurrentUserName();
      final userDept = await _authService.getUserDepartment();
      final announcements = await _announcementService.getAllAnnouncements();
      setState(() {
        _isAdmin = (userRole == 'admin' || userRole == 'pastor');
        _isDeptHead = userRole == 'departmentHead' || userRole == 'department_head';
        _userName = userName ?? '';
        _userDept = userDept ?? 'General';
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load announcements: $e')),
        );
      }
    }
  }

  bool get _canCreate => _isAdmin || _isDeptHead;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? const Center(child: Text('No announcements yet'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = _announcements[index];
                      final borderColor =
                          announcement.priority.toLowerCase() == 'high'
                              ? Colors.red
                              : announcement.priority.toLowerCase() == 'normal'
                                  ? Colors.orange
                                  : Colors.grey;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor, width: 3),
                        ),
                        child: InkWell(
                          onTap: _isAdmin
                              ? () => _showEditAnnouncementDialog(announcement)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.campaign,
                                      color: announcement.priority
                                                  .toLowerCase() ==
                                              'high'
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        announcement.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (_isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            size: 18, color: AppColors.purple),
                                        onPressed: () =>
                                            _showEditAnnouncementDialog(
                                                announcement),
                                        tooltip: 'Edit',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(announcement.content),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By ${announcement.author}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM d, yyyy')
                                          .format(announcement.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (announcement.department != 'General') ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      announcement.department,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.purple),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              onPressed: _showAddAnnouncementDialog,
              backgroundColor: AppColors.accentPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedPriority = 'Normal';
    String selectedDepartment = _isDeptHead ? _userDept : 'General';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Low', 'Normal', 'High']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedPriority = v ?? 'Normal'),
                ),
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Department (optional)',
                      border: const OutlineInputBorder(),
                      hintText: selectedDepartment,
                    ),
                    onChanged: (v) => selectedDepartment =
                        v.trim().isEmpty ? 'General' : v.trim(),
                  ),
                ],
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
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill title and content')),
                  );
                  return;
                }
                final newAnnouncement = Announcement(
                  id: '',
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  priority: selectedPriority,
                  author: _userName,
                  date: DateTime.now(),
                  department: selectedDepartment,
                  status: 'Published',
                );
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _announcementService.addAnnouncement(newAnnouncement);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Announcement published'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to publish: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAnnouncementDialog(Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final contentController =
        TextEditingController(text: announcement.content);
    String selectedPriority = announcement.priority;
    final deptController =
        TextEditingController(text: announcement.department);

    const validPriorities = ['Low', 'Normal', 'High'];
    if (!validPriorities.contains(selectedPriority)) {
      selectedPriority = 'Normal';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: validPriorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedPriority = v ?? 'Normal'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showDeleteAnnouncementDialog(announcement);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final updated = Announcement(
                  id: announcement.id,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  priority: selectedPriority,
                  author: announcement.author,
                  date: announcement.date,
                  department: deptController.text.trim().isEmpty
                      ? 'General'
                      : deptController.text.trim(),
                  status: announcement.status,
                );
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _announcementService.updateAnnouncement(updated);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Announcement updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAnnouncementDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            Text('Delete "${announcement.title}"? This cannot be undone.'),
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
                await _announcementService.deleteAnnouncement(announcement.id);
                navigator.pop();
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Announcement deleted')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
