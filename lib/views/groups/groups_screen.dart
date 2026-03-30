import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/org_group.dart';
import '../../models/user.dart';
import '../../services/org_group_service.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../../utils/colors.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupService = OrgGroupService();
  final _authService = AuthService();
  final _eventService = EventService();

  List<OrgGroup> _groups = [];
  List<OrgGroup> _filtered = [];
  AppUser? _currentUser;
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _groupService.getAllGroups(),
      _authService.getCurrentUserProfile(),
    ]);
    if (mounted) {
      setState(() {
        _groups = results[0] as List<OrgGroup>;
        _currentUser = results[1] as AppUser?;
        _filtered = List.from(_groups);
        _loading = false;
      });
    }
  }

  void _filterGroups() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_groups)
          : _groups
              .where((g) =>
                  g.name.toLowerCase().contains(q) ||
                  g.leaders.any((l) => l.toLowerCase().contains(q)) ||
                  g.description.toLowerCase().contains(q))
              .toList();
    });
  }

  bool get _isAdmin => _currentUser?.isAdmin ?? false;

  bool _canEdit(OrgGroup group) {
    if (_isAdmin) return true;
    return _currentUser?.canEditDepartment(group.name) ?? false;
  }

  // ── ADD / EDIT ────────────────────────────────────────────────────────────

  Future<void> _showGroupDialog({OrgGroup? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final leadersCtrl = TextEditingController(
        text: existing?.leaders.join(', ') ?? '');
    final meetingDayCtrl =
        TextEditingController(text: existing?.meetingDay ?? '');
    final meetingTimeCtrl =
        TextEditingController(text: existing?.meetingTime ?? '');
    final locationCtrl =
        TextEditingController(text: existing?.location ?? '');
    final whatsappCtrl =
        TextEditingController(text: existing?.whatsappGroup ?? '');
    final membersCtrl = TextEditingController(
        text: existing?.members.join(', ') ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Group' : 'Edit Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Group Name', Icons.group),
              _field(descCtrl, 'Description', Icons.description, lines: 2),
              _field(leadersCtrl, 'Leaders (comma-separated)',
                  Icons.manage_accounts),
              _field(meetingDayCtrl, 'Meeting Day', Icons.calendar_today),
              _field(meetingTimeCtrl, 'Meeting Time', Icons.access_time),
              _field(locationCtrl, 'Location', Icons.location_on),
              _field(whatsappCtrl, 'WhatsApp Link', Icons.chat),
              _field(membersCtrl, 'Members (comma-separated)', Icons.people,
                  lines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final leaders = leadersCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final members = membersCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              Navigator.pop(ctx);
              if (existing == null) {
                await _groupService.addGroup(
                  name: name,
                  description: descCtrl.text.trim(),
                  leaders: leaders,
                  meetingDay: meetingDayCtrl.text.trim(),
                  meetingTime: meetingTimeCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  whatsappGroup: whatsappCtrl.text.trim(),
                );
              } else {
                await _groupService.updateGroup(
                  existing.id,
                  name: name,
                  description: descCtrl.text.trim(),
                  leaders: leaders,
                  members: members,
                  meetingDay: meetingDayCtrl.text.trim(),
                  meetingTime: meetingTimeCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  whatsappGroup: whatsappCtrl.text.trim(),
                );
              }
              await _load();
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.purple, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.purple, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(OrgGroup group) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Delete "${group.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _groupService.deleteGroup(group.id);
      await _load();
    }
  }

  // ── ADD EVENT ─────────────────────────────────────────────────────────────

  Future<void> _showAddEventDialog(OrgGroup group) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: group.location);
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Add Event — ${group.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(titleCtrl, 'Event Title', Icons.event),
                _field(descCtrl, 'Description', Icons.description, lines: 2),
                _field(locationCtrl, 'Location', Icons.location_on),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppColors.purple),
                    const SizedBox(width: 8),
                    Text(
                        '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (picked != null) setS(() => selectedDate = picked);
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await _eventService.addEvent(Event.create(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  date: selectedDate,
                  location: locationCtrl.text.trim(),
                  department: group.name,
                ));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event added for ${group.name}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  // ── DETAIL SHEET ──────────────────────────────────────────────────────────

  void _showDetail(OrgGroup group) {
    final canEdit = _canEdit(group);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                    radius: 26,
                    child: const Icon(Icons.group, color: AppColors.purple, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(group.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(group.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
              const SizedBox(height: 16),
              if (group.leaders.isNotEmpty)
                _detailRow(Icons.manage_accounts, 'Leader(s)',
                    group.leaders.join(', ')),
              if (group.meetingDay.isNotEmpty)
                _detailRow(Icons.calendar_today, 'Meeting Day',
                    group.meetingDay),
              if (group.meetingTime.isNotEmpty)
                _detailRow(Icons.access_time, 'Time', group.meetingTime),
              if (group.location.isNotEmpty)
                _detailRow(Icons.location_on, 'Location', group.location),
              if (group.members.isNotEmpty) ...[
                const SizedBox(height: 8),
                _detailRow(Icons.people, 'Members',
                    '${group.members.length} member(s)'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: group.members
                      .map((m) => Chip(
                            label: Text(m,
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor:
                                AppColors.purple.withValues(alpha: 0.08),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              // Action buttons
              if (group.whatsappGroup.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                    label: const Text('Join WhatsApp Group',
                        style: TextStyle(color: Color(0xFF25D366))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF25D366)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(group.whatsappGroup);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              if (canEdit) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.purple,
                          side: const BorderSide(color: AppColors.purple),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showGroupDialog(existing: group);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: const Text('Add Event'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          side: const BorderSide(color: AppColors.blue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddEventDialog(group);
                        },
                      ),
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete(group);
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.purple),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups & Ministries'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Group'),
              onPressed: () => _showGroupDialog(),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search groups...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.purple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text('No groups found',
                              style: TextStyle(color: Colors.grey)))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _buildCard(_filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCard(OrgGroup group) {
    final canEdit = _canEdit(group);
    return GestureDetector(
      onTap: () => _showDetail(group),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                  radius: 18,
                  child: const Icon(Icons.group, color: AppColors.purple, size: 18),
                ),
                const Spacer(),
                if (canEdit)
                  GestureDetector(
                    onTap: () => _showGroupDialog(existing: group),
                    child: const Icon(Icons.edit, size: 16, color: AppColors.purple),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              group.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (group.leaders.isNotEmpty)
              Text(
                group.leaders.first,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const Spacer(),
            if (group.meetingDay.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 11, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      group.meetingDay,
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (group.members.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.people, size: 11, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Text(
                    '${group.members.length} member${group.members.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
