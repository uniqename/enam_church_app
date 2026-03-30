import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prayer_request.dart';
import '../../services/prayer_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen>
    with SingleTickerProviderStateMixin {
  final _prayerService = PrayerService();
  final _authService = AuthService();

  late TabController _tabController;

  List<PrayerRequest> _myPrayers = [];
  List<PrayerRequest> _allPrayers = [];
  List<PrayerRequest> _testimonies = [];

  bool _isLoading = true;
  bool _isPrayerWarrior = false;
  bool _isAdmin = false;
  String? _currentUserId;
  String? _currentUserName;

  static const List<String> _categories = [
    'Health',
    'Family',
    'Career',
    'Financial',
    'General',
    'Other',
  ];

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
    try {
      final userId = await _authService.getCurrentUserId();
      final userName = await _authService.getCurrentUserName();
      final department = await _authService.getUserDepartment();
      final userRole = await _authService.getUserRole();

      final isPrayerWarrior = department != null &&
          (department.toLowerCase().contains('prayer warrior') ||
              department.toLowerCase().contains('prayer ministry'));
      final isAdmin = userRole == 'admin' || userRole == 'pastor';

      List<PrayerRequest> myPrayers = [];
      List<PrayerRequest> allPrayers = [];

      if (userId != null) {
        myPrayers = await _prayerService.getMyPrayers(userId);
      }

      if (isPrayerWarrior) {
        allPrayers = await _prayerService.getAllPrayersForPrayerWarriors();
      }

      final testimonies = await _prayerService.getTestimonies();

      final tabCount = isPrayerWarrior ? 3 : 2;
      if (_tabController.length != tabCount) {
        _tabController.dispose();
        _tabController = TabController(length: tabCount, vsync: this);
      }

      setState(() {
        _currentUserId = userId;
        _currentUserName = userName ?? 'Member';
        _isPrayerWarrior = isPrayerWarrior;
        _isAdmin = isAdmin;
        _myPrayers = myPrayers;
        _allPrayers = allPrayers;
        _testimonies = testimonies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load prayers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Prayers'),
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = [
      const Tab(text: 'My Prayers'),
      if (_isPrayerWarrior) const Tab(text: 'All Prayers'),
      const Tab(text: 'Testimonies'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayers'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPrayersTab(),
          if (_isPrayerWarrior) _buildAllPrayersTab(),
          _buildTestimoniesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPrayerDialog,
        backgroundColor: AppColors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyPrayersTab() {
    if (_myPrayers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        message: 'No prayer requests yet.\nTap + to add your first prayer.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myPrayers.length,
        itemBuilder: (context, index) =>
            _buildPrayerCard(_myPrayers[index], isOwn: true),
      ),
    );
  }

  Widget _buildAllPrayersTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.purple.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.shield, color: AppColors.purple, size: 18),
              const SizedBox(width: 8),
              Text(
                'Prayer Warriors View — Interceding for all members',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _allPrayers.isEmpty
              ? _buildEmptyState(
                  icon: Icons.people,
                  message: 'No prayer requests at this time.',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allPrayers.length,
                    itemBuilder: (context, index) => _buildPrayerCard(
                      _allPrayers[index],
                      isOwn: _allPrayers[index].userId == _currentUserId,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTestimoniesTab() {
    if (_testimonies.isEmpty) {
      return _buildEmptyState(
        icon: Icons.celebration,
        message: 'No testimonies yet.\nAnswered prayers will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testimonies.length,
        itemBuilder: (context, index) =>
            _buildTestimonyCard(_testimonies[index]),
      ),
    );
  }

  Widget _buildPrayerCard(PrayerRequest prayer, {required bool isOwn}) {
    final isAnswered = prayer.status == 'Answered';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAnswered
            ? const BorderSide(color: AppColors.success, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(prayer.status),
                const SizedBox(width: 8),
                _buildCategoryBadge(prayer.category),
                if (prayer.isPrivate) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock, size: 14, color: Colors.grey),
                ],
                const Spacer(),
                Text(
                  DateFormat('MMM d, y').format(prayer.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              prayer.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              prayer.request,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By ${prayer.memberName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${prayer.responses}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (isOwn && !isAnswered) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmMarkAnswered(prayer),
                  icon: const Text('🙏', style: TextStyle(fontSize: 14)),
                  label: const Text('Mark as Answered'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            if (_isAdmin && !isOwn) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmDeletePrayer(prayer),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
            ],
            if (isAnswered) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Answered',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    if (prayer.answeredDate != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${DateFormat('MMM d').format(prayer.answeredDate!)}',
                        style: const TextStyle(
                            color: AppColors.success, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonyCard(PrayerRequest prayer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.success, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.celebration, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Testimony',
                          style:
                              TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
                const Spacer(),
                _buildCategoryBadge(prayer.category),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              prayer.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              prayer.request,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By ${prayer.memberName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (prayer.answeredDate != null)
                  Text(
                    'Answered ${DateFormat('MMM d, y').format(prayer.answeredDate!)}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Answered' ? AppColors.success : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        category,
        style: const TextStyle(
            color: AppColors.purple,
            fontSize: 10,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmMarkAnswered(PrayerRequest prayer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Answered?'),
        content: Text(
            'Mark "${prayer.title}" as answered? It will move to the Testimonies board.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Answered'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _prayerService.markAsAnswered(prayer.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Praise God! Prayer marked as answered.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update prayer: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeletePrayer(PrayerRequest prayer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Prayer?'),
        content: Text('Remove "${prayer.title}" from the board?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _prayerService.deletePrayer(prayer.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }

  void _showAddPrayerDialog() {
    final titleController = TextEditingController();
    final requestController = TextEditingController();
    String selectedCategory = 'General';
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Prayer Request'),
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
                  controller: requestController,
                  decoration: const InputDecoration(
                    labelText: 'Prayer Request',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedCategory = v ?? 'General'),
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  title: const Text('Private (only visible to you)'),
                  value: isPrivate,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) =>
                      setDialogState(() => isPrivate = v ?? false),
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
                if (titleController.text.trim().isEmpty ||
                    requestController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final newPrayer = PrayerRequest(
                  id: '',
                  title: titleController.text.trim(),
                  memberName: _currentUserName ?? 'Member',
                  request: requestController.text.trim(),
                  category: selectedCategory,
                  status: 'Open',
                  date: DateTime.now(),
                  isPrivate: isPrivate,
                  responses: 0,
                  userId: _currentUserId,
                );

                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _prayerService.addPrayer(newPrayer);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('Prayer request added successfully')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to add prayer: $e')),
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
}
