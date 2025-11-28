import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/member.dart';
import '../models/event.dart';
import '../models/finance.dart';
import '../models/prayer_request.dart';
import '../models/message.dart';
import '../models/stream.dart';
import '../models/announcement.dart';
import '../models/department.dart';
import '../models/ministry.dart';
import '../models/kids_game.dart';
import '../models/kids_lesson.dart';
import '../models/kids_sermon.dart';
import '../models/giving_option.dart';
import '../models/bible_app.dart';
import '../models/notification.dart';

class AppProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;
  String _activeTab = 'dashboard';

  // All sample data from old React app
  final List<User> _users = [
    User(id: 1, username: 'pastor', password: 'pastor123', role: 'pastor', name: 'Rev. Ebenezer Adarquah-Yiadom', email: 'pastor@faithklinikministries.com', phone: '(614) 555-0100', department: 'Leadership'),
    User(id: 2, username: 'admin', password: 'admin123', role: 'admin', name: 'Rev. Lucie Adarquah-Yiadom', email: 'residentpastor@faithklinikministries.com', phone: '(614) 555-0101', department: 'Administration'),
    User(id: 3, username: 'member', password: 'member123', role: 'member', name: 'Enam Egyir', email: 'enam@faithklinikministries.com', phone: '(614) 555-0104', department: 'Faith Klinik Dance Ministers'),
    User(id: 4, username: 'child', password: 'child123', role: 'child', name: 'Eyram Kwauvi', email: 'eyram@faithklinikministries.com', parent: 'Enam Egyir', age: 8),
  ];

  List<Member> _members = [
    Member(id: 1, name: 'Rev. Ebenezer Adarquah-Yiadom', email: 'pastor@faithklinikministries.com', phone: '(614) 555-0100', role: 'Executive Pastor', department: 'Leadership', joinDate: '2018-01-01', status: 'Active'),
    Member(id: 2, name: 'Rev. Lucie Adarquah-Yiadom', email: 'residentpastor@faithklinikministries.com', phone: '(614) 555-0101', role: 'Resident Pastor', department: 'Administration', joinDate: '2018-01-01', status: 'Active'),
    Member(id: 3, name: 'Gloria Adarquah-Yiadom', email: 'elder.gloria@faithklinikministries.com', phone: '(614) 555-0102', role: 'Elder', department: 'Prayer Ministry', joinDate: '2018-02-15', status: 'Active'),
    Member(id: 4, name: 'Enam Egyir', email: 'enam@faithklinikministries.com', phone: '(614) 555-0104', role: 'Dance Ministry Leader', department: 'Faith Klinik Dance Ministers', joinDate: '2018-06-15', status: 'Active'),
    Member(id: 5, name: 'Jeshurun Adarquah-Yiadom', email: 'jeshurun@faithklinikministries.com', phone: '(614) 555-0110', role: 'Youth Pastor', department: 'Youth Ministry', joinDate: '2019-09-01', status: 'Active'),
  ];

  List<Event> _events = [
    Event(id: 1, title: 'Sunday Worship', date: '2024-01-07', time: '10:00 AM', location: 'Main Sanctuary', type: 'Worship', status: 'Scheduled'),
    Event(id: 2, title: 'Bible Study', date: '2024-01-10', time: '7:00 PM', location: 'Fellowship Hall', type: 'Study', status: 'Scheduled'),
    Event(id: 3, title: 'Youth Meeting', date: '2024-01-12', time: '6:00 PM', location: 'Youth Room', type: 'Youth', status: 'Scheduled'),
    Event(id: 4, title: 'Prayer Meeting', date: '2024-01-14', time: '8:00 AM', location: 'Prayer Room', type: 'Prayer', status: 'Scheduled'),
  ];

  List<Finance> _finances = [
    Finance(id: 1, type: 'Tithe', amount: 500.00, member: 'John Smith', date: '2024-01-07', method: 'Cash', status: 'Received'),
    Finance(id: 2, type: 'Offering', amount: 150.00, member: 'Mary Johnson', date: '2024-01-07', method: 'Card', status: 'Received'),
    Finance(id: 3, type: 'Special Gift', amount: 1000.00, member: 'David Wilson', date: '2024-01-06', method: 'Transfer', status: 'Received'),
    Finance(id: 4, type: 'Building Fund', amount: 250.00, member: 'Sarah Brown', date: '2024-01-05', method: 'Cash', status: 'Received'),
  ];

  List<PrayerRequest> _prayerRequests = [
    PrayerRequest(id: 1, title: 'Healing Prayer', member: 'John Smith', request: 'Please pray for my mother who is in the hospital.', category: 'Health', status: 'Open', date: '2024-01-07', private: false, responses: 5),
    PrayerRequest(id: 2, title: 'Job Search', member: 'Mary Johnson', request: 'Seeking Gods guidance in finding employment.', category: 'Career', status: 'Open', date: '2024-01-06', private: false, responses: 3),
    PrayerRequest(id: 3, title: 'Family Restoration', member: 'David Wilson', request: 'Praying for reconciliation with my brother.', category: 'Family', status: 'Answered', date: '2024-01-05', private: false, responses: 8),
  ];

  List<Message> _messages = [
    Message(id: 1, sender: 'Pastor Johnson', recipient: 'All Members', subject: 'Welcome to the New Year!', content: 'May God bless you richly.', date: '2024-01-01', read: false, priority: 'high'),
    Message(id: 2, sender: 'Admin Mary', recipient: 'Youth Group', subject: 'Youth Meeting Update', content: 'Meeting this week focuses on leadership.', date: '2024-01-06', read: true, priority: 'normal'),
  ];

  List<LiveStream> _streams = [
    LiveStream(id: 1, title: 'Sunday Morning Worship', date: '2024-01-07', time: '10:00 AM', status: 'Live', viewers: 156, category: 'Worship'),
    LiveStream(id: 2, title: 'Midweek Bible Study', date: '2024-01-10', time: '7:00 PM', status: 'Scheduled', viewers: 0, category: 'Study'),
    LiveStream(id: 3, title: 'Prayer and Praise Night', date: '2024-01-03', time: '6:30 PM', status: 'Ended', viewers: 87, category: 'Prayer'),
  ];

  List<KidsGame> _kidsGames = [
    KidsGame(id: 1, title: 'Bible Memory Verse Game', description: 'Learn verses through fun activities!', difficulty: 'Easy', completed: false),
    KidsGame(id: 2, title: "Noah's Ark Animals", description: 'Help Noah collect all the animals!', difficulty: 'Easy', completed: true),
    KidsGame(id: 3, title: 'David and Goliath Adventure', description: 'Experience the epic Bible story!', difficulty: 'Medium', completed: false),
    KidsGame(id: 4, title: 'Bible Trivia Challenge', description: 'Test your Bible knowledge!', difficulty: 'Hard', completed: false),
  ];

  List<KidsLesson> _kidsLessons = [
    KidsLesson(id: 1, title: 'Jesus Loves Me', content: "Learn about God's amazing love for you!", duration: '10 min', age: '3-6', completed: false),
    KidsLesson(id: 2, title: 'The Good Samaritan', content: 'How to be kind to others', duration: '15 min', age: '6-10', completed: true),
    KidsLesson(id: 3, title: 'Creation Story', content: 'God created everything beautiful!', duration: '12 min', age: '4-8', completed: false),
    KidsLesson(id: 4, title: 'Daniel and the Lions', content: "Being brave with God's help", duration: '18 min', age: '7-12', completed: false),
  ];

  List<KidsSermon> _kidsSermons = [
    KidsSermon(id: 1, title: "God's Love is Bigger Than...", speaker: 'Pastor Kids', date: '2024-01-07', duration: '15:00', views: 45),
    KidsSermon(id: 2, title: 'Be Kind Like Jesus', speaker: 'Miss Sarah', date: '2024-01-06', duration: '12:30', views: 38),
    KidsSermon(id: 3, title: 'Prayer Warriors for Kids', speaker: 'Pastor Kids', date: '2024-01-05', duration: '14:45', views: 52),
    KidsSermon(id: 4, title: 'Bible Heroes Adventure', speaker: 'Teacher Mike', date: '2024-01-04', duration: '16:20', views: 41),
  ];

  List<GivingOption> _givingOptions = [
    GivingOption(id: 1, type: 'Tithe', description: 'Regular 10% giving', suggested: [50, 100, 200, 500], frequency: 'Weekly'),
    GivingOption(id: 2, type: 'Offering', description: 'Additional gifts to God', suggested: [25, 50, 100, 250], frequency: 'As led'),
    GivingOption(id: 3, type: 'Building Fund', description: 'Support church expansion', suggested: [100, 250, 500, 1000], frequency: 'One-time'),
    GivingOption(id: 4, type: 'Missions', description: 'Support global missions', suggested: [50, 100, 300, 750], frequency: 'Monthly'),
    GivingOption(id: 5, type: 'Special Needs', description: 'Help those in need', suggested: [25, 75, 150, 400], frequency: 'As needed'),
  ];

  List<Department> _departments = [
    Department(id: 1, name: 'Leadership', head: 'Rev. Ebenezer Adarquah-Yiadom', members: ['Rev. Ebenezer', 'Rev. Lucie', 'Gloria'], whatsappGroup: 'https://chat.whatsapp.com/leadership123', slackChannel: '#leadership'),
    Department(id: 2, name: 'Youth Ministry', head: 'Jeshurun Adarquah-Yiadom', members: ['Jeshurun'], whatsappGroup: 'https://chat.whatsapp.com/youth123', slackChannel: '#youth'),
    Department(id: 3, name: 'Faith Klinik Dance Ministers', head: 'Enam Egyir', members: ['Enam Egyir', 'Eyram', 'Edem'], whatsappGroup: 'https://chat.whatsapp.com/dance123', slackChannel: '#dance'),
    Department(id: 4, name: 'League of Anointed Ministers', head: 'Jedidiah Adarquah-Yiadom', members: ['Jedidiah'], whatsappGroup: 'https://chat.whatsapp.com/worship123', slackChannel: '#worship'),
    Department(id: 5, name: 'Food Pantry Ministry', head: 'Deaconness Esinam Segoh', members: ['Esinam'], whatsappGroup: 'https://chat.whatsapp.com/foodpantry123', slackChannel: '#foodpantry'),
    Department(id: 6, name: 'Media Ministry', head: 'Jasper D.', members: ['Jasper D.'], whatsappGroup: 'https://chat.whatsapp.com/media123', slackChannel: '#media'),
    Department(id: 7, name: 'Prayer Ministry', head: 'Gloria Adarquah-Yiadom', members: ['Rev. Ebenezer', 'Rev. Lucie', 'Gloria'], whatsappGroup: 'https://chat.whatsapp.com/prayer123', slackChannel: '#prayer'),
    Department(id: 8, name: 'Women Ministry', head: 'Rev. Lucie Adarquah-Yiadom', members: ['Rev. Lucie'], whatsappGroup: 'https://chat.whatsapp.com/women123', slackChannel: '#women'),
  ];

  List<Ministry> _ministries = [
    Ministry(id: 1, name: 'Food Pantry Ministry', description: 'Providing food assistance to families in need', leader: 'Deaconness Esinam Segoh', meetingDay: 'Wednesday', meetingTime: '6:00 PM', location: 'Fellowship Hall'),
    Ministry(id: 2, name: 'Faith Klinik Dance Ministers', description: 'Expressing worship through dance and movement', leader: 'Enam Egyir', meetingDay: 'Saturday', meetingTime: '10:00 AM', location: 'Main Sanctuary'),
    Ministry(id: 3, name: 'League of Anointed Ministers', description: 'Leading congregation in worship through music', leader: 'Jedidiah Adarquah-Yiadom', meetingDay: 'Thursday', meetingTime: '7:00 PM', location: 'Music Room'),
    Ministry(id: 4, name: 'Media Ministry', description: 'Managing audio, video, and digital media', leader: 'Jasper D.', meetingDay: 'Second Saturday', meetingTime: '2:00 PM', location: 'Media Room'),
    Ministry(id: 5, name: 'Youth Ministry', description: 'Engaging and discipling the next generation', leader: 'Jeshurun Adarquah-Yiadom', meetingDay: 'Friday', meetingTime: '7:00 PM', location: 'Youth Room'),
    Ministry(id: 6, name: 'Prayer Ministry', description: 'Coordinating prayer meetings and intercession', leader: 'Gloria Adarquah-Yiadom', meetingDay: 'Multiple days', meetingTime: 'Various times', location: 'Prayer Room'),
    Ministry(id: 7, name: 'Women Ministry', description: 'Fellowship and growth for women in faith', leader: 'Rev. Lucie Adarquah-Yiadom', meetingDay: 'Second Saturday', meetingTime: '10:00 AM', location: 'Conference Room'),
    Ministry(id: 8, name: 'Evangelism Team', description: 'Reaching the lost with the Gospel', leader: 'Rev. Ebenezer Adarquah-Yiadom', meetingDay: 'Thursday', meetingTime: '7:00 PM', location: 'Fellowship Hall'),
  ];

  List<Announcement> _announcements = [
    Announcement(id: 1, title: 'Faith Klinik Annual Revival', content: 'Join us for 7 days of intensive prayer starting February 15th.', priority: 'high', author: 'Rev. Ebenezer', date: '2024-01-08', department: 'All', status: 'active'),
    Announcement(id: 2, title: 'Youth Ministry Camp Registration', content: 'Register now for annual youth camp (March 14-17).', priority: 'normal', author: 'Jeshurun', date: '2024-01-07', department: 'Youth Ministry', status: 'active'),
    Announcement(id: 3, title: 'Dance Ministry Practice', content: 'Practice every Saturday at 10:00 AM.', priority: 'normal', author: 'Enam Egyir', date: '2024-01-06', department: 'Faith Klinik Dance Ministers', status: 'active'),
  ];

  List<BibleApp> _bibleApps = [
    BibleApp(id: 1, name: 'YouVersion Bible', description: 'Free Bible with multiple versions', url: 'https://www.bible.com/', category: 'All Ages'),
    BibleApp(id: 2, name: 'Bible for Kids', description: 'Interactive Bible stories for children', url: 'https://www.bible.com/kids', category: 'Kids'),
    BibleApp(id: 3, name: 'ESV Bible', description: 'English Standard Version Bible app', url: 'https://www.esv.org/', category: 'All Ages'),
    BibleApp(id: 4, name: 'KJV Bible', description: 'King James Version Bible app', url: 'https://play.google.com/store', category: 'All Ages'),
  ];

  List<AppNotification> _notifications = [
    AppNotification(id: 1, title: 'New Member Joined', message: 'Sarah Brown joined the church', type: 'info', read: false, date: '2024-01-07'),
    AppNotification(id: 2, title: 'Event Reminder', message: 'Bible Study tomorrow at 7:00 PM', type: 'reminder', read: false, date: '2024-01-09'),
    AppNotification(id: 3, title: 'Prayer Request', message: 'New prayer request for healing', type: 'prayer', read: false, date: '2024-01-07'),
    AppNotification(id: 4, title: 'Live Stream Starting', message: 'Sunday Service starting in 5 minutes', type: 'stream', read: false, date: '2024-01-07'),
  ];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String get activeTab => _activeTab;
  List<Member> get members => _members;
  List<Event> get events => _events;
  List<Finance> get finances => _finances;
  List<PrayerRequest> get prayerRequests => _prayerRequests;
  List<Message> get messages => _messages;
  List<LiveStream> get streams => _streams;
  List<KidsGame> get kidsGames => _kidsGames;
  List<KidsLesson> get kidsLessons => _kidsLessons;
  List<KidsSermon> get kidsSermons => _kidsSermons;
  List<GivingOption> get givingOptions => _givingOptions;
  List<Department> get departments => _departments;
  List<Ministry> get ministries => _ministries;
  List<Announcement> get announcements => _announcements;
  List<BibleApp> get bibleApps => _bibleApps;
  List<AppNotification> get notifications => _notifications;

  int get unreadNotificationCount => _notifications.where((n) => !n.read).length;

  // Authentication
  bool login(String username, String password) {
    final user = _users.where((u) => u.username == username && u.password == password).firstOrNull;
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool kidsLogin(String code) {
    if (code == '1234') {
      final kidsUser = _users.firstWhere((u) => u.role == 'child');
      _currentUser = kidsUser;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _activeTab = 'dashboard';
    notifyListeners();
  }

  // Tab management
  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // CRUD operations
  void addMember(Member member) {
    _members.add(member);
    notifyListeners();
  }

  void markNotificationAsRead(int id) {
    final notif = _notifications.firstWhere((n) => n.id == id);
    notif.read = true;
    notifyListeners();
  }

  // Analytics
  double getTotalFinances() {
    return _finances.fold(0.0, (sum, f) => sum + f.amount);
  }

  double getTotalFinancesByType(String type) {
    return _finances.where((f) => f.type == type).fold(0.0, (sum, f) => sum + f.amount);
  }

  int getLiveStreamCount() {
    return _streams.where((s) => s.status == 'Live').length;
  }
}
