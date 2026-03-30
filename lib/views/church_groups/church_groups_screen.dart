import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/church_group.dart';
import '../../models/user.dart';
import '../../services/church_group_service.dart';
import '../../services/auth_service.dart';
import '../../services/join_request_service.dart';
import '../../utils/colors.dart';

class ChurchGroupsScreen extends StatefulWidget {
  const ChurchGroupsScreen({super.key});

  @override
  State<ChurchGroupsScreen> createState() => _ChurchGroupsScreenState();
}

class _ChurchGroupsScreenState extends State<ChurchGroupsScreen> {
  final _groupService = ChurchGroupService();
  final _authService = AuthService();
  final _joinService = JoinRequestService();

  List<ChurchGroup> _groups = [];
  AppUser? _currentUser;
  String? _userId;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _groupService.getAllGroups(),
        _authService.getCurrentUserProfile(),
        _authService.getCurrentUserId(),
        _authService.getCurrentUserName(),
      ]);
      setState(() {
        _groups = results[0] as List<ChurchGroup>;
        _currentUser = results[1] as AppUser?;
        _userId = results[2] as String?;
        _userName = results[3] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool get _isAdmin =>
      _currentUser?.isAdmin ?? false;

  bool _canEdit(String groupName) =>
      _currentUser?.canEditDepartment(groupName) ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Groups'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _groups.isEmpty
                  ? const Center(child: Text('No groups yet'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) =>
                          _buildGroupCard(_groups[index]),
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddGroupDialog,
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildGroupCard(ChurchGroup group) {
    final canEdit = _canEdit(group.name);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.groups, color: AppColors.brown, size: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 16, color: AppColors.purple),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditGroupDialog(group),
                          tooltip: 'Edit',
                        ),
                      if (group.whatsappGroup.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.chat, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: const Color(0xFF25D366),
                          onPressed: () => _openWhatsApp(group.whatsappGroup),
                          tooltip: 'WhatsApp Group',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                group.name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                group.leader,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                group.description,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (group.meetingDay.isNotEmpty)
                Text(
                  '${group.meetingDay} · ${group.meetingTime}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (canEdit)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'You manage this',
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (!canEdit && _userId != null) ...[
                const SizedBox(height: 6),
                FutureBuilder<bool>(
                  future: _joinService.hasUserRequested(_userId!, group.id),
                  builder: (ctx, snap) {
                    final hasPending = snap.data == true;
                    final isMember = group.members.any((m) =>
                        m.toLowerCase() ==
                        (_userName ?? '').toLowerCase());
                    if (isMember) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Member',
                          style: TextStyle(
                              fontSize: 9,
                              color: AppColors.success,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: hasPending
                            ? null
                            : () => _requestJoin(group),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          side: BorderSide(
                            color: hasPending
                                ? Colors.grey
                                : AppColors.purple,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(
                          hasPending ? 'Request Sent' : 'Request to Join',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                hasPending ? Colors.grey : AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestJoin(ChurchGroup group) async {
    if (_userId == null) return;
    final msgController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Join ${group.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your request will be sent to the group leader for approval.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Why would you like to join? (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _joinService.submitRequest(
        userId: _userId!,
        userName: _userName ?? 'Member',
        groupId: group.id,
        groupName: group.name,
        groupType: GroupType.department,
        message: msgController.text.trim(),
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request to join ${group.name} sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  void _openWhatsApp(String url) {
    if (url.isEmpty) return;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError(
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp link')),
          );
        }
        return false;
      },
    );
  }

  void _showGroupDetails(ChurchGroup group) {
    final canEdit = _canEdit(group.name);
    final isUshering = group.name.toLowerCase().contains('usher');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(group.name)),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.purple),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEditGroupDialog(group);
                },
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              _infoRow(Icons.person, 'Leader', group.leader),
              if (group.meetingDay.isNotEmpty) ...[
                const SizedBox(height: 6),
                _infoRow(Icons.calendar_today, 'Meeting',
                    '${group.meetingDay} at ${group.meetingTime}'),
              ],
              if (group.location.isNotEmpty) ...[
                const SizedBox(height: 6),
                _infoRow(Icons.location_on, 'Location', group.location),
              ],
              if (group.members.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('${group.members.length} member${group.members.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                ...group.members.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('• $m',
                          style: const TextStyle(fontSize: 13)),
                    )),
              ],
              if (group.whatsappGroup.isNotEmpty) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openWhatsApp(group.whatsappGroup),
                  child: const Row(
                    children: [
                      Icon(Icons.chat, color: Color(0xFF25D366), size: 16),
                      SizedBox(width: 4),
                      Text('Open WhatsApp Group',
                          style: TextStyle(
                              color: Color(0xFF25D366),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              if (isUshering) ...[
                const SizedBox(height: 12),
                _buildUsheringPlan(),
              ],
              if (canEdit) ...[
                const SizedBox(height: 12),
                _buildJoinRequestsSection(group),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.purple),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinRequestsSection(ChurchGroup group) {
    return FutureBuilder<List<JoinRequest>>(
      future: _joinService.getPendingForGroup(group.id),
      builder: (ctx, snap) {
        final pending = snap.data ?? [];
        if (pending.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pending_actions,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${pending.length} Join Request${pending.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pending.map((req) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.userName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (req.message.isNotEmpty)
                          Text('"${req.message}"',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await _joinService.reviewRequest(req.id, false);
                                if (ctx.mounted) setState(() {});
                              },
                              child: const Text('Decline',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _joinService.reviewRequest(req.id, true);
                                final updated = group.members.contains(req.userName)
                                    ? group.members
                                    : [...group.members, req.userName];
                                await _groupService.updateGroup(
                                  group.id,
                                  name: group.name,
                                  description: group.description,
                                  leader: group.leader,
                                  members: updated,
                                  meetingDay: group.meetingDay,
                                  meetingTime: group.meetingTime,
                                  location: group.location,
                                  whatsappGroup: group.whatsappGroup,
                                );
                                await _loadData();
                                if (ctx.mounted) setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildUsheringPlan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purple),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ushering 2026 Growth Plan',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                  fontSize: 13)),
          SizedBox(height: 8),
          Text('• Target: 6–8 ushers by Dec 2026'),
          Text('• Quarterly training: Apr | Jul | Sep | Nov'),
          Text('• Responsibilities: hospitality & premises security'),
          Text('• Annual appreciation gathering: December'),
          SizedBox(height: 6),
          Text('Budget: \$565 – \$1,670',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.success)),
        ],
      ),
    );
  }

  void _showEditGroupDialog(ChurchGroup group) {
    final nameCtrl = TextEditingController(text: group.name);
    final descCtrl = TextEditingController(text: group.description);
    final leaderCtrl = TextEditingController(text: group.leader);
    final dayCtrl = TextEditingController(text: group.meetingDay);
    final timeCtrl = TextEditingController(text: group.meetingTime);
    final locationCtrl = TextEditingController(text: group.location);
    final waCtrl = TextEditingController(text: group.whatsappGroup);
    final membersCtrl =
        TextEditingController(text: group.members.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Name'),
              const SizedBox(height: 12),
              _field(descCtrl, 'Description', maxLines: 3),
              const SizedBox(height: 12),
              _field(leaderCtrl, 'Leader'),
              const SizedBox(height: 12),
              _field(dayCtrl, 'Meeting Day'),
              const SizedBox(height: 12),
              _field(timeCtrl, 'Meeting Time'),
              const SizedBox(height: 12),
              _field(locationCtrl, 'Location'),
              const SizedBox(height: 12),
              TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Group Link',
                  hintText: 'https://chat.whatsapp.com/...',
                  prefixIcon:
                      Icon(Icons.chat, color: Color(0xFF25D366)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _field(membersCtrl, 'Members (comma-separated)',
                  maxLines: 3),
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
              Navigator.pop(ctx);
              await _groupService.updateGroup(
                group.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                leader: leaderCtrl.text.trim(),
                members: membersCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
                meetingDay: dayCtrl.text.trim(),
                meetingTime: timeCtrl.text.trim(),
                location: locationCtrl.text.trim(),
                whatsappGroup: waCtrl.text.trim(),
              );
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group updated'),
                    backgroundColor: AppColors.success,
                  ),
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
    );
  }

  void _showAddGroupDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final leaderCtrl = TextEditingController();
    final dayCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final waCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Name'),
              const SizedBox(height: 12),
              _field(descCtrl, 'Description', maxLines: 3),
              const SizedBox(height: 12),
              _field(leaderCtrl, 'Leader'),
              const SizedBox(height: 12),
              _field(dayCtrl, 'Meeting Day'),
              const SizedBox(height: 12),
              _field(timeCtrl, 'Meeting Time'),
              const SizedBox(height: 12),
              _field(locationCtrl, 'Location'),
              const SizedBox(height: 12),
              TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Group Link (optional)',
                  hintText: 'https://chat.whatsapp.com/...',
                  prefixIcon:
                      Icon(Icons.chat, color: Color(0xFF25D366)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
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
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _groupService.addGroup(
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                leader: leaderCtrl.text.trim(),
                meetingDay: dayCtrl.text.trim(),
                meetingTime: timeCtrl.text.trim(),
                location: locationCtrl.text.trim(),
                whatsappGroup: waCtrl.text.trim(),
              );
              await _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
    );
  }
}
