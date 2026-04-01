import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../services/member_service.dart';
import '../../services/auth_service.dart';
import '../../services/department_service.dart';
import '../../services/local_auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen>
    with SingleTickerProviderStateMixin {
  final _memberService = MemberService();
  final _authService = AuthService();
  final _departmentService = DepartmentService();
  final _localAuth = LocalAuthService();

  late TabController _tabController;

  List<Member> _members = [];
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final members = await _memberService.getAllMembers();
    final userRole = await _authService.getUserRole();
    final isAdmin = userRole == 'admin' || userRole == 'pastor';

    List<Map<String, dynamic>> pending = [];
    if (isAdmin) {
      // Try Supabase first, fallback to local
      try {
        pending = await SupabaseService()
            .query('users', column: 'status', value: 'pending');
      } catch (_) {}
      if (pending.isEmpty) {
        final localUsers = await _localAuth.getAllUsers();
        pending = localUsers
            .where((u) => u.status == 'pending')
            .map((u) => {
                  'id': u.id,
                  'name': u.name,
                  'email': u.email,
                  'role': u.role,
                  'department': u.department,
                  'status': u.status,
                  '_source': 'local',
                })
            .toList();
      }
    }

    setState(() {
      _members = members;
      _isAdmin = isAdmin;
      _pendingUsers = pending;
      _isLoading = false;
    });
  }

  Future<void> _approveUser(Map<String, dynamic> user) async {
    try {
      if (user['_source'] == 'local') {
        final localUser = await _localAuth.getUserById(user['id'] as String);
        if (localUser != null) {
          await _localAuth.updateUser(LocalUser(
            id: localUser.id,
            email: localUser.email,
            password: localUser.password,
            name: localUser.name,
            role: localUser.role,
            department: localUser.department,
            status: 'active',
          ));
        }
      } else {
        await SupabaseService()
            .update('users', user['id'] as String, {'status': 'active'});
      }
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name']} approved!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  Future<void> _rejectUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Account'),
        content: Text(
            'Reject and delete the account for ${user['name']}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      if (user['_source'] == 'local') {
        final localUsers = await _localAuth.getAllUsers();
        localUsers.removeWhere((u) => u.id == user['id']);
        // Save updated list via updateUser workaround — we don't have a delete,
        // so set status to 'rejected'
        final localUser = await _localAuth.getUserById(user['id'] as String);
        if (localUser != null) {
          await _localAuth.updateUser(LocalUser(
            id: localUser.id,
            email: localUser.email,
            password: localUser.password,
            name: localUser.name,
            role: localUser.role,
            department: localUser.department,
            status: 'rejected',
          ));
        }
      } else {
        await SupabaseService()
            .update('users', user['id'] as String, {'status': 'rejected'});
      }
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        bottom: _isAdmin
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  const Tab(text: 'Active Members'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Pending'),
                        if (_pendingUsers.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_pendingUsers.length}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAdmin
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMembersList(),
                    _buildPendingList(),
                  ],
                )
              : _buildMembersList(),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddMemberDialog,
              backgroundColor: AppColors.accentPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMembersList() {
    if (_members.isEmpty) {
      return const Center(child: Text('No members yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.brown,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(member.name),
              subtitle: Text('${member.role} • ${member.department}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    member.status,
                    style: TextStyle(
                      color: member.status.toLowerCase() == 'active'
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (_isAdmin)
                    const Icon(Icons.chevron_right,
                        size: 16, color: Colors.grey),
                ],
              ),
              onTap: _isAdmin ? () => _showEditMemberDialog(member) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No pending approvals',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingUsers.length,
        itemBuilder: (context, index) {
          final user = _pendingUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: AppColors.warning.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] as String? ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user['email'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _roleBadge(user['role'] as String? ?? 'member'),
                            if ((user['department'] as String? ?? '')
                                .isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                user['department'] as String,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _approveUser(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () => _rejectUser(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'pastor':
        color = AppColors.purple;
        break;
      case 'admin':
        color = AppColors.blue;
        break;
      case 'department_head':
      case 'departmenthead':
        color = AppColors.brown;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddMemberDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'Member';

    final departments = await _departmentService.getAllDepartments();
    String selectedDepartment =
        departments.isNotEmpty ? departments.first.name : '';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Member', 'Elder', 'Deacon', 'Minister', 'Leader']
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'Member');
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue:
                      departments.isNotEmpty ? selectedDepartment : null,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: departments
                      .map((dept) => DropdownMenuItem(
                            value: dept.name,
                            child: Text(dept.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedDepartment = value ?? '');
                  },
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                  return;
                }

                final newMember = Member(
                  id: '',
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  role: selectedRole,
                  department: selectedDepartment,
                  joinDate: DateTime.now(),
                  status: 'Active',
                );

                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _memberService.addMember(newMember);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Member added successfully')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to add member: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(Member member) {
    final nameController = TextEditingController(text: member.name);
    final emailController = TextEditingController(text: member.email);
    final phoneController = TextEditingController(text: member.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _showDeleteMemberDialog(member),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedMember = member.copyWith(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );

              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _memberService.updateMember(updatedMember);
                navigator.pop();
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Member updated successfully')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to update member: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMemberDialog(Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
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
                await _memberService.deleteMember(member.id);
                navigator.pop();
                if (mounted) Navigator.pop(context);
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Member deleted successfully')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete member: $e')),
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
