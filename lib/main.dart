import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/supabase_service.dart';
import 'utils/colors.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/pending_approval_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/dashboard_screen.dart';
import 'views/members/members_screen.dart';
import 'views/events/events_screen.dart';
import 'views/finances/finances_screen.dart';
import 'views/streaming/streaming_screen.dart';
import 'views/prayers/prayers_screen.dart';
import 'views/departments/departments_screen.dart';
import 'views/announcements/announcements_screen.dart';
import 'views/messages/messages_screen.dart';
import 'views/giving/giving_screen.dart';
import 'views/resources/bible_apps_screen.dart';
import 'views/children/child_games_screen.dart';
import 'views/children/child_lessons_screen.dart';
import 'views/children/child_sermons_screen.dart';
import 'views/children/child_devotionals_screen.dart';
import 'views/notifications/notifications_screen.dart';
import 'views/settings/privacy_policy_screen.dart';
import 'views/settings/data_deletion_screen.dart';
import 'views/tools/birthday_card_screen.dart';
import 'views/tools/ai_tools_screen.dart';
import 'views/admin/admin_video_upload_screen.dart';
import 'views/church_groups/church_groups_screen.dart';
import 'views/membership/membership_screen.dart';
import 'views/children/guided_prayer_screen.dart';
import 'views/children/reading_plans_screen.dart';
import 'views/children/streak_screen.dart';
import 'views/media/event_gallery_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/admin/admin_bible_stories_screen.dart';
import 'views/sermons/sermons_screen.dart';
import 'views/connect/connect_card_screen.dart';
import 'views/resources/bulletin_screen.dart';
import 'views/devotionals/devotionals_screen.dart';
import 'views/volunteer/volunteer_screen.dart';
import 'views/staff/staff_screen.dart';
import 'views/banners/banners_screen.dart';
import 'views/quiz/quiz_home_screen.dart';
import 'views/notes/notes_screen.dart';
import 'views/resources/church_library_screen.dart';
import 'views/children/child_notes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await SupabaseService().initialize();
  } catch (e) {
    print('⚠️ Supabase initialization skipped: $e');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FaithKlinikApp(),
    ),
  );
}

class FaithKlinikApp extends StatelessWidget {
  const FaithKlinikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Faith Klinik Ministries',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/pending_approval': (context) => const PendingApprovalScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/members': (context) => const MembersScreen(),
            '/events': (context) => const EventsScreen(),
            '/finances': (context) => const FinancesScreen(),
            '/streaming': (context) => const StreamingScreen(),
            '/prayers': (context) => const PrayersScreen(),
            '/departments': (context) => const DepartmentsScreen(),
            '/ministries': (context) => const DepartmentsScreen(initialTab: 1),
            '/announcements': (context) => const AnnouncementsScreen(),
            '/messages': (context) => const MessagesScreen(),
            '/giving': (context) => const GivingScreen(),
            '/bible_apps': (context) => const BibleAppsScreen(),
            '/child_games': (context) => const ChildGamesScreen(),
            '/child_lessons': (context) => const ChildLessonsScreen(),
            '/child_sermons': (context) => const ChildSermonsScreen(),
            '/child_devotionals': (context) => const ChildDevotionalsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/privacy_policy': (context) => const PrivacyPolicyScreen(),
            '/data_deletion': (context) => const DataDeletionScreen(),
            '/birthday_card': (context) => const BirthdayCardScreen(),
            '/ai_tools': (context) => const AiToolsScreen(),
            '/admin/videos': (context) => const AdminVideoUploadScreen(),
            '/church_groups': (context) => const ChurchGroupsScreen(),
            '/membership': (context) => const MembershipScreen(),
            '/guided_prayers': (context) => const GuidedPrayerScreen(),
            '/reading_plans': (context) => const ReadingPlansScreen(),
            '/streak': (context) => const StreakScreen(),
            '/event_gallery': (context) => const EventGalleryScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/admin/bible_stories': (context) => const AdminBibleStoriesScreen(),
            '/sermons': (context) => const SermonsScreen(),
            '/connect': (context) => const ConnectCardScreen(),
            '/bulletin': (context) => const BulletinScreen(),
            '/devotionals': (context) => const DevotionalsScreen(),
            '/volunteer': (context) => const VolunteerScreen(),
            '/groups': (context) => const ChurchGroupsScreen(),
            '/staff': (context) => const StaffScreen(),
            '/admin/banners': (context) => const BannersScreen(),
            '/quiz': (context) => const QuizHomeScreen(),
            '/notes': (context) => const NotesScreen(),
            '/church_library': (context) => const ChurchLibraryScreen(),
            '/child_notes': (context) => const ChildNotesScreen(),
          },
        );
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        primary: AppColors.purple,
        secondary: AppColors.accentPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5FA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentPurple,
        primary: AppColors.accentPurple,
        secondary: AppColors.accentGold,
        surface: AppColors.darkSurface,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.accentPurple),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        color: AppColors.darkSurface2,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkSurface),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accentPurple,
        unselectedItemColor: Colors.grey,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.accentPurple,
        labelColor: AppColors.accentPurple,
        unselectedLabelColor: Colors.grey,
        dividerColor: AppColors.darkBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentPurple),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: AppColors.darkSurface2,
        iconColor: AppColors.accentPurple,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurface2,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface2,
        selectedColor: AppColors.accentPurple.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    );
  }
}
