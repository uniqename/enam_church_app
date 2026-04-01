import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/child_account_service.dart';
import '../../services/member_service.dart';
import '../../services/event_service.dart';
import '../../services/finance_service.dart';
import '../../services/sermon_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';
import '../admin/admin_video_upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _memberService = MemberService();
  final _eventService = EventService();
  final _financeService = FinanceService();
  final _sermonService = SermonService();

  int _selectedIndex = 0;
  String? _userRole;
  int _childAge = 0;
  bool _isLoading = true;

  // Stats for adult dashboard
  int _memberCount = 0;
  int _eventCount = 0;
  int _sermonCount = 0;
  double _financeTotal = 0.0;
  int _pendingApprovals = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final role = await _authService.getUserRole();

      // Load stats for adult dashboard
      if (role == 'child') {
        final age = await ChildAccountService().getActiveChildAge();
        setState(() => _childAge = age);
      }

      if (role != 'child') {
        final members = await _memberService.getAllMembers();
        final events = await _eventService.getAllEvents();
        final sermons = await _sermonService.getAllSermons();
        final financeTotal = await _financeService.getTotal();
        int pendingCount = 0;
        if (role == 'admin' || role == 'pastor') {
          try {
            final pending = await SupabaseService().query(
              'users',
              column: 'status',
              value: 'pending',
            );
            pendingCount = pending.length;
          } catch (_) {}
        }

        setState(() {
          _memberCount = members.length;
          _eventCount = events.length;
          _sermonCount = sermons.length;
          _financeTotal = financeTotal;
          _pendingApprovals = pendingCount;
        });
      }

      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userRole = 'member';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isChild = _userRole == 'child';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faith Klinik Ministries'),
        backgroundColor: isChild ? AppColors.childGreen : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      body: _buildBody(isChild),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isChild ? AppColors.childGreen : AppColors.accentPurple,
        unselectedItemColor: Colors.grey,
        items: isChild
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.games),
                  label: 'Games',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Stories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'Videos',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Members',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on),
                  label: 'Finance',
                ),
              ],
      ),
    );
  }

  Widget _buildBody(bool isChild) {
    if (isChild) {
      return _buildChildDashboard();
    } else {
      return _buildAdultDashboard();
    }
  }

  Widget _buildChildDashboard() {
    if (_selectedIndex == 1) {
      Navigator.pushNamed(context, '/child_games').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 2) {
      Navigator.pushNamed(context, '/child_lessons').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 3) {
      Navigator.pushNamed(context, '/child_sermons').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.childGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.child_care,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome to Children\'s Church!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Learn, Play, and Grow in Faith!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What would you like to do today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildChildCard(
                'Bible Games',
                Icons.games,
                AppColors.childGreen,
                () => Navigator.pushNamed(context, '/child_games'),
              ),
              _buildChildCard(
                'Bible Stories',
                Icons.book,
                AppColors.childBlue,
                () => Navigator.pushNamed(context, '/child_lessons'),
              ),
              _buildChildCard(
                'Watch Videos',
                Icons.video_library,
                AppColors.childOrange,
                () => Navigator.pushNamed(context, '/child_sermons'),
              ),
              _buildChildCard(
                'Prayers',
                Icons.favorite,
                AppColors.childPink,
                () => Navigator.pushNamed(context, '/prayers'),
              ),
              if (_childAge >= 12)
                _buildChildCard(
                  'Give',
                  Icons.volunteer_activism,
                  AppColors.childPurple,
                  () => Navigator.pushNamed(context, '/giving'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 56,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdultDashboard() {
    if (_selectedIndex == 1) {
      Navigator.pushNamed(context, '/members').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 2) {
      Navigator.pushNamed(context, '/events').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 3) {
      Navigator.pushNamed(context, '/finances').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    }

    final isAdmin = _userRole == 'admin' || _userRole == 'pastor';
    final isDeptHead = _userRole == 'department_head';
    final isMediaTeam = _userRole == 'media_team';
    final isTreasurer = _userRole == 'treasurer';

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkGradient
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? Border.all(color: AppColors.darkBorder, width: 1)
                    : null,
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.glowPurple(radius: 24, opacity: 0.18)
                    : null,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.church,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to Faith Klinik',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAdmin
                        ? (_userRole == 'pastor' ? 'Pastor Dashboard' : 'Admin Dashboard')
                        : isDeptHead
                            ? 'Department Head Dashboard'
                            : isMediaTeam
                                ? 'Media Team Dashboard'
                                : isTreasurer
                                    ? 'Treasurer Dashboard'
                                    : 'Member Dashboard',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isAdmin) ...[
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Members',
                      _memberCount.toString(),
                      Icons.people,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Events',
                      _eventCount.toString(),
                      Icons.event,
                      AppColors.accentTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Finances',
                      '\$${_financeTotal.toStringAsFixed(0)}',
                      Icons.monetization_on,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Sermons',
                      _sermonCount.toString(),
                      Icons.play_circle,
                      AppColors.accentRose,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else if (isDeptHead) ...[
              const Text(
                'Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Members', _memberCount.toString(), Icons.people, Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Events', _eventCount.toString(), Icons.event, AppColors.accentTeal),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else if (isTreasurer) ...[
              const Text(
                'Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Giving', '\$${_financeTotal.toStringAsFixed(0)}', Icons.monetization_on, AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Members', _memberCount.toString(), Icons.people, AppColors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (isAdmin && _pendingApprovals > 0) ...[
              _buildPendingApprovalsBanner(),
              const SizedBox(height: 16),
            ],
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                if (isAdmin || isDeptHead)
                  _buildQuickActionCard(
                    'Admin Panel',
                    Icons.admin_panel_settings,
                    const Color(0xFF1565C0),
                    () => _showAdminPanel(),
                  ),
                _buildQuickActionCard(
                  'Streaming',
                  Icons.live_tv,
                  AppColors.error,
                  () => Navigator.pushNamed(context, '/streaming'),
                ),
                _buildQuickActionCard(
                  'Sermons',
                  Icons.mic,
                  AppColors.purple,
                  () => Navigator.pushNamed(context, '/sermons'),
                ),
                _buildQuickActionCard(
                  'Devotionals',
                  Icons.auto_stories,
                  AppColors.accentBlue,
                  () => Navigator.pushNamed(context, '/devotionals'),
                ),
                _buildQuickActionCard(
                  'Prayers',
                  Icons.favorite,
                  AppColors.brown,
                  () => Navigator.pushNamed(context, '/prayers'),
                ),
                _buildQuickActionCard(
                  'Giving',
                  Icons.card_giftcard,
                  AppColors.success,
                  () => Navigator.pushNamed(context, '/giving'),
                ),
                _buildQuickActionCard(
                  'Groups',
                  Icons.groups,
                  AppColors.blue,
                  () => Navigator.pushNamed(context, '/groups'),
                ),
                _buildQuickActionCard(
                  'Connect',
                  Icons.waving_hand,
                  AppColors.warning,
                  () => Navigator.pushNamed(context, '/connect'),
                ),
                _buildQuickActionCard(
                  'Messages',
                  Icons.message,
                  AppColors.darkNavy,
                  () => Navigator.pushNamed(context, '/messages'),
                ),
                _buildQuickActionCard(
                  'Our Team',
                  Icons.people_alt,
                  const Color(0xFF6A0080),
                  () => Navigator.pushNamed(context, '/staff'),
                ),
                _buildQuickActionCard(
                  'Bulletin',
                  Icons.receipt_long,
                  AppColors.blue,
                  () => Navigator.pushNamed(context, '/bulletin'),
                ),
                _buildQuickActionCard(
                  'Volunteer',
                  Icons.volunteer_activism,
                  AppColors.info,
                  () => Navigator.pushNamed(context, '/volunteer'),
                ),
                _buildQuickActionCard(
                  'AI Tools',
                  Icons.rocket_launch,
                  const Color(0xFFFF6B6B),
                  () => Navigator.pushNamed(context, '/ai_tools'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalsBanner() {
    return InkWell(
      onTap: _showPendingApprovals,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_pendingApprovals account${_pendingApprovals > 1 ? "s" : ""} pending approval',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'Tap to review and approve',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.warning),
          ],
        ),
      ),
    );
  }

  Future<void> _showPendingApprovals() async {
    List<Map<String, dynamic>> pending = [];
    try {
      pending = await SupabaseService().query('users', column: 'status', value: 'pending');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load pending accounts: $e')),
        );
      }
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pending Approvals'),
        content: SizedBox(
          width: double.maxFinite,
          child: pending.isEmpty
              ? const Text('No pending accounts.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder: (_, i) {
                    final user = pending[i];
                    return ListTile(
                      leading: const Icon(Icons.person, color: AppColors.purple),
                      title: Text(user['name'] as String? ?? 'Unknown'),
                      subtitle: Text(
                        '${user['email'] ?? ''} • ${user['role'] ?? 'unknown'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(ctx);
                          try {
                            await SupabaseService().update(
                              'users', user['id'] as String, {'status': 'active'},
                            );
                            navigator.pop();
                            _loadUserData();
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
                        },
                        child: const Text('Approve', style: TextStyle(color: AppColors.success)),
                      ),
                    );
                  },
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? AppColors.glowColor(color, radius: 12, opacity: 0.15) : null,
      ),
      child: Card(
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAdminPanel() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _buildMenuItem('Manage Members', Icons.people, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/members');
            }),
            _buildMenuItem('Manage Videos', Icons.video_library, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/videos');
            }),
            _buildMenuItem('Bible Stories (Kids)', Icons.auto_stories, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/bible_stories');
            }),
            _buildMenuItem('Departments & Groups', Icons.groups, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/departments');
            }),
            _buildMenuItem('Volunteer Roles', Icons.volunteer_activism, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/volunteer');
            }),
            _buildMenuItem('Announcements', Icons.announcement, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/announcements');
            }),
            _buildMenuItem('Weekly Bulletin', Icons.receipt_long, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bulletin');
            }),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'More Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    _buildMenuItem(
                      'My Profile',
                      Icons.account_circle,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _buildDarkModeToggle(),
                    _buildMenuItem(
                      'Daily Devotional',
                      Icons.auto_stories,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/devotionals');
                      },
                    ),
                    _buildMenuItem(
                      'Connect Card',
                      Icons.waving_hand,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/connect');
                      },
                    ),
                    _buildMenuItem(
                      'Our Team',
                      Icons.people_alt,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/staff');
                      },
                    ),
                    _buildMenuItem(
                      'Groups & Ministries',
                      Icons.groups,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/groups');
                      },
                    ),
                    _buildMenuItem(
                      'Streaming',
                      Icons.live_tv,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/streaming');
                      },
                    ),
                    _buildMenuItem(
                      'Sermons',
                      Icons.headphones,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/sermons');
                      },
                    ),
                    _buildMenuItem(
                      'Event Gallery',
                      Icons.photo_library,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/event_gallery');
                      },
                    ),
                    _buildMenuItem(
                      'Prayers',
                      Icons.favorite,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/prayers');
                      },
                    ),
                    _buildMenuItem(
                      'Announcements',
                      Icons.announcement,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/announcements');
                      },
                    ),
                    _buildMenuItem(
                      'Messages',
                      Icons.message,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/messages');
                      },
                    ),
                    _buildMenuItem(
                      'My Membership Journey',
                      Icons.workspace_premium,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/membership');
                      },
                    ),
                    _buildMenuItem(
                      'Bible Apps',
                      Icons.menu_book,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/bible_apps');
                      },
                    ),
                    _buildMenuItem(
                      'Birthday Cards',
                      Icons.cake,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/birthday_card');
                      },
                    ),
                    _buildMenuItem(
                      'Notifications',
                      Icons.notifications,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    _buildMenuItem(
                      'Giving',
                      Icons.card_giftcard,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/giving');
                      },
                    ),
                    _buildMenuItem(
                      'Weekly Bulletin',
                      Icons.receipt_long,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/bulletin');
                      },
                    ),
                    _buildMenuItem(
                      'Volunteer',
                      Icons.volunteer_activism,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/volunteer');
                      },
                    ),
                    _buildMenuItem(
                      'AI Ministry Tools',
                      Icons.rocket_launch,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/ai_tools');
                      },
                    ),
                    // Elevated roles — content management
                    if (_userRole == 'admin' || _userRole == 'pastor' ||
                        _userRole == 'department_head' || _userRole == 'media_team')
                      _buildMenuItem(
                        'Upload Video',
                        Icons.video_call,
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminVideoUploadScreen(),
                            ),
                          );
                        },
                      ),
                    if (_userRole == 'admin' || _userRole == 'pastor')
                      _buildMenuItem(
                        'Manage Bible Stories',
                        Icons.auto_stories,
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/admin/bible_stories');
                        },
                      ),
                    const Divider(height: 32),
                    _buildMenuItem(
                      'Privacy Policy',
                      Icons.privacy_tip,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/privacy_policy');
                      },
                    ),
                    _buildMenuItem(
                      'Data Deletion',
                      Icons.delete_outline,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/data_deletion');
                      },
                    ),
                    _buildMenuItem(
                      'Logout',
                      Icons.logout,
                      () async {
                        Navigator.pop(context);
                        final navigator = Navigator.of(context);
                        await _authService.signOut();
                        if (mounted) {
                          navigator.pushReplacementNamed('/login');
                        }
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) => SwitchListTile(
        secondary: Icon(
          themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.accentPurple,
        ),
        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
        value: themeProvider.isDark,
        activeThumbColor: AppColors.accentPurple,
        onChanged: (_) => themeProvider.toggle(),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.purple,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
