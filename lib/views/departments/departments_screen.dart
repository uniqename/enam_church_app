import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/department.dart';
import '../../models/ministry.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../services/department_service.dart';
import '../../services/ministry_service.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class DepartmentsScreen extends StatefulWidget {
  final int initialTab;
  const DepartmentsScreen({super.key, this.initialTab = 0});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen>
    with SingleTickerProviderStateMixin {
  final _deptService = DepartmentService();
  final _minService = MinistryService();
  final _eventService = EventService();
  final _authService = AuthService();

  late TabController _tabController;

  List<Department> _departments = [];
  List<Ministry> _ministries = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _deptService.getAllDepartments(),
        _minService.getAllMinistries(),
        _authService.getCurrentUserProfile(),
      ]);
      setState(() {
        _departments = results[0] as List<Department>;
        _ministries = results[1] as List<Ministry>;
        _currentUser = results[2] as AppUser?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  bool get _isAdmin => _currentUser?.isAdmin ?? false;

  bool _canEditDept(Department dept) =>
      _currentUser?.canEditDepartment(dept.name) ?? false;

  bool _canEditMinistry(Ministry ministry) =>
      _currentUser?.canEditDepartment(ministry.name) ?? false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open link: $e')));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments & Ministries'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Departments'),
            Tab(text: 'Ministries'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDepartmentsTab(),
                _buildMinistriesTab(),
              ],
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              tooltip: 'Add',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ── Departments tab ───────────────────────────────────────────────────────

  Widget _buildDepartmentsTab() {
    if (_departments.isEmpty) {
      return const Center(child: Text('No departments yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final dept = _departments[index];
          final canEdit = _canEditDept(dept);
          return _buildDeptCard(dept, canEdit);
        },
      ),
    );
  }

  Widget _buildDeptCard(Department dept, bool canEdit) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDeptDetails(dept),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.people, color: AppColors.brown),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: AppColors.purple),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditDeptDialog(dept),
                          tooltip: 'Edit',
                        ),
                      if (_isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmDeleteDept(dept),
                          tooltip: 'Delete',
                        ),
                      if (dept.whatsappGroup.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.childGreen,
                          onPressed: () => _launchURL(dept.whatsappGroup),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(dept.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Text('Head: ${dept.head}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${dept.members.length} members',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              if (canEdit)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('You manage this',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Ministries tab ────────────────────────────────────────────────────────

  Widget _buildMinistriesTab() {
    if (_ministries.isEmpty) {
      return const Center(child: Text('No ministries yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _ministries.length,
        itemBuilder: (context, index) {
          final ministry = _ministries[index];
          final canEdit = _canEditMinistry(ministry);
          return _buildMinistryCard(ministry, canEdit);
        },
      ),
    );
  }

  Widget _buildMinistryCard(Ministry ministry, bool canEdit) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMinistryDetails(ministry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.volunteer_activism, color: AppColors.brown),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: AppColors.purple),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditMinistryDialog(ministry),
                          tooltip: 'Edit',
                        ),
                      if (_isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmDeleteMinistry(ministry),
                          tooltip: 'Delete',
                        ),
                      if (ministry.whatsappGroup.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.childGreen,
                          onPressed: () => _launchURL(ministry.whatsappGroup),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(ministry.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Text('Leader: ${ministry.leader}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              if (ministry.meetingDay.isNotEmpty)
                Text(ministry.meetingDay,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              if (canEdit)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('You manage this',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Department detail dialog ──────────────────────────────────────────────

  void _showDeptDetails(Department dept) {
    final canEdit = _canEditDept(dept);
    final canAddEvent = _isAdmin || canEdit;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Expanded(child: Text(dept.name)),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.purple),
              onPressed: () {
                Navigator.pop(ctx);
                _showEditDeptDialog(dept);
              },
            ),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dept.heads.isNotEmpty)
                Text('Head(s): ${dept.heads.join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Members: ${dept.members.length}'),
              if (dept.whatsappGroup.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL(dept.whatsappGroup),
                  child: const Text('WhatsApp Group →',
                      style: TextStyle(
                          color: AppColors.childGreen,
                          fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(height: 16),
              if (dept.members.isNotEmpty) ...[
                const Text('Members:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...dept.members.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $m'),
                    )),
              ],
              if (canAddEvent) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event, color: AppColors.blue),
                    label: const Text('Add Event',
                        style: TextStyle(color: AppColors.blue)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEventDialog(dept.name);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Ministry detail dialog ────────────────────────────────────────────────

  void _showMinistryDetails(Ministry ministry) {
    final canEdit = _canEditMinistry(ministry);
    final canAddEvent = _isAdmin || canEdit;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Expanded(child: Text(ministry.name)),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.purple),
              onPressed: () {
                Navigator.pop(ctx);
                _showEditMinistryDialog(ministry);
              },
            ),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leader: ${ministry.leader}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (ministry.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(ministry.description),
              ],
              if (ministry.meetingDay.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Meets: ${ministry.meetingDay} ${ministry.meetingTime}'),
              ],
              if (ministry.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Location: ${ministry.location}'),
              ],
              if (ministry.whatsappGroup.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL(ministry.whatsappGroup),
                  child: const Text('WhatsApp Group →',
                      style: TextStyle(
                          color: AppColors.childGreen,
                          fontWeight: FontWeight.bold)),
                ),
              ],
              if (ministry.members.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Members:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...ministry.members.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $m'),
                    )),
              ],
              if (canAddEvent) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.event, color: AppColors.blue),
                    label: const Text('Add Event',
                        style: TextStyle(color: AppColors.blue)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEventDialog(ministry.name);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Edit department dialog ────────────────────────────────────────────────

  void _showEditDeptDialog(Department dept) {
    final nameCtrl = TextEditingController(text: dept.name);
    final headCtrl = TextEditingController(text: dept.head);
    final waCtrl = TextEditingController(text: dept.whatsappGroup);
    final membersCtrl =
        TextEditingController(text: dept.members.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Department'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Department Name',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: headCtrl,
                decoration: const InputDecoration(
                    labelText: 'Department Head(s)',
                    hintText: 'Multiple: comma-separated',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                    labelText: 'WhatsApp Group Link',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: membersCtrl,
                decoration: const InputDecoration(
                    labelText: 'Members (comma-separated)',
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveDept(
                dept,
                name: nameCtrl.text.trim(),
                head: headCtrl.text.trim(),
                whatsappGroup: waCtrl.text.trim(),
                members: membersCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Edit ministry dialog ──────────────────────────────────────────────────

  void _showEditMinistryDialog(Ministry ministry) {
    final nameCtrl = TextEditingController(text: ministry.name);
    final descCtrl = TextEditingController(text: ministry.description);
    final leaderCtrl = TextEditingController(text: ministry.leader);
    final dayCtrl = TextEditingController(text: ministry.meetingDay);
    final timeCtrl = TextEditingController(text: ministry.meetingTime);
    final locCtrl = TextEditingController(text: ministry.location);
    final waCtrl = TextEditingController(text: ministry.whatsappGroup);
    final membersCtrl =
        TextEditingController(text: ministry.members.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Ministry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Ministry Name',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: leaderCtrl,
                decoration: const InputDecoration(
                    labelText: 'Leader(s)',
                    hintText: 'Multiple: comma-separated',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dayCtrl,
                decoration: const InputDecoration(
                    labelText: 'Meeting Day (e.g. Sundays)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Meeting Time (e.g. 10:00 AM)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                    labelText: 'WhatsApp Group Link',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: membersCtrl,
                decoration: const InputDecoration(
                    labelText: 'Members (comma-separated)',
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveMinistry(
                ministry,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                leader: leaderCtrl.text.trim(),
                meetingDay: dayCtrl.text.trim(),
                meetingTime: timeCtrl.text.trim(),
                location: locCtrl.text.trim(),
                whatsappGroup: waCtrl.text.trim(),
                members: membersCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Add dialog (FAB) ──────────────────────────────────────────────────────

  void _showAddDialog() {
    final isOnDepts = _tabController.index == 0;
    if (isOnDepts) {
      _showAddDeptDialog();
    } else {
      _showAddMinistryDialog();
    }
  }

  void _showAddDeptDialog() {
    final nameCtrl = TextEditingController();
    final headCtrl = TextEditingController();
    final waCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Department Name',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: headCtrl,
                decoration: const InputDecoration(
                    labelText: 'Department Head',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                    labelText: 'WhatsApp Group Link (optional)',
                    border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _addDept(
                  name: nameCtrl.text.trim(),
                  head: headCtrl.text.trim(),
                  whatsappGroup: waCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMinistryDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final leaderCtrl = TextEditingController();
    final dayCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final waCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ministry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Ministry Name',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder()),
                  maxLines: 2),
              const SizedBox(height: 12),
              TextField(
                  controller: leaderCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Leader',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: dayCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Meeting Day',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Meeting Time',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: waCtrl,
                  decoration: const InputDecoration(
                      labelText: 'WhatsApp Group Link (optional)',
                      border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _addMinistry(
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                leader: leaderCtrl.text.trim(),
                meetingDay: dayCtrl.text.trim(),
                meetingTime: timeCtrl.text.trim(),
                location: locCtrl.text.trim(),
                whatsappGroup: waCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ── Add Event dialog ──────────────────────────────────────────────────────

  void _showAddEventDialog(String groupName) {
    final titleCtrl = TextEditingController(text: '$groupName Event');
    final timeCtrl = TextEditingController(text: '10:00 AM');
    final locCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedType = 'General';
    String selectedStatus = 'Upcoming';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Add Event for $groupName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.calendar_today, color: AppColors.purple),
                  title: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                  subtitle: const Text('Tap to change date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setS(() => selectedDate = picked);
                  },
                ),
                TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Time (e.g. 10:00 AM)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder()),
                  items: ['General', 'Worship', 'Training', 'Outreach', 'Meeting', 'Social']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setS(() => selectedType = v ?? 'General'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final navigator = Navigator.of(ctx);
                try {
                  await _eventService.addEvent(Event(
                    id: '',
                    title: titleCtrl.text.trim(),
                    date: selectedDate,
                    time: timeCtrl.text.trim(),
                    location: locCtrl.text.trim(),
                    type: selectedType,
                    status: 'Upcoming',
                  ));
                  navigator.pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Event added'),
                          backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add event: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white),
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save/Delete helpers ───────────────────────────────────────────────────

  Future<void> _saveDept(
    Department dept, {
    required String name,
    required String head,
    required String whatsappGroup,
    required List<String> members,
  }) async {
    try {
      await _deptService.updateDepartment(
        dept.id,
        name: name,
        head: head,
        whatsappGroup: whatsappGroup,
        members: members,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Department updated'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _addDept({
    required String name,
    required String head,
    required String whatsappGroup,
  }) async {
    try {
      await _deptService.addDepartment(
          name: name, head: head, whatsappGroup: whatsappGroup);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Department added'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteDept(Department dept) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department?'),
        content: Text('Delete "${dept.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _deptService.deleteDepartment(dept.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _saveMinistry(
    Ministry ministry, {
    required String name,
    required String description,
    required String leader,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
    required List<String> members,
  }) async {
    try {
      await _minService.updateMinistry(
        ministry.id,
        name: name,
        description: description,
        leader: leader,
        meetingDay: meetingDay,
        meetingTime: meetingTime,
        location: location,
        whatsappGroup: whatsappGroup,
        members: members,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ministry updated'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _addMinistry({
    required String name,
    required String description,
    required String leader,
    required String meetingDay,
    required String meetingTime,
    required String location,
    required String whatsappGroup,
  }) async {
    try {
      await _minService.addMinistry(
        name: name,
        description: description,
        leader: leader,
        meetingDay: meetingDay,
        meetingTime: meetingTime,
        location: location,
        whatsappGroup: whatsappGroup,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ministry added'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteMinistry(Ministry ministry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ministry?'),
        content: Text('Delete "${ministry.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _minService.deleteMinistry(ministry.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ministry deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }
}
