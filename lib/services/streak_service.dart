import 'package:shared_preferences/shared_preferences.dart';

const String _kLastOpenKey = 'streak_last_open_date';
const String _kStreakCountKey = 'streak_count';
const String _kLongestStreakKey = 'streak_longest';
const String _kTotalDaysKey = 'streak_total_days';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  /// Call this on every app open. Updates streak and returns current count.
  Future<int> recordOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastOpen = prefs.getString(_kLastOpenKey);

    int streak = prefs.getInt(_kStreakCountKey) ?? 0;
    int longest = prefs.getInt(_kLongestStreakKey) ?? 0;
    int total = prefs.getInt(_kTotalDaysKey) ?? 0;

    if (lastOpen == today) {
      // Already opened today — no change
      return streak;
    }

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastOpen == yesterday) {
      // Consecutive day
      streak += 1;
    } else {
      // Streak broken
      streak = 1;
    }

    total += 1;
    if (streak > longest) longest = streak;

    await prefs.setString(_kLastOpenKey, today);
    await prefs.setInt(_kStreakCountKey, streak);
    await prefs.setInt(_kLongestStreakKey, longest);
    await prefs.setInt(_kTotalDaysKey, total);

    return streak;
  }

  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpen = prefs.getString(_kLastOpenKey);
    final streak = prefs.getInt(_kStreakCountKey) ?? 0;

    // If last open wasn't today or yesterday, streak is broken
    if (lastOpen == null) return 0;
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (lastOpen != today && lastOpen != yesterday) return 0;

    return streak;
  }

  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLongestStreakKey) ?? 0;
  }

  Future<int> getTotalDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTotalDaysKey) ?? 0;
  }

  /// Returns a motivational message for the current streak.
  String streakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Great start! Keep it up!';
    if (streak < 3) return '$streak days in a row! You\'re on a roll!';
    if (streak < 7) return '$streak days! God is pleased with your dedication!';
    if (streak < 14) return '$streak days! You\'re a faith warrior!';
    if (streak < 30) return '$streak days! Amazing devotion!';
    return '$streak days! You\'re a Bible Champion!';
  }

  /// Returns the flame emoji intensity based on streak.
  String streakEmoji(int streak) {
    if (streak == 0) return '💤';
    if (streak < 3) return '🌱';
    if (streak < 7) return '🔥';
    if (streak < 14) return '🔥🔥';
    if (streak < 30) return '🔥🔥🔥';
    return '👑🔥';
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
