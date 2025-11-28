import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/app_provider.dart';
import 'utils/colors.dart';
import 'models/member.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const FaithKlinikApp(),
    ),
  );
}

class FaithKlinikApp extends StatelessWidget {
  const FaithKlinikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faith Klinik Ministries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brown,
          primary: AppColors.brown,
          secondary: AppColors.gold,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoggedIn) {
          return const LoggedInScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.brown.withOpacity(0.1), AppColors.gold.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/faith_klinik_logo.png',
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.church, size: 50, color: AppColors.brown);
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Faith Klinik',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brown,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showLoginDialog(context),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showKidsLoginDialog(context),
                          icon: const Icon(Icons.child_care, size: 18),
                          label: const Text('Kids Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kidsGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/faith_klinik_logo.png',
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.church, size: 120, color: AppColors.brown);
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome to Faith Klinik Ministries',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brown,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Building faith, healing lives, transforming communities',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Columbus, Ohio',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatCard('150+', 'Members'),
                            const SizedBox(width: 24),
                            _buildStatCard('8', 'Ministries'),
                            const SizedBox(width: 24),
                            _buildStatCard('Active', 'Community'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login to Faith Klinik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Try: pastor/pastor123, admin/admin123, member/member123, child/child123',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              if (provider.login(usernameController.text, passwordController.text)) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid credentials')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brown),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showKidsLoginDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.child_care, color: AppColors.kidsGreen),
            const SizedBox(width: 8),
            const Text('Kids Login'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Kids Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ask your parent for the code. Try: 1234',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              if (provider.kidsLogin(codeController.text)) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid code. Try: 1234')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kidsGreen),
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }
}

class LoggedInScreen extends StatelessWidget {
  const LoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/images/faith_klinik_logo.png',
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.church, size: 32);
                  },
                ),
                const SizedBox(width: 8),
                const Text('Faith Klinik'),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      _showNotificationsDialog(context, provider);
                    },
                  ),
                  if (provider.unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.unreadNotificationCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.currentUser?.name.split(' ').first ?? 'User',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          provider.currentUser?.role ?? '',
                          style: const TextStyle(fontSize: 10, color: AppColors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => provider.logout(),
              ),
            ],
          ),
          body: _getScreenForTab(provider.activeTab, provider),
          bottomNavigationBar: _buildBottomNavBar(context, provider),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, AppProvider provider) {
    // Different nav bars for different user roles
    if (provider.currentUser?.role == 'child') {
      return BottomNavigationBar(
        currentIndex: _getKidsTabIndex(provider.activeTab),
        onTap: (index) => _onKidsTabTapped(index, provider),
        selectedItemColor: AppColors.kidsPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Stories'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Videos'),
        ],
      );
    }

    // Admin/Pastor nav bar
    if (provider.currentUser?.role == 'admin' || provider.currentUser?.role == 'pastor') {
      return BottomNavigationBar(
        currentIndex: _getAdminTabIndex(provider.activeTab),
        onTap: (index) => _onAdminTabTapped(index, provider),
        selectedItemColor: AppColors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      );
    }

    // Member nav bar
    return BottomNavigationBar(
      currentIndex: _getMemberTabIndex(provider.activeTab),
      onTap: (index) => _onMemberTabTapped(index, provider),
      selectedItemColor: AppColors.brown,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Give'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }

  int _getKidsTabIndex(String tab) {
    switch (tab) {
      case 'dashboard':
        return 0;
      case 'kids-games':
        return 1;
      case 'kids-lessons':
        return 2;
      case 'kids-sermons':
        return 3;
      default:
        return 0;
    }
  }

  void _onKidsTabTapped(int index, AppProvider provider) {
    switch (index) {
      case 0:
        provider.setActiveTab('dashboard');
        break;
      case 1:
        provider.setActiveTab('kids-games');
        break;
      case 2:
        provider.setActiveTab('kids-lessons');
        break;
      case 3:
        provider.setActiveTab('kids-sermons');
        break;
    }
  }

  int _getAdminTabIndex(String tab) {
    switch (tab) {
      case 'dashboard':
        return 0;
      case 'members':
        return 1;
      case 'events':
        return 2;
      default:
        return 3;
    }
  }

  void _onAdminTabTapped(int index, AppProvider provider) {
    switch (index) {
      case 0:
        provider.setActiveTab('dashboard');
        break;
      case 1:
        provider.setActiveTab('members');
        break;
      case 2:
        provider.setActiveTab('events');
        break;
      case 3:
        _showMoreMenu(provider);
        break;
    }
  }

  int _getMemberTabIndex(String tab) {
    switch (tab) {
      case 'dashboard':
        return 0;
      case 'events':
        return 1;
      case 'giving':
        return 2;
      default:
        return 3;
    }
  }

  void _onMemberTabTapped(int index, AppProvider provider) {
    switch (index) {
      case 0:
        provider.setActiveTab('dashboard');
        break;
      case 1:
        provider.setActiveTab('events');
        break;
      case 2:
        provider.setActiveTab('giving');
        break;
      case 3:
        _showMoreMenu(provider);
        break;
    }
  }

  void _showMoreMenu(AppProvider provider) {
    // This will be handled by a menu dialog
  }

  Widget _getScreenForTab(String tab, AppProvider provider) {
    switch (tab) {
      case 'dashboard':
        return DashboardScreen(provider: provider);
      case 'members':
        return MembersScreen(provider: provider);
      case 'events':
        return EventsScreen(provider: provider);
      case 'finances':
        return FinancesScreen(provider: provider);
      case 'communications':
        return CommunicationsScreen(provider: provider);
      case 'streaming':
        return StreamingScreen(provider: provider);
      case 'prayers':
        return PrayersScreen(provider: provider);
      case 'departments':
        return DepartmentsScreen(provider: provider);
      case 'ministries':
        return MinistriesScreen(provider: provider);
      case 'announcements':
        return AnnouncementsScreen(provider: provider);
      case 'giving':
        return GivingScreen(provider: provider);
      case 'bible-apps':
        return BibleAppsScreen(provider: provider);
      case 'kids-games':
        return KidsGamesScreen(provider: provider);
      case 'kids-lessons':
        return KidsLessonsScreen(provider: provider);
      case 'kids-sermons':
        return KidsSermonsScreen(provider: provider);
      default:
        return DashboardScreen(provider: provider);
    }
  }

  void _showNotificationsDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              return ListTile(
                leading: Icon(
                  notif.read ? Icons.mail_outline : Icons.mail,
                  color: notif.read ? Colors.grey : AppColors.brown,
                ),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notif.message),
                trailing: Text(notif.date, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  provider.markNotificationAsRead(notif.id);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  final AppProvider provider;

  const DashboardScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.currentUser?.role == 'child') {
      return _buildKidsDashboard(context);
    }
    return _buildAdultDashboard(context);
  }

  Widget _buildKidsDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsPink.withOpacity(0.3), AppColors.kidsPurple.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.wb_sunny, size: 64, color: AppColors.kidsYellow),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${provider.currentUser?.name.split(' ').last ?? 'Friend'}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kidsPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's learn about Jesus together!",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildKidsCard(
                context,
                icon: Icons.games,
                title: 'Fun Games',
                subtitle: 'Bible adventures!',
                color: AppColors.kidsGreen,
                onTap: () => provider.setActiveTab('kids-games'),
              ),
              _buildKidsCard(
                context,
                icon: Icons.book,
                title: 'Bible Stories',
                subtitle: 'Amazing lessons!',
                color: AppColors.kidsBlue,
                onTap: () => provider.setActiveTab('kids-lessons'),
              ),
              _buildKidsCard(
                context,
                icon: Icons.video_library,
                title: 'Kid Sermons',
                subtitle: 'Watch & learn!',
                color: AppColors.kidsOrange,
                onTap: () => provider.setActiveTab('kids-sermons'),
              ),
              _buildKidsCard(
                context,
                icon: Icons.favorite,
                title: 'Prayer Time',
                subtitle: 'Talk to God!',
                color: AppColors.kidsPurple,
                onTap: () => provider.setActiveTab('prayers'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kidsYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kidsYellow),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 32, color: AppColors.kidsYellow),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Progress',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Games: ${provider.kidsGames.where((g) => g.completed).length}/${provider.kidsGames.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Stories: ${provider.kidsLessons.where((l) => l.completed).length}/${provider.kidsLessons.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kidsGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kidsGreen),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.auto_stories, size: 32, color: AppColors.kidsGreen),
                      SizedBox(height: 8),
                      Text(
                        "Today's Verse",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"Jesus loves me, this I know!"',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'John 3:16',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKidsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdultDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${provider.currentUser?.name ?? 'User'}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Faith Klinik Church Management System',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                icon: Icons.people,
                title: 'Total Members',
                value: '${provider.members.length}',
                color: AppColors.info,
              ),
              _buildStatCard(
                icon: Icons.event,
                title: 'Upcoming Events',
                value: '${provider.events.length}',
                color: AppColors.success,
              ),
              _buildStatCard(
                icon: Icons.attach_money,
                title: 'This Month',
                value: '\$${provider.getTotalFinances().toStringAsFixed(0)}',
                color: AppColors.brown,
              ),
              _buildStatCard(
                icon: Icons.video_library,
                title: 'Live Streams',
                value: '${provider.getLiveStreamCount()}',
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            context,
            icon: Icons.video_call,
            title: 'Start Live Stream',
            subtitle: 'Begin streaming worship',
            onTap: () => provider.setActiveTab('streaming'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            context,
            icon: Icons.volunteer_activism,
            title: 'Online Giving',
            subtitle: 'Give tithes and offerings',
            onTap: () => provider.setActiveTab('giving'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            context,
            icon: Icons.menu_book,
            title: 'Bible Apps',
            subtitle: 'Access Bible reading apps',
            onTap: () => provider.setActiveTab('bible-apps'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.brown),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens - will be implemented
class MembersScreen extends StatelessWidget {
  final AppProvider provider;
  const MembersScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.members.length,
        itemBuilder: (context, index) {
          final member = provider.members[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.brown,
                child: Text(member.name[0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(member.name),
              subtitle: Text('${member.role} • ${member.department}'),
              trailing: Text(member.status, style: const TextStyle(color: AppColors.success)),
            ),
          );
        },
      ),
      floatingActionButton: (provider.currentUser?.role == 'admin' || provider.currentUser?.role == 'pastor')
          ? FloatingActionButton(
              onPressed: () => _showAddMemberDialog(context, provider),
              backgroundColor: AppColors.brown,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddMemberDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'Member';
    String selectedDepartment = provider.departments.first.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newMember = Member(
                id: DateTime.now().millisecondsSinceEpoch,
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                role: selectedRole,
                department: selectedDepartment,
                joinDate: DateTime.now().toString().split(' ')[0],
                status: 'Active',
              );
              provider.addMember(newMember);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brown),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class EventsScreen extends StatelessWidget {
  final AppProvider provider;
  const EventsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: provider.events.length,
        itemBuilder: (context, index) {
          final event = provider.events[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(event.status, style: const TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.date, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(event.time, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: (provider.currentUser?.role == 'admin' || provider.currentUser?.role == 'pastor')
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.brown,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class FinancesScreen extends StatelessWidget {
  final AppProvider provider;
  const FinancesScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildFinanceCard('Tithes', provider.getTotalFinancesByType('Tithe'), AppColors.success),
              _buildFinanceCard('Offerings', provider.getTotalFinancesByType('Offering'), AppColors.info),
              _buildFinanceCard('Special', provider.getTotalFinancesByType('Special Gift'), AppColors.brown),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.finances.length,
            itemBuilder: (context, index) {
              final finance = provider.finances[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success.withOpacity(0.2),
                    child: const Icon(Icons.attach_money, color: AppColors.success),
                  ),
                  title: Text(finance.type),
                  subtitle: Text('${finance.member} • ${finance.method}'),
                  trailing: Text(
                    '\$${finance.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class CommunicationsScreen extends StatelessWidget {
  final AppProvider provider;
  const CommunicationsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        return Card(
          child: ListTile(
            leading: Icon(
              message.read ? Icons.mail_outline : Icons.mail,
              color: message.read ? Colors.grey : AppColors.brown,
            ),
            title: Text(
              message.subject,
              style: TextStyle(fontWeight: message.read ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Text('From: ${message.sender} • To: ${message.recipient}'),
            trailing: message.priority == 'high'
                ? const Chip(
                    label: Text('High', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.red,
                    labelPadding: EdgeInsets.symmetric(horizontal: 4),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class StreamingScreen extends StatelessWidget {
  final AppProvider provider;
  const StreamingScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: provider.streams.length,
      itemBuilder: (context, index) {
        final stream = provider.streams[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: stream.status == 'Live' ? Colors.red : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stream.status,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stream.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('${stream.date} • ${stream.time}', style: const TextStyle(fontSize: 12)),
                    Text('${stream.viewers} viewers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PrayersScreen extends StatelessWidget {
  final AppProvider provider;
  const PrayersScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.prayerRequests.length,
      itemBuilder: (context, index) {
        final prayer = provider.prayerRequests[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: prayer.status == 'Open' ? AppColors.info : AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        prayer.status,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (prayer.private)
                      const Icon(Icons.lock, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prayer.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(prayer.request),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By ${prayer.member}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${prayer.responses}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DepartmentsScreen extends StatelessWidget {
  final AppProvider provider;
  const DepartmentsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: provider.departments.length,
      itemBuilder: (context, index) {
        final dept = provider.departments[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.people, color: AppColors.brown),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone, size: 20),
                          color: AppColors.kidsGreen,
                          onPressed: () => _launchURL(dept.whatsappGroup),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dept.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  'Head: ${dept.head}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dept.members.length} members',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class MinistriesScreen extends StatelessWidget {
  final AppProvider provider;
  const MinistriesScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: provider.ministries.length,
      itemBuilder: (context, index) {
        final ministry = provider.ministries[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.volunteer_activism, color: AppColors.brown, size: 32),
                const SizedBox(height: 12),
                Text(
                  ministry.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  ministry.description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  'Leader: ${ministry.leader}',
                  style: const TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${ministry.meetingDay} at ${ministry.meetingTime}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  final AppProvider provider;
  const AnnouncementsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.announcements.length,
      itemBuilder: (context, index) {
        final announcement = provider.announcements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: announcement.priority == 'high'
                  ? Colors.red
                  : announcement.priority == 'normal'
                      ? Colors.orange
                      : Colors.grey,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.campaign,
                      color: announcement.priority == 'high' ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(announcement.content),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By ${announcement.author}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      announcement.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GivingScreen extends StatelessWidget {
  final AppProvider provider;
  const GivingScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsGreen.withOpacity(0.2), AppColors.kidsBlue.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.volunteer_activism, size: 64, color: AppColors.kidsGreen),
                SizedBox(height: 16),
                Text(
                  'Online Giving',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Give joyfully as God has blessed you',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: provider.givingOptions.length,
            itemBuilder: (context, index) {
              final option = provider.givingOptions[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 32, color: AppColors.kidsGreen),
                      const SizedBox(height: 12),
                      Text(
                        option.type,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.description,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${option.type} giving - Amount: \$${option.suggested.first}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsGreen,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: Text('Give \$${option.suggested.first}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BibleAppsScreen extends StatelessWidget {
  final AppProvider provider;
  const BibleAppsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsBlue.withOpacity(0.2), AppColors.kidsPurple.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.menu_book, size: 64, color: AppColors.kidsBlue),
                SizedBox(height: 16),
                Text(
                  'Bible Reading Apps',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Access God's Word anytime, anywhere",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: provider.bibleApps.length,
            itemBuilder: (context, index) {
              final app = provider.bibleApps[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.kidsBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book, size: 32, color: AppColors.kidsBlue),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        app.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _launchURL(app.url),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsBlue,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Kids Portal Screens
class KidsGamesScreen extends StatelessWidget {
  final AppProvider provider;
  const KidsGamesScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsGreen.withOpacity(0.3), AppColors.kidsBlue.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.games, size: 64, color: AppColors.kidsGreen),
                SizedBox(height: 16),
                Text(
                  'Bible Adventure Games!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.kidsGreen),
                ),
                SizedBox(height: 8),
                Text(
                  'Play fun games and learn about God!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: provider.kidsGames.length,
            itemBuilder: (context, index) {
              final game = provider.kidsGames[index];
              final color = game.difficulty == 'Easy'
                  ? AppColors.kidsGreen
                  : game.difficulty == 'Medium'
                      ? AppColors.kidsYellow
                      : AppColors.kidsOrange;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (game.completed)
                          const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.check_circle, color: Colors.white),
                          ),
                        const Icon(Icons.games, size: 48, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          game.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            game.difficulty,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Starting ${game.title}...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: color,
                            minimumSize: const Size(double.infinity, 36),
                          ),
                          child: Text(game.completed ? 'Play Again!' : 'Start Game!'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class KidsLessonsScreen extends StatelessWidget {
  final AppProvider provider;
  const KidsLessonsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsBlue.withOpacity(0.3), AppColors.kidsPurple.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.auto_stories, size: 64, color: AppColors.kidsBlue),
                SizedBox(height: 16),
                Text(
                  'Amazing Bible Stories!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.kidsBlue),
                ),
                SizedBox(height: 8),
                Text(
                  "Discover God's love through wonderful stories!",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.kidsLessons.length,
            itemBuilder: (context, index) {
              final lesson = provider.kidsLessons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: lesson.completed
                      ? const BorderSide(color: AppColors.kidsGreen, width: 2)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (lesson.completed)
                            const Icon(Icons.check_circle, color: AppColors.kidsGreen),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(lesson.content),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(lesson.duration, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          const Icon(Icons.child_care, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Age ${lesson.age}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening ${lesson.title}...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lesson.completed ? AppColors.kidsGreen : AppColors.kidsBlue,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(lesson.completed ? 'Read Again!' : 'Start Reading!'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class KidsSermonsScreen extends StatelessWidget {
  final AppProvider provider;
  const KidsSermonsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.kidsOrange.withOpacity(0.3), Colors.red.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.video_library, size: 64, color: AppColors.kidsOrange),
                SizedBox(height: 16),
                Text(
                  'Fun Kid Sermons!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.kidsOrange),
                ),
                SizedBox(height: 8),
                Text(
                  'Watch and learn about Jesus in a fun way!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: provider.kidsSermons.length,
            itemBuilder: (context, index) {
              final sermon = provider.kidsSermons[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.kidsOrange, Colors.red.shade400],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_filled, size: 48, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sermon.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${sermon.speaker}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(sermon.duration, style: const TextStyle(fontSize: 10)),
                              const Spacer(),
                              const Icon(Icons.visibility, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${sermon.views}', style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Playing ${sermon.title}...')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kidsOrange,
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text('Watch Now!', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
