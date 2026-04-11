import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/child_account_service.dart';
import '../../services/member_service.dart';
import '../../services/event_service.dart';
import '../../services/finance_service.dart';
import '../../services/sermon_service.dart';
import '../../services/announcement_service.dart';
import '../../services/banner_service.dart';
import '../../services/supabase_service.dart';
import '../../models/announcement.dart';
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
  final _announcementService = AnnouncementService();
  final _bannerService = BannerService();

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

  // Sliding banner (adult)
  List<Announcement> _bannerAnnouncements = [];
  List<_BannerSlide> _dedicatedBannerSlides = [];
  final _bannerController = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;

  // Sliding banner (children)
  List<_BannerSlide> _childBannerSlides = [];
  final _childBannerController = PageController();
  int _childBannerPage = 0;
  Timer? _childBannerTimer;

  // Campaign / year theme section
  List<_BannerSlide> _campaignSlides = [];
  final _campaignController = PageController();
  int _campaignPage = 0;
  Timer? _campaignTimer;

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
        try {
          final childBanners = await _bannerService.getActiveChildBanners();
          final slides = childBanners.map((b) => _BannerSlide(
            type: _BannerType.announcement,
            title: b.title,
            subtitle: b.subtitle,
            color1: AppColors.childOrange,
            color2: AppColors.childYellow,
            imageUrl: b.mediaType == 'image' ? b.mediaUrl : '',
            linkRoute: b.linkRoute,
          )).toList();
          setState(() => _childBannerSlides = slides);
          _startChildBannerTimer();
        } catch (_) {}
      }

      if (role != 'child') {
        final members = await _memberService.getAllMembers();
        final events = await _eventService.getAllEvents();
        final sermons = await _sermonService.getAllSermons();
        final financeTotal = await _financeService.getTotal();
        // Load hero banners (adult) + campaign banners in parallel
        try {
          final dedicated = await _bannerService.getActiveBanners();
          if (dedicated.isNotEmpty) {
            final slides = dedicated.map((b) => _BannerSlide(
              type: _BannerType.announcement,
              title: b.title,
              subtitle: b.subtitle,
              color1: AppColors.purple,
              color2: AppColors.blue,
              imageUrl: b.mediaType == 'image' ? b.mediaUrl : '',
              linkRoute: b.linkRoute,
            )).toList();
            setState(() => _dedicatedBannerSlides = slides);
          } else {
            // Fallback: use active announcements
            final all = await _announcementService.getAllAnnouncements();
            final active = all.where((a) => a.status == 'Active' || a.status == 'active').toList();
            setState(() => _bannerAnnouncements = active.take(5).toList());
          }
          _startBannerTimer();
        } catch (_) {}
        // Load campaign/year-theme banners
        try {
          final campaigns = await _bannerService.getActiveCampaignBanners();
          final cSlides = campaigns.map((b) => _BannerSlide(
            type: _BannerType.yearTheme,
            title: b.title,
            subtitle: b.subtitle,
            color1: const Color(0xFF4A0080),
            color2: const Color(0xFF7B1FA2),
            imageUrl: b.mediaType == 'image' ? b.mediaUrl : '',
            linkRoute: b.linkRoute,
          )).toList();
          setState(() => _campaignSlides = cSlides);
          _startCampaignTimer();
        } catch (_) {}
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

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    final totalSlides = _dedicatedBannerSlides.isNotEmpty
        ? _dedicatedBannerSlides.length
        : _bannerAnnouncements.length;
    if (totalSlides < 2) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final count = _dedicatedBannerSlides.isNotEmpty
          ? _dedicatedBannerSlides.length
          : _bannerAnnouncements.length;
      if (count < 2) return;
      final next = (_bannerPage + 1) % count;
      _bannerController.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _startCampaignTimer() {
    _campaignTimer?.cancel();
    if (_campaignSlides.length < 2) return;
    _campaignTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_campaignController.hasClients) return;
      if (_campaignSlides.length < 2) return;
      final next = (_campaignPage + 1) % _campaignSlides.length;
      _campaignController.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _startChildBannerTimer() {
    _childBannerTimer?.cancel();
    if (_childBannerSlides.length < 2) return;
    _childBannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_childBannerController.hasClients) return;
      if (_childBannerSlides.length < 2) return;
      final next = (_childBannerPage + 1) % _childBannerSlides.length;
      _childBannerController.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _childBannerTimer?.cancel();
    _campaignTimer?.cancel();
    _bannerController.dispose();
    _childBannerController.dispose();
    _campaignController.dispose();
    super.dispose();
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
            : [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv),
                  label: 'Live',
                ),
                if (_userRole == 'admin' || _userRole == 'pastor' || _userRole == 'treasurer')
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.monetization_on),
                    label: 'Finance',
                  )
                else
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.mic),
                    label: 'Sermons',
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
          _buildChildSlidingBanner(),
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
              _buildChildCard(
                'My Notes',
                Icons.note_alt,
                AppColors.childPurple,
                () => Navigator.pushNamed(context, '/child_notes'),
              ),
              if (_childAge >= 12)
                _buildChildCard(
                  'Give',
                  Icons.volunteer_activism,
                  AppColors.childGreen,
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

  Widget _buildChildSlidingBanner() {
    final canEdit = _userRole == 'admin' || _userRole == 'pastor' ||
        _userRole == 'dept_head' || _userRole == 'media_team';

    Widget bannerContent;
    if (_childBannerSlides.isEmpty) {
      // Default hardcoded welcome banner
      bannerContent = Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: AppColors.childGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 56, color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Welcome to Children\'s Church!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Learn, Play, and Grow in Faith!',
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (_childBannerSlides.length == 1) {
      bannerContent = SizedBox(height: 160, child: _buildBannerCard(_childBannerSlides[0]));
    } else {
      bannerContent = Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _childBannerController,
              itemCount: _childBannerSlides.length,
              onPageChanged: (i) => setState(() => _childBannerPage = i),
              itemBuilder: (_, i) {
                final slide = _childBannerSlides[i];
                return GestureDetector(
                  onTap: slide.linkRoute.isNotEmpty
                      ? () => Navigator.pushNamed(context, slide.linkRoute)
                      : null,
                  child: _buildBannerCard(slide),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_childBannerSlides.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _childBannerPage == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _childBannerPage == i
                    ? AppColors.childOrange
                    : AppColors.childOrange.withValues(alpha: 0.3),
              ),
            )),
          ),
        ],
      );
    }

    return Stack(
      children: [
        bannerContent,
        if (canEdit)
          Positioned(
            top: 8,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin/banners').then((_) => _loadUserData()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Edit Banners',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdultDashboard() {
    if (_selectedIndex == 1) {
      Navigator.pushNamed(context, '/events').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 2) {
      Navigator.pushNamed(context, '/streaming').then((_) {
        setState(() => _selectedIndex = 0);
      });
      return const Center(child: CircularProgressIndicator());
    } else if (_selectedIndex == 3) {
      final isFinanceRole = _userRole == 'admin' || _userRole == 'pastor' || _userRole == 'treasurer';
      Navigator.pushNamed(context, isFinanceRole ? '/finances' : '/sermons').then((_) {
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
            _buildHeroBanner(isAdmin: isAdmin, isDeptHead: isDeptHead, isMediaTeam: isMediaTeam, isTreasurer: isTreasurer),
            const SizedBox(height: 20),
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
            _buildCampaignSection(),
            const SizedBox(height: 20),
            if (isAdmin && _pendingApprovals > 0) ...[
              _buildPendingApprovalsBanner(),
              const SizedBox(height: 16),
            ],
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // ── Core actions grid (6 primary) ────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildQuickActionCard('Streaming', Icons.live_tv, AppColors.error,
                    () => Navigator.pushNamed(context, '/streaming'),
                    editRoute: '/streaming'),
                _buildQuickActionCard('Sermons', Icons.mic, AppColors.purple,
                    () => Navigator.pushNamed(context, '/sermons'),
                    editRoute: '/sermons'),
                _buildQuickActionCard('Devotionals', Icons.auto_stories, AppColors.accentBlue,
                    () => Navigator.pushNamed(context, '/devotionals'),
                    editRoute: '/devotionals'),
                _buildQuickActionCard('Prayers', Icons.favorite, AppColors.brown,
                    () => Navigator.pushNamed(context, '/prayers'),
                    editRoute: '/prayers'),
                _buildQuickActionCard('Giving', Icons.card_giftcard, AppColors.success,
                    () => Navigator.pushNamed(context, '/giving')),
                _buildQuickActionCard('Events', Icons.event, AppColors.accentTeal,
                    () => Navigator.pushNamed(context, '/events'),
                    editRoute: '/events'),
              ],
            ),
            const SizedBox(height: 20),
            // ── Community widget ─────────────────────────────────────────────
            _buildCommunityWidget(),
            const SizedBox(height: 12),
            // ── Finance widget (admin / pastor / treasurer only) ─────────────
            if (isAdmin || isTreasurer) ...[
              _buildFinanceWidget(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  // ── Hero banner (top of adult dashboard — replaces old welcome card) ─────────
  Widget _buildHeroBanner({required bool isAdmin, required bool isDeptHead, required bool isMediaTeam, required bool isTreasurer}) {
    final canEdit = isAdmin || isDeptHead || isMediaTeam;
    final roleLabel = isAdmin
        ? (_userRole == 'pastor' ? 'Pastor Dashboard' : 'Admin Dashboard')
        : isDeptHead ? 'Department Head Dashboard'
        : isMediaTeam ? 'Media Team Dashboard'
        : isTreasurer ? 'Treasurer Dashboard'
        : 'Member Dashboard';

    final slides = <_BannerSlide>[
      if (_dedicatedBannerSlides.isNotEmpty)
        ..._dedicatedBannerSlides
      else
        ..._bannerAnnouncements.map((a) => _BannerSlide(
              type: _BannerType.announcement,
              title: a.title,
              subtitle: a.content.isNotEmpty ? a.content : a.department,
              color1: a.priority == 'High' ? const Color(0xFFB71C1C) : AppColors.purple,
              color2: a.priority == 'High' ? const Color(0xFFD32F2F) : AppColors.blue,
              imageUrl: RegExp(r'\.(jpg|jpeg|png|gif|webp)(\?|$)', caseSensitive: false)
                      .hasMatch(a.mediaUrl)
                  ? a.mediaUrl : '',
            )),
    ];

    // Default: welcome slide matching the old card style
    if (slides.isEmpty) {
      slides.add(_BannerSlide(
        type: _BannerType.announcement,
        title: 'Welcome to Faith Klinik',
        subtitle: roleLabel,
        color1: const Color(0xFF4A0080),
        color2: const Color(0xFF7B1FA2),
      ));
    }

    Widget heroContent;
    if (slides.length == 1) {
      heroContent = SizedBox(height: 200, child: _buildHeroCard(slides[0]));
    } else {
      heroContent = Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _bannerPage = i),
              itemBuilder: (_, i) => GestureDetector(
                onTap: slides[i].linkRoute.isNotEmpty
                    ? () => Navigator.pushNamed(context, slides[i].linkRoute)
                    : null,
                child: _buildHeroCard(slides[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _bannerPage == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _bannerPage == i
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.35),
              ),
            )),
          ),
        ],
      );
    }

    return Stack(
      children: [
        heroContent,
        if (canEdit)
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin/banners').then((_) => _loadUserData()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Edit Banners', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroCard(_BannerSlide slide) {
    final hasImage = slide.imageUrl.isNotEmpty;
    if (hasImage) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(slide.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildHeroGradientCard(slide)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slide.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (slide.subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(slide.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildHeroGradientCard(slide);
  }

  Widget _buildHeroGradientCard(_BannerSlide slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [slide.color1, slide.color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.church, size: 52, color: Colors.white),
          const SizedBox(height: 14),
          Text(slide.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          if (slide.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 24, right: 24),
              child: Text(slide.subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  // ── Campaign / Year Theme section (compact, below stats) ──────────────────
  Widget _buildCampaignSection() {
    final canEdit = _userRole == 'admin' || _userRole == 'pastor' ||
        _userRole == 'media_team' || _userRole == 'dept_head';

    final slides = _campaignSlides.isNotEmpty
        ? _campaignSlides
        : const [_BannerSlide(
            type: _BannerType.yearTheme,
            title: 'Year Theme 2026',
            subtitle: '"Possessing Our Possessions" — Obadiah 1:17',
            color1: Color(0xFF4A0080),
            color2: Color(0xFF7B1FA2),
          )];

    Widget content;
    if (slides.length == 1) {
      content = SizedBox(height: 90, child: _buildBannerCard(slides[0]));
    } else {
      content = Column(
        children: [
          SizedBox(
            height: 90,
            child: PageView.builder(
              controller: _campaignController,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _campaignPage = i),
              itemBuilder: (_, i) => _buildBannerCard(slides[i]),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _campaignPage == i ? 16 : 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _campaignPage == i ? AppColors.purple : AppColors.purple.withValues(alpha: 0.3),
              ),
            )),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 15, color: AppColors.purple),
            const SizedBox(width: 6),
            const Text('Year Theme & Campaigns',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.purple)),
            const Spacer(),
            if (canEdit)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/admin/banners').then((_) => _loadUserData()),
                child: const Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.purple)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildBannerCard(_BannerSlide slide) {
    final icon = slide.type == _BannerType.yearTheme ? Icons.star : Icons.campaign;
    final hasImage = slide.imageUrl.isNotEmpty;

    if (hasImage) {
      // Image banner — photo background with text overlay
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(slide.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [slide.color1, slide.color2])))),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slide.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (slide.subtitle.isNotEmpty)
                      Text(slide.subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Gradient banner (year theme + text-only announcements)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [slide.color1, slide.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(slide.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(slide.subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Community widget ────────────────────────────────────────────────────────
  Widget _buildCommunityWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canManage = _userRole == 'admin' || _userRole == 'pastor' ||
        _userRole == 'dept_head' || _userRole == 'media_team';
    final items = [
      _CommunityItem('Groups', Icons.groups, AppColors.blue, '/groups'),
      _CommunityItem('Members', Icons.people, AppColors.purple, '/members',
          editRoute: canManage ? '/members' : null),
      _CommunityItem('Messages', Icons.message, AppColors.darkNavy, '/messages'),
      _CommunityItem('Quiz', Icons.quiz, AppColors.warning, '/quiz'),
      _CommunityItem('Bulletin', Icons.receipt_long, AppColors.blue, '/bulletin',
          editRoute: canManage ? '/bulletin' : null),
      _CommunityItem('Notes', Icons.note_alt, const Color(0xFF5D4037), '/notes'),
      _CommunityItem('AI Tools', Icons.rocket_launch, const Color(0xFFFF6B6B), '/ai_tools'),
      _CommunityItem('Volunteer', Icons.volunteer_activism, AppColors.info, '/volunteer',
          editRoute: canManage ? '/volunteer' : null),
    ];
    return Card(
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined, size: 18, color: AppColors.purple),
                const SizedBox(width: 6),
                const Text('Community',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 0.9,
              children: items.map((item) => Stack(
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, item.route),
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 22),
                        ),
                        const SizedBox(height: 5),
                        Text(item.label,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (item.editRoute != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, item.editRoute!),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(Icons.edit, size: 10, color: item.color),
                        ),
                      ),
                    ),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Finance widget (role-gated) ──────────────────────────────────────────────
  Widget _buildFinanceWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTreasurer = _userRole == 'treasurer';
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/finances'),
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [AppColors.success.withValues(alpha: 0.15), AppColors.success.withValues(alpha: 0.05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: AppColors.success, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTreasurer ? 'Finance Overview' : 'Church Finances',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GH₵ ${_financeTotal.toStringAsFixed(2)}  · Total recorded',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.success),
            ],
          ),
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

  Widget _buildQuickActionCard(String title, IconData icon, Color color,
      VoidCallback onTap, {String? editRoute}) {
    final canEdit = editRoute != null &&
        (_userRole == 'admin' || _userRole == 'pastor' ||
            _userRole == 'dept_head' || _userRole == 'media_team');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          InkWell(
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (canEdit)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, editRoute),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.edit, size: 12, color: color),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                      'Bible Apps & Library',
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
                    // ── Content management (elevated roles) ─────────────
                    if (_userRole == 'admin' || _userRole == 'pastor' ||
                        _userRole == 'dept_head' || _userRole == 'media_team') ...[
                      const Divider(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text('Manage Content',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                                letterSpacing: 0.8)),
                      ),
                      _buildMenuItem('Manage Banners', Icons.view_carousel, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin/banners');
                      }),
                      _buildMenuItem('Announcements', Icons.campaign, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/announcements');
                      }),
                      _buildMenuItem('Weekly Bulletin', Icons.receipt_long, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/bulletin');
                      }),
                      _buildMenuItem('Church Library', Icons.local_library, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/church_library');
                      }),
                      _buildMenuItem('Upload Video', Icons.video_call, () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const AdminVideoUploadScreen()));
                      }),
                    ],
                    if (_userRole == 'admin' || _userRole == 'pastor') ...[
                      _buildMenuItem('Manage Bible Stories', Icons.auto_stories, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin/bible_stories');
                      }),
                      _buildMenuItem('Members', Icons.people, () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/members');
                      }),
                    ],
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

class _CommunityItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final String? editRoute;
  const _CommunityItem(this.label, this.icon, this.color, this.route, {this.editRoute});
}

enum _BannerType { yearTheme, announcement }

class _BannerSlide {
  final _BannerType type;
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final String imageUrl;
  final String linkRoute;
  const _BannerSlide({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    this.imageUrl = '',
    this.linkRoute = '',
  });
}
