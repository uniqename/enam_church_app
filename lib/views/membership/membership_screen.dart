import 'package:flutter/material.dart';
import '../../models/membership.dart';
import '../../models/user.dart';
import '../../services/membership_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  final _membershipService = MembershipService();
  final _authService = AuthService();

  late TabController _tabController;

  List<Membership> _memberships = [];
  Membership? _myMembership;
  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isAdmin = false;

  final _typeController = TextEditingController();
  final _benefitsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _typeController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userRole = await _authService.getUserRole();
      final user = await _authService.getCurrentUserProfile();
      final isAdmin = userRole == 'admin' || userRole == 'pastor';

      List<Membership> all = [];
      Membership? mine;

      if (isAdmin) {
        all = await _membershipService.getAllMemberships();
      }
      if (user != null) {
        mine = await _membershipService.getMembershipByUserId(user.id);
      }

      setState(() {
        _isAdmin = isAdmin;
        _currentUser = user;
        _memberships = all;
        _myMembership = mine;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load membership data: $e')),
        );
      }
    }
  }

  void _showAddMembershipDialog() {
    _typeController.clear();
    _benefitsController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Membership'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type (Regular/Premium/Youth)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _benefitsController,
                decoration: const InputDecoration(labelText: 'Benefits'),
                maxLines: 3,
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
              if (_currentUser == null) return;
              Navigator.pop(ctx);
              try {
                final newMembership = Membership(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: _currentUser!.id,
                  type: _typeController.text.trim().isEmpty
                      ? 'Regular'
                      : _typeController.text.trim(),
                  status: 'Active',
                  startDate: DateTime.now(),
                  benefits: _benefitsController.text.trim(),
                );
                await _membershipService.createMembership(newMembership);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membership added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Membership membership) {
    _typeController.text = membership.type;
    _benefitsController.text = membership.benefits;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Membership'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _benefitsController,
                decoration: const InputDecoration(labelText: 'Benefits'),
                maxLines: 3,
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
              Navigator.pop(ctx);
              try {
                final updated = Membership(
                  id: membership.id,
                  userId: membership.userId,
                  type: _typeController.text.trim(),
                  status: membership.status,
                  startDate: membership.startDate,
                  expiryDate: membership.expiryDate,
                  benefits: _benefitsController.text.trim(),
                );
                await _membershipService.updateMembership(updated);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membership updated')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMembership(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Membership'),
        content: const Text('Are you sure you want to delete this membership?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _membershipService.deleteMembership(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membership deleted')),
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

  Widget _buildMyMembershipTab() {
    if (_myMembership == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_membership, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No membership found', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'Contact the church office to get your membership set up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddMembershipDialog,
              icon: const Icon(Icons.add),
              label: const Text('Request Membership'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    final m = _myMembership!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.card_membership, size: 40, color: Colors.white),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: m.status == 'Active' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          m.status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Faith Klinik Ministries',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _currentUser?.name ?? 'Member',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${m.type} Member',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MEMBER SINCE',
                              style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(
                            '${m.startDate.day}/${m.startDate.month}/${m.startDate.year}',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (m.expiryDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('VALID UNTIL',
                                style: TextStyle(color: Colors.white54, fontSize: 10)),
                            Text(
                              '${m.expiryDate!.day}/${m.expiryDate!.month}/${m.expiryDate!.year}',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (m.benefits.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Benefits',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(m.benefits),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_isAdmin)
            ElevatedButton.icon(
              onPressed: () => _showEditDialog(m),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Membership'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildAllMembershipsTab() {
    if (_memberships.isEmpty) {
      return const Center(child: Text('No memberships found'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _memberships.length,
        itemBuilder: (context, index) {
          final m = _memberships[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    m.status == 'Active' ? AppColors.primary : Colors.grey,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text('${m.type} Member'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Since: ${m.startDate.day}/${m.startDate.month}/${m.startDate.year}'),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: m.status == 'Active'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: m.status == 'Active' ? Colors.green[700] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: _isAdmin
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _showEditDialog(m);
                        if (value == 'delete') _deleteMembership(m.id);
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    )
                  : null,
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: _isAdmin
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'My Membership'),
                  Tab(text: 'All Members'),
                ],
              )
            : null,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddMembershipDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAdmin
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyMembershipTab(),
                    _buildAllMembershipsTab(),
                  ],
                )
              : _buildMyMembershipTab(),
    );
  }
}
