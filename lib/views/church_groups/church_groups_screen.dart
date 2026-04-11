import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/org_group.dart';
import '../../services/supabase_service.dart';
import '../../models/dues_entry.dart';
import '../../models/group_finance.dart';
import '../../models/user.dart';
import '../../services/org_group_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class ChurchGroupsScreen extends StatefulWidget {
  const ChurchGroupsScreen({super.key});

  @override
  State<ChurchGroupsScreen> createState() => _ChurchGroupsScreenState();
}

class _ChurchGroupsScreenState extends State<ChurchGroupsScreen> {
  final _service = OrgGroupService();
  final _auth = AuthService();

  List<OrgGroup> _groups = [];
  AppUser? _me;
  String? _userId;
  String? _userName;
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait<dynamic>([
        _service.getAllGroups(),
        _auth.getCurrentUserProfile(),
        _auth.getCurrentUserId(),
        _auth.getCurrentUserName(),
      ]);
      setState(() {
        _groups = results[0] as List<OrgGroup>;
        _me = results[1] as AppUser?;
        _userId = results[2] as String?;
        _userName = results[3] as String?;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool get _isAdmin => _me?.role == UserRole.admin || _me?.role == UserRole.pastor;

  bool _isLeaderOf(OrgGroup g) {
    if (_userId == null) return false;
    return g.leader == _userId ||
        g.leader == _userName ||
        (_me?.role == UserRole.dept_head &&
            (_me?.department.toLowerCase().contains(g.name.toLowerCase()) ?? false));
  }

  bool _canManage(OrgGroup g) => _isAdmin || _isLeaderOf(g);

  List<OrgGroup> get _filtered {
    if (_search.isEmpty) return _groups;
    final q = _search.toLowerCase();
    return _groups.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Church Groups',
            style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.accentPurple),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.accentPurple),
              onPressed: _showAddGroupDialog,
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search groups…',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: AppColors.darkSurface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : _filtered.isEmpty
              ? const Center(
                  child: Text('No groups found',
                      style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) => _GroupCard(
                    group: _filtered[i],
                    canManage: _canManage(_filtered[i]),
                    userId: _userId,
                    userName: _userName,
                    onTap: () => _openGroup(_filtered[i]),
                    onEdit: _canManage(_filtered[i]) ? () => _showEditDialog(_filtered[i]) : null,
                    onDelete: _isAdmin ? () => _deleteGroup(_filtered[i]) : null,
                  ),
                ),
    );
  }

  void _openGroup(OrgGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GroupDetailScreen(
          group: group,
          service: _service,
          userId: _userId,
          userName: _userName,
          isAdmin: _isAdmin,
          isLeader: _canManage(group),
          onChanged: _load,
        ),
      ),
    );
  }

  Future<String?> _uploadGroupCover(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final path = 'groups/${const Uuid().v4()}.$ext';
    try {
      return await SupabaseService().uploadImage('church-media', path, file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ));
      }
      return null;
    }
  }

  void _showAddGroupDialog() {
    _showGroupFormDialog(null);
  }

  void _showEditDialog(OrgGroup g) {
    _showGroupFormDialog(g);
  }

  void _showGroupFormDialog(OrgGroup? existing) {
    final nameC = TextEditingController(text: existing?.name);
    final descC = TextEditingController(text: existing?.description);
    final leaderC = TextEditingController(text: existing?.leader);
    final meetC = TextEditingController(text: existing?.meetingTime);
    final locationC = TextEditingController(text: existing?.location);
    final gmeetC = TextEditingController(text: existing?.googleMeetLink);
    final waC = TextEditingController(text: existing?.whatsappGroup);
    final bylawsC = TextEditingController(text: existing?.bylaws);
    final duesC = TextEditingController(text: existing?.dues.toString() ?? '');
    String duesPeriod = existing?.duesPeriod ?? 'monthly';
    File? coverFile;
    String coverUrl = existing?.coverUrl ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: Text(existing == null ? 'Add Group' : 'Edit Group',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(builder: (ctx2, setSt) {
            return SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Cover photo picker
                GestureDetector(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery, imageQuality: 85);
                    if (picked != null) setSt(() => coverFile = File(picked.path));
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: coverFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(coverFile!, fit: BoxFit.cover, width: double.infinity))
                        : coverUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(coverUrl, fit: BoxFit.cover, width: double.infinity))
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.add_photo_alternate, color: AppColors.accentPurple, size: 28),
                                SizedBox(height: 4),
                                Text('Add Cover Photo', style: TextStyle(fontSize: 12, color: AppColors.accentPurple)),
                              ]),
                  ),
                ),
                const SizedBox(height: 10),
                _DarkField(controller: nameC, label: 'Group Name *'),
                const SizedBox(height: 10),
                _DarkField(controller: descC, label: 'Description', maxLines: 3),
                const SizedBox(height: 10),
                _DarkField(controller: leaderC, label: 'Leader Name'),
                const SizedBox(height: 10),
                _DarkField(controller: meetC, label: 'Meeting Time'),
                const SizedBox(height: 10),
                _DarkField(controller: locationC, label: 'Meeting Location'),
                const SizedBox(height: 10),
                _DarkField(controller: gmeetC, label: 'Google Meet Link'),
                const SizedBox(height: 10),
                _DarkField(controller: waC, label: 'WhatsApp Group Link'),
                const SizedBox(height: 10),
                _DarkField(controller: bylawsC, label: 'Bylaws / Rules', maxLines: 4),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _DarkField(controller: duesC, label: 'Dues Amount', keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: duesPeriod,
                      dropdownColor: AppColors.darkSurface2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Period',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                      ),
                      items: ['monthly', 'quarterly', 'annual']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setSt(() => duesPeriod = v ?? 'monthly'),
                    ),
                  ),
                ]),
              ]),
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
            child: Text(existing == null ? 'Add' : 'Save'),
            onPressed: () async {
              if (nameC.text.trim().isEmpty) return;
              String finalCoverUrl = coverUrl;
              if (coverFile != null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Uploading cover…'),
                      duration: Duration(seconds: 30)));
                }
                finalCoverUrl = await _uploadGroupCover(coverFile!) ?? coverUrl;
                if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
              final data = OrgGroup(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameC.text.trim(),
                description: descC.text.trim(),
                leaders: leaderC.text.trim().isNotEmpty ? [leaderC.text.trim()] : [],
                meetingTime: meetC.text.trim(),
                location: locationC.text.trim(),
                members: existing?.members ?? [],
                pendingMembers: existing?.pendingMembers ?? [],
                imageEmoji: existing?.imageEmoji ?? '🙏',
                whatsappGroup: waC.text.trim(),
                googleMeetLink: gmeetC.text.trim(),
                bylaws: bylawsC.text.trim(),
                dues: double.tryParse(duesC.text) ?? 0,
                duesPeriod: duesPeriod,
                coverUrl: finalCoverUrl,
              );
              if (existing == null) {
                await _service.addGroup(data);
              } else {
                await _service.updateGroup(data);
              }
              Navigator.pop(ctx);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(OrgGroup g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Delete Group?', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${g.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.deleteGroup(g.id);
      _load();
    }
  }
}

// ── Group Card ─────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final OrgGroup group;
  final bool canManage;
  final String? userId;
  final String? userName;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupCard({
    required this.group,
    required this.canManage,
    required this.userId,
    required this.userName,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pending = group.pendingMembers.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: AppColors.glowPurple(radius: 10, opacity: 0.08),
        ),
        child: Row(
          children: [
            if (group.coverUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  group.coverUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.darkSurface2, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(group.imageEmoji, style: const TextStyle(fontSize: 22))),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Center(
                    child: Text(group.imageEmoji,
                        style: const TextStyle(fontSize: 22))),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(group.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    if (pending > 0 && canManage)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$pending pending',
                            style: const TextStyle(
                                color: AppColors.accentGold, fontSize: 11)),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  if (group.leader.isNotEmpty)
                    Text('Leader: ${group.leader}',
                        style: const TextStyle(
                            color: AppColors.accentPurple, fontSize: 12)),
                  if (group.description.isNotEmpty)
                    Text(group.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.people_outline,
                        size: 13, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text('${group.members.length} members',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                    if (group.meetingTime.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.schedule,
                          size: 13, color: Colors.white38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(group.meetingTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            Column(children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.accentPurple),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Group Detail Screen ───────────────────────────────────────────────────────
class _GroupDetailScreen extends StatefulWidget {
  final OrgGroup group;
  final OrgGroupService service;
  final String? userId;
  final String? userName;
  final bool isAdmin;
  final bool isLeader;
  final VoidCallback onChanged;

  const _GroupDetailScreen({
    required this.group,
    required this.service,
    required this.userId,
    required this.userName,
    required this.isAdmin,
    required this.isLeader,
    required this.onChanged,
  });

  @override
  State<_GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<_GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late OrgGroup _group;
  List<DuesEntry> _dues = [];
  List<GroupFinance> _finances = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _tabs = TabController(length: 4, vsync: this);
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    setState(() => _loading = true);
    final results = await Future.wait<dynamic>([
      widget.service.getDuesLog(_group.id),
      widget.service.getGroupFinances(_group.id),
    ]);
    setState(() {
      _dues = results[0] as List<DuesEntry>;
      _finances = results[1] as List<GroupFinance>;
      _loading = false;
    });
  }

  Future<void> _refreshGroup() async {
    final groups = await widget.service.getAllGroups();
    final updated = groups.firstWhere((g) => g.id == _group.id, orElse: () => _group);
    setState(() => _group = updated);
    await _loadExtras();
    widget.onChanged();
  }

  bool get _isMember => _group.members.contains(widget.userId) ||
      _group.members.contains(widget.userName);
  bool get _isPending => _group.pendingMembers.contains(widget.userId) ||
      _group.pendingMembers.contains(widget.userName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Row(children: [
          Text(_group.imageEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_group.name,
                style: const TextStyle(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        iconTheme: const IconThemeData(color: AppColors.accentPurple),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accentPurple,
          labelColor: AppColors.accentPurple,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Members'),
            Tab(text: 'Dues Log'),
            Tab(text: 'Finances'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : TabBarView(
              controller: _tabs,
              children: [
                _AboutTab(group: _group, isLeader: widget.isLeader || widget.isAdmin,
                    isMember: _isMember, isPending: _isPending,
                    userId: widget.userId, userName: widget.userName,
                    service: widget.service, onChanged: _refreshGroup),
                _MembersTab(group: _group, isLeader: widget.isLeader || widget.isAdmin,
                    userId: widget.userId, userName: widget.userName,
                    service: widget.service, onChanged: _refreshGroup),
                _DuesTab(group: _group, dues: _dues,
                    isLeader: widget.isLeader || widget.isAdmin,
                    userId: widget.userId, userName: widget.userName,
                    service: widget.service, onChanged: _loadExtras),
                _FinancesTab(group: _group, finances: _finances,
                    isLeader: widget.isLeader || widget.isAdmin,
                    service: widget.service, onChanged: _loadExtras,
                    userId: widget.userId, userName: widget.userName),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

// ── About Tab ─────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final OrgGroup group;
  final bool isLeader;
  final bool isMember;
  final bool isPending;
  final String? userId;
  final String? userName;
  final OrgGroupService service;
  final VoidCallback onChanged;

  const _AboutTab({
    required this.group, required this.isLeader, required this.isMember,
    required this.isPending, required this.userId, required this.userName,
    required this.service, required this.onChanged,
  });

  Future<void> _openUrl(BuildContext ctx, String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        _InfoCard(children: [
          Text(group.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          if (group.leader.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Leader: ${group.leader}',
                style: const TextStyle(color: AppColors.accentPurple, fontSize: 14)),
          ],
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(group.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ]),
        const SizedBox(height: 12),

        // Meeting info
        if (group.meetingTime.isNotEmpty || group.location.isNotEmpty)
          _InfoCard(title: 'Meeting Info', children: [
            if (group.meetingTime.isNotEmpty)
              _Row(icon: Icons.schedule, label: group.meetingTime),
            if (group.location.isNotEmpty)
              _Row(icon: Icons.location_on_outlined, label: group.location),
          ]),

        // Links
        if (group.googleMeetLink.isNotEmpty == true ||
            group.whatsappGroup.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Quick Links', children: [
            if (group.googleMeetLink.isNotEmpty == true)
              _LinkButton(
                icon: Icons.videocam_outlined,
                label: 'Join Google Meet',
                color: AppColors.googleMeet,
                onTap: () => _openUrl(context, group.googleMeetLink),
              ),
            if (group.whatsappGroup.isNotEmpty)
              _LinkButton(
                icon: Icons.chat_bubble_outline,
                label: 'WhatsApp Group',
                color: const Color(0xFF25D366),
                onTap: () => _openUrl(context, group.whatsappGroup),
              ),
          ]),
        ],

        // Dues info
        ...[
        const SizedBox(height: 12),
        _InfoCard(title: 'Dues', children: [
          _Row(
            icon: Icons.payments_outlined,
            label: 'GHS ${group.dues!.toStringAsFixed(2)} / ${group.duesPeriod ?? "monthly"}',
          ),
        ]),
      ],

        // Bylaws
        if (group.bylaws.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Bylaws & Rules', children: [
            Text(group.bylaws,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ],

        const SizedBox(height: 16),
        // Join / status button
        if (!isLeader) ...[
          if (isMember)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.4)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline, color: AppColors.success),
                SizedBox(width: 8),
                Text('You are a member of this group',
                    style: TextStyle(color: AppColors.success)),
              ]),
            )
          else if (isPending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.hourglass_top_outlined, color: AppColors.accentGold),
                SizedBox(width: 8),
                Text('Join request pending approval',
                    style: TextStyle(color: AppColors.accentGold)),
              ]),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  minimumSize: const Size(double.infinity, 48)),
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Request to Join'),
              onPressed: () async {
                final id = userId ?? '';
                final name = userName ?? '';
                if (id.isEmpty && name.isEmpty) return;
                await service.requestToJoin(group.id, id.isNotEmpty ? id : name);
                onChanged();
              },
            ),
        ],
      ],
    );
  }
}

// ── Members Tab ───────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final OrgGroup group;
  final bool isLeader;
  final String? userId;
  final String? userName;
  final OrgGroupService service;
  final VoidCallback onChanged;

  const _MembersTab({
    required this.group, required this.isLeader, required this.userId,
    required this.userName, required this.service, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pending approvals
        if (isLeader && group.pendingMembers.isNotEmpty) ...[
          const Text('Pending Approvals',
              style: TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 8),
          ...group.pendingMembers.map((m) => _MemberTile(
            name: m,
            subtitle: 'Awaiting approval',
            subtitleColor: AppColors.accentGold,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                onPressed: () async {
                  await service.approveMember(group.id, m);
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                onPressed: () async {
                  await service.rejectMember(group.id, m);
                  onChanged();
                },
              ),
            ]),
          )),
          const Divider(color: AppColors.darkBorder, height: 24),
        ],

        // Members
        Row(children: [
          Expanded(
              child: Text('Members (${group.members.length})',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15))),
          if (isLeader)
            TextButton.icon(
              icon: const Icon(Icons.person_add_outlined,
                  size: 16, color: AppColors.accentPurple),
              label: const Text('Add',
                  style: TextStyle(color: AppColors.accentPurple)),
              onPressed: () => _addMemberDialog(context),
            ),
        ]),
        const SizedBox(height: 8),
        if (group.members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No members yet.',
                style: TextStyle(color: Colors.white38),
                textAlign: TextAlign.center),
          ),
        ...group.members.map((m) => _MemberTile(
          name: m,
          trailing: isLeader
              ? IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 18, color: Colors.red),
                  onPressed: () async {
                    await service.removeMember(group.id, m);
                    onChanged();
                  },
                )
              : null,
        )),
      ],
    );
  }

  void _addMemberDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Add Member', style: TextStyle(color: Colors.white)),
        content: _DarkField(controller: ctrl, label: 'Member Name or ID'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
            child: const Text('Add'),
            onPressed: () async {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              await service.approveMember(group.id, v);
              Navigator.pop(ctx);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Dues Log Tab ──────────────────────────────────────────────────────────────
class _DuesTab extends StatelessWidget {
  final OrgGroup group;
  final List<DuesEntry> dues;
  final bool isLeader;
  final String? userId;
  final String? userName;
  final OrgGroupService service;
  final VoidCallback onChanged;

  const _DuesTab({
    required this.group, required this.dues, required this.isLeader,
    required this.userId, required this.userName,
    required this.service, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = dues.fold<double>(0, (s, d) => s + d.amount);
    return Column(
      children: [
        if (dues.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Collected',
                  style: TextStyle(color: Colors.white70)),
              Text('GHS ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ]),
          ),
        Expanded(
          child: dues.isEmpty
              ? const Center(
                  child: Text('No dues recorded yet.',
                      style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: dues.length,
                  itemBuilder: (ctx, i) {
                    final d = dues[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.memberName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text(d.period,
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          if (d.note.isNotEmpty)
                            Text(d.note, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('GHS ${d.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold)),
                          Text(_formatDate(d.date),
                              style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ]),
                        if (isLeader)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 16, color: Colors.red),
                            onPressed: () async {
                              await service.deleteDuesEntry(d.id);
                              onChanged();
                            },
                            constraints: const BoxConstraints(minWidth: 32),
                            padding: EdgeInsets.zero,
                          ),
                      ]),
                    );
                  }),
        ),
        if (isLeader)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  minimumSize: const Size(double.infinity, 48)),
              icon: const Icon(Icons.add),
              label: const Text('Record Dues Payment'),
              onPressed: () => _showAddDues(context),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  void _showAddDues(BuildContext context) {
    final nameC = TextEditingController();
    final amtC = TextEditingController();
    final noteC = TextEditingController();
    String period = group.duesPeriod ?? 'monthly';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Record Dues Payment', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(builder: (ctx2, setSt) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            _DarkField(controller: nameC, label: 'Member Name'),
            const SizedBox(height: 10),
            _DarkField(controller: amtC, label: 'Amount (GHS)', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: period,
              dropdownColor: AppColors.darkSurface2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Period',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
              ),
              items: ['monthly', 'quarterly', 'annual', 'one-time']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setSt(() => period = v ?? 'monthly'),
            ),
            const SizedBox(height: 10),
            _DarkField(controller: noteC, label: 'Note (optional)'),
          ]);
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
            child: const Text('Save'),
            onPressed: () async {
              final name = nameC.text.trim();
              final amt = double.tryParse(amtC.text.trim());
              if (name.isEmpty || amt == null) return;
              await service.addDuesEntry(DuesEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                groupId: group.id,
                memberName: name,
                amount: amt,
                date: DateTime.now(),
                period: period,
                note: noteC.text.trim(),
                postedBy: userName ?? '',
              ));
              Navigator.pop(ctx);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Finances Tab ──────────────────────────────────────────────────────────────
class _FinancesTab extends StatelessWidget {
  final OrgGroup group;
  final List<GroupFinance> finances;
  final bool isLeader;
  final String? userId;
  final String? userName;
  final OrgGroupService service;
  final VoidCallback onChanged;

  const _FinancesTab({
    required this.group, required this.finances, required this.isLeader,
    required this.userId, required this.userName,
    required this.service, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: finances.isEmpty
              ? const Center(
                  child: Text('No finance entries yet.',
                      style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: finances.length,
                  itemBuilder: (ctx, i) {
                    final f = finances[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        iconColor: AppColors.accentPurple,
                        collapsedIconColor: Colors.white38,
                        title: Text(f.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Row(children: [
                          Text(f.category,
                              style: const TextStyle(
                                  color: AppColors.accentPurple, fontSize: 12)),
                          if (f.amount != null) ...[
                            const SizedBox(width: 8),
                            Text('GHS ${f.amount!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppColors.accentGold, fontSize: 12)),
                          ],
                        ]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.body,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Posted by ${f.postedBy} · ${_formatDate(f.date)}',
                                        style: const TextStyle(
                                            color: Colors.white38, fontSize: 11)),
                                    if (isLeader)
                                      GestureDetector(
                                        onTap: () async {
                                          await service.deleteFinanceEntry(f.id);
                                          onChanged();
                                        },
                                        child: const Text('Delete',
                                            style: TextStyle(
                                                color: Colors.red, fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
        ),
        if (isLeader)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  minimumSize: const Size(double.infinity, 48)),
              icon: const Icon(Icons.post_add_outlined),
              label: const Text('Post Finance Entry'),
              onPressed: () => _showAddFinance(context),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showAddFinance(BuildContext context) {
    final titleC = TextEditingController();
    final bodyC = TextEditingController();
    final amtC = TextEditingController();
    String category = 'budget';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Post Finance Entry', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(builder: (ctx2, setSt) {
          return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DarkField(controller: titleC, label: 'Title *'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: category,
                dropdownColor: AppColors.darkSurface2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                  border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                ),
                items: ['budget', 'expense', 'report', 'plan', 'other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setSt(() => category = v ?? 'budget'),
              ),
              const SizedBox(height: 10),
              _DarkField(controller: amtC, label: 'Amount (GHS, optional)', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _DarkField(controller: bodyC, label: 'Details / Description *', maxLines: 5),
            ]),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
            child: const Text('Post'),
            onPressed: () async {
              if (titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty) return;
              await service.addFinanceEntry(GroupFinance(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                groupId: group.id,
                title: titleC.text.trim(),
                body: bodyC.text.trim(),
                amount: double.tryParse(amtC.text.trim()) ?? 0,
                date: DateTime.now(),
                postedBy: userName ?? '',
                category: category,
              ));
              Navigator.pop(ctx);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: const TextStyle(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ]),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.open_in_new, color: color.withOpacity(0.6), size: 14),
        ]),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;

  const _MemberTile({required this.name, this.subtitle, this.subtitleColor, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.accentPurple.withOpacity(0.15),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.accentPurple, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            if (subtitle != null)
              Text(subtitle!,
                  style: TextStyle(
                      color: subtitleColor ?? Colors.white54, fontSize: 12)),
          ],
        )),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors.darkSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentPurple),
        ),
      ),
    );
  }
}
