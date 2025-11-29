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

  // Real church data - only keeping actual church leadership
  final List<User> _users = [
    User(id: 1, username: 'pastor', password: 'pastor123', role: 'pastor', name: 'Rev. Ebenezer Adarquah-Yiadom', email: 'pastor@faithklinikministries.com', phone: '(614) 555-0100', department: 'Leadership'),
    User(id: 2, username: 'admin', password: 'admin123', role: 'admin', name: 'Rev. Lucie Adarquah-Yiadom', email: 'residentpastor@faithklinikministries.com', phone: '(614) 555-0101', department: 'Administration'),
    User(id: 3, username: 'member', password: 'member123', role: 'member', name: 'Enam Egyir', email: 'enam@faithklinikministries.com', phone: '(614) 555-0104', department: 'Faith Klinik Dance Ministers'),
    User(id: 4, username: 'child', password: 'child123', role: 'child', name: 'Eyram Kwauvi', email: 'eyram@faithklinikministries.com', parent: 'Enam Egyir', age: 8),
  ];

  // Real church members - admin entered data
  List<Member> _members = [
    Member(id: 1, name: 'Rev. Ebenezer Adarquah-Yiadom', email: 'pastor@faithklinikministries.com', phone: '(614) 555-0100', role: 'Executive Pastor', department: 'Leadership', joinDate: '2018-01-01', status: 'Active'),
    Member(id: 2, name: 'Rev. Lucie Adarquah-Yiadom', email: 'residentpastor@faithklinikministries.com', phone: '(614) 555-0101', role: 'Resident Pastor', department: 'Administration', joinDate: '2018-01-01', status: 'Active'),
    Member(id: 3, name: 'Gloria Adarquah-Yiadom', email: 'elder.gloria@faithklinikministries.com', phone: '(614) 555-0102', role: 'Elder', department: 'Prayer Ministry', joinDate: '2018-02-15', status: 'Active'),
    Member(id: 4, name: 'Enam Egyir', email: 'enam@faithklinikministries.com', phone: '(614) 555-0104', role: 'Dance Ministry Leader', department: 'Faith Klinik Dance Ministers', joinDate: '2018-06-15', status: 'Active'),
    Member(id: 5, name: 'Jeshurun Adarquah-Yiadom', email: 'jeshurun@faithklinikministries.com', phone: '(614) 555-0110', role: 'Youth Pastor', department: 'Youth Ministry', joinDate: '2019-09-01', status: 'Active'),
  ];

  // Empty lists - admin will add real data
  List<Event> _events = [];
  List<Finance> _finances = []; // NO DUMMY DATA - User hasn't added any money yet
  List<PrayerRequest> _prayerRequests = [];
  List<Message> _messages = [];
  List<LiveStream> _streams = [];
  List<KidsGame> _kidsGames = [];
  List<KidsLesson> _kidsLessons = [];
  List<KidsSermon> _kidsSermons = [];
  List<Announcement> _announcements = [];
  List<AppNotification> _notifications = [];

  // Real giving options
  List<GivingOption> _givingOptions = [
    GivingOption(id: 1, type: 'Tithe', description: 'Regular 10% giving', suggested: [50, 100, 200, 500], frequency: 'Weekly'),
    GivingOption(id: 2, type: 'Offering', description: 'Additional gifts to God', suggested: [25, 50, 100, 250], frequency: 'As led'),
    GivingOption(id: 3, type: 'Building Fund', description: 'Support church expansion', suggested: [100, 250, 500, 1000], frequency: 'One-time'),
    GivingOption(id: 4, type: 'Missions', description: 'Support global missions', suggested: [50, 100, 300, 750], frequency: 'Monthly'),
    GivingOption(id: 5, type: 'Special Needs', description: 'Help those in need', suggested: [25, 75, 150, 400], frequency: 'As needed'),
  ];

  // Real church departments - keep this data as it's accurate (WhatsApp links empty for now)
  List<Department> _departments = [
    Department(id: 1, name: 'Leadership', head: 'Rev. Ebenezer Adarquah-Yiadom', members: ['Rev. Ebenezer', 'Rev. Lucie', 'Gloria'], whatsappGroup: '', slackChannel: '#leadership'),
    Department(id: 2, name: 'Youth Ministry', head: 'Jeshurun Adarquah-Yiadom', members: ['Jeshurun'], whatsappGroup: '', slackChannel: '#youth'),
    Department(id: 3, name: 'Faith Klinik Dance Ministers', head: 'Enam Egyir', members: ['Enam Egyir', 'Eyram', 'Edem'], whatsappGroup: '', slackChannel: '#dance'),
    Department(id: 4, name: 'League of Anointed Ministers', head: 'Jedidiah Adarquah-Yiadom', members: ['Jedidiah'], whatsappGroup: '', slackChannel: '#worship'),
    Department(id: 5, name: 'Food Pantry Ministry', head: 'Deaconness Esinam Segoh', members: ['Esinam'], whatsappGroup: '', slackChannel: '#foodpantry'),
    Department(id: 6, name: 'Media Ministry', head: 'Jasper D.', members: ['Jasper D.'], whatsappGroup: '', slackChannel: '#media'),
    Department(id: 7, name: 'Prayer Ministry', head: 'Gloria Adarquah-Yiadom', members: ['Rev. Ebenezer', 'Rev. Lucie', 'Gloria'], whatsappGroup: '', slackChannel: '#prayer'),
    Department(id: 8, name: 'Women Ministry', head: 'Rev. Lucie Adarquah-Yiadom', members: ['Rev. Lucie'], whatsappGroup: '', slackChannel: '#women'),
  ];

  // Real ministries
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

  // Bible apps - keep these as they're real resources
  List<BibleApp> _bibleApps = [
    BibleApp(id: 1, name: 'YouVersion Bible', description: 'Free Bible with multiple versions', url: 'https://www.bible.com/', category: 'All Ages'),
    BibleApp(id: 2, name: 'Bible for Kids', description: 'Interactive Bible stories for children', url: 'https://www.bible.com/kids', category: 'Kids'),
    BibleApp(id: 3, name: 'ESV Bible', description: 'English Standard Version Bible app', url: 'https://www.esv.org/', category: 'All Ages'),
    BibleApp(id: 4, name: 'KJV Bible', description: 'King James Version Bible app', url: 'https://play.google.com/store', category: 'All Ages'),
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

  // CRUD operations for Members
  void addMember(Member member) {
    _members.add(member);
    notifyListeners();
  }

  void updateMember(int id, Member updatedMember) {
    final index = _members.indexWhere((m) => m.id == id);
    if (index != -1) {
      _members[index] = updatedMember;
      notifyListeners();
    }
  }

  void deleteMember(int id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // CRUD operations for Events
  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(int id, Event updatedEvent) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(int id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // CRUD operations for Finances
  void addFinance(Finance finance) {
    _finances.add(finance);
    notifyListeners();
  }

  void updateFinance(int id, Finance updatedFinance) {
    final index = _finances.indexWhere((f) => f.id == id);
    if (index != -1) {
      _finances[index] = updatedFinance;
      notifyListeners();
    }
  }

  void deleteFinance(int id) {
    _finances.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  // CRUD operations for Prayer Requests
  void addPrayerRequest(PrayerRequest request) {
    _prayerRequests.add(request);
    notifyListeners();
  }

  void updatePrayerRequest(int id, PrayerRequest updatedRequest) {
    final index = _prayerRequests.indexWhere((pr) => pr.id == id);
    if (index != -1) {
      _prayerRequests[index] = updatedRequest;
      notifyListeners();
    }
  }

  void deletePrayerRequest(int id) {
    _prayerRequests.removeWhere((pr) => pr.id == id);
    notifyListeners();
  }

  // CRUD operations for Announcements
  void addAnnouncement(Announcement announcement) {
    _announcements.add(announcement);
    notifyListeners();
  }

  void updateAnnouncement(int id, Announcement updatedAnnouncement) {
    final index = _announcements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _announcements[index] = updatedAnnouncement;
      notifyListeners();
    }
  }

  void deleteAnnouncement(int id) {
    _announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // CRUD operations for Streams
  void addStream(LiveStream stream) {
    _streams.add(stream);
    notifyListeners();
  }

  void updateStream(int id, LiveStream updatedStream) {
    final index = _streams.indexWhere((s) => s.id == id);
    if (index != -1) {
      _streams[index] = updatedStream;
      notifyListeners();
    }
  }

  void deleteStream(int id) {
    _streams.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Notifications
  void markNotificationAsRead(int id) {
    final notif = _notifications.firstWhere((n) => n.id == id);
    notif.read = true;
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.add(notification);
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

  // Real Zoom info from website
  String getZoomMeetingId() {
    return '619 342 2249';
  }

  String getZoomPasscode() {
    return '12345';
  }

  String getZoomSchedule() {
    return 'Prayer: MON-THU 8PM-9PM\nBible Study: FRI 8PM-9:30PM';
  }
}
