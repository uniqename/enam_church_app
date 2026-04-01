/// LocalDataService — pre-seeded real Faith Klinik Ministries data.
/// All services fall back to this when Supabase is not yet configured
/// or returns empty results. This ensures the app is fully functional
/// from first install.
library;

import '../models/department.dart';
import '../models/ministry.dart';
import '../models/child_game.dart';
import '../models/child_lesson.dart';
import '../models/child_sermon.dart';
import '../models/live_stream.dart';
import '../models/announcement.dart';
import '../models/member.dart';
import '../models/event.dart';
import '../models/prayer_request.dart';

class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  // ─────────────────────────────────────────────────────
  // DEPARTMENTS
  // ─────────────────────────────────────────────────────
  List<Department> getDepartments() => [
        const Department(
          id: 'dept-1',
          name: 'Leadership',
          heads: ['Rev. Ebenezer Adarquah-Yiadom'],
          members: [
            'Rev. Ebenezer Adarquah-Yiadom',
            'Rev. Lucie Adarquah-Yiadom',
            'Gloria Adarquah-Yiadom',
          ],
          whatsappGroup: 'https://chat.whatsapp.com/FKMLeadership',
          slackChannel: '#leadership',
        ),
        const Department(
          id: 'dept-2',
          name: 'Youth Ministry',
          heads: ['Jeshurun Adarquah-Yiadom'],
          members: ['Jeshurun Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMYouth',
          slackChannel: '#youth',
        ),
        const Department(
          id: 'dept-3',
          name: 'Faith Klinik Dance Ministers',
          heads: ['Enam Egyir'],
          members: ['Enam Egyir', 'Eyram Kwauvi', 'Edem Kwauvi'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMDance',
          slackChannel: '#dance',
        ),
        const Department(
          id: 'dept-4',
          name: 'League of Anointed Ministers',
          heads: ['Jedidiah Adarquah-Yiadom'],
          members: ['Jedidiah Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMWorship',
          slackChannel: '#worship',
        ),
        const Department(
          id: 'dept-5',
          name: 'Food Pantry Ministry',
          heads: ['Deaconess Esinam Segoh'],
          members: ['Deaconess Esinam Segoh'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMFoodPantry',
          slackChannel: '#foodpantry',
        ),
        const Department(
          id: 'dept-6',
          name: 'Media Ministry',
          heads: ['Jasper D.'],
          members: ['Jasper D.'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMMedia',
          slackChannel: '#media',
        ),
        const Department(
          id: 'dept-7',
          name: 'Prayer Ministry',
          heads: ['Gloria Adarquah-Yiadom'],
          members: [
            'Rev. Ebenezer Adarquah-Yiadom',
            'Rev. Lucie Adarquah-Yiadom',
            'Gloria Adarquah-Yiadom',
          ],
          whatsappGroup: 'https://chat.whatsapp.com/FKMPrayer',
          slackChannel: '#prayer',
        ),
        const Department(
          id: 'dept-8',
          name: 'Women Ministry',
          heads: ['Rev. Lucie Adarquah-Yiadom'],
          members: ['Rev. Lucie Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMWomen',
          slackChannel: '#women',
        ),
        const Department(
          id: 'dept-9',
          name: 'Men Ministry',
          heads: ['Rev. Ebenezer Adarquah-Yiadom'],
          members: ['Rev. Ebenezer Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMMen',
          slackChannel: '#men',
        ),
        const Department(
          id: 'dept-10',
          name: 'Ushering Department',
          heads: ['Deaconess Esinam Segoh'],
          members: ['Deaconess Esinam Segoh'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMUshers',
          slackChannel: '#ushers',
        ),
        const Department(
          id: 'dept-11',
          name: 'Children Ministry',
          heads: ['Rev. Lucie Adarquah-Yiadom'],
          members: ['Rev. Lucie Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMChildren',
          slackChannel: '#children',
        ),
        const Department(
          id: 'dept-12',
          name: 'Evangelism',
          heads: ['Rev. Ebenezer Adarquah-Yiadom'],
          members: ['Rev. Ebenezer Adarquah-Yiadom'],
          whatsappGroup: 'https://chat.whatsapp.com/FKMEvangelism',
          slackChannel: '#evangelism',
        ),
      ];

  // ─────────────────────────────────────────────────────
  // MINISTRIES
  // ─────────────────────────────────────────────────────
  List<Ministry> getMinistries() => [
        const Ministry(
          id: 'min-1',
          name: 'Food Pantry Ministry',
          description:
              'Providing food assistance to families in need in the Columbus community. '
              'We serve over 100 families monthly and accept donations every Wednesday.',
          leader: 'Deaconess Esinam Segoh',
          meetingDay: 'Wednesday',
          meetingTime: '6:00 PM',
          location: 'Fellowship Hall',
        ),
        const Ministry(
          id: 'min-2',
          name: 'Faith Klinik Dance Ministers',
          description:
              'Expressing worship through dance and movement. We minister during '
              'Sunday services, special programs, and outreach events.',
          leader: 'Enam Egyir',
          meetingDay: 'Saturday',
          meetingTime: '10:00 AM',
          location: 'Main Sanctuary',
        ),
        const Ministry(
          id: 'min-3',
          name: 'League of Anointed Ministers',
          description:
              'Leading the congregation in worship through music and praise. '
              'We seek God\'s presence through anointed songs and instruments.',
          leader: 'Jedidiah Adarquah-Yiadom',
          meetingDay: 'Thursday',
          meetingTime: '7:00 PM',
          location: 'Music Room',
        ),
        const Ministry(
          id: 'min-4',
          name: 'Media Ministry',
          description:
              'Managing audio, video, live streaming, and digital media for all '
              'church services and events. We ensure the Gospel reaches the world.',
          leader: 'Jasper D.',
          meetingDay: 'Second Saturday',
          meetingTime: '2:00 PM',
          location: 'Media Room',
        ),
        const Ministry(
          id: 'min-5',
          name: 'Youth Ministry',
          description:
              'Engaging and discipling the next generation in their faith journey. '
              'Weekly youth services, camps, and mentorship programs.',
          leader: 'Jeshurun Adarquah-Yiadom',
          meetingDay: 'Friday',
          meetingTime: '7:00 PM',
          location: 'Youth Room',
        ),
        const Ministry(
          id: 'min-6',
          name: 'Prayer Ministry',
          description:
              'Coordinating prayer meetings and intercession for the church and community. '
              'Daily Zoom prayers Mon–Thu 8–9 PM. Bible Study Fridays 8–9:30 PM.',
          leader: 'Gloria Adarquah-Yiadom',
          meetingDay: 'Daily (Mon–Fri)',
          meetingTime: '8:00 PM',
          location: 'Prayer Room / Zoom ID: 619 342 2249',
        ),
        const Ministry(
          id: 'min-7',
          name: 'Women Ministry',
          description:
              'Fellowship and growth for women in faith. Monthly meetings, '
              'conferences, and community outreach for women of all ages.',
          leader: 'Rev. Lucie Adarquah-Yiadom',
          meetingDay: 'Second Saturday',
          meetingTime: '10:00 AM',
          location: 'Conference Room',
        ),
        const Ministry(
          id: 'min-8',
          name: 'Evangelism Team',
          description:
              'Reaching the lost with the Gospel in Columbus and beyond. '
              'Faith Klinik is a primarily missions-minded church supporting world evangelism.',
          leader: 'Rev. Ebenezer Adarquah-Yiadom',
          meetingDay: 'Thursday',
          meetingTime: '7:00 PM',
          location: 'Fellowship Hall',
        ),
        const Ministry(
          id: 'min-9',
          name: 'Men Ministry',
          description:
              'Building strong men of faith and character. Monthly breakfasts, '
              'accountability groups, and community service projects.',
          leader: 'Rev. Ebenezer Adarquah-Yiadom',
          meetingDay: 'First Saturday',
          meetingTime: '8:00 AM',
          location: 'Fellowship Hall',
        ),
        const Ministry(
          id: 'min-10',
          name: 'Ushering Ministry',
          description:
              'Welcoming and serving church attendees with excellence and hospitality. '
              'Training every third Sunday for all new ushers.',
          leader: 'Deaconess Esinam Segoh',
          meetingDay: 'Third Sunday',
          meetingTime: '12:00 PM',
          location: 'Main Sanctuary',
        ),
        const Ministry(
          id: 'min-11',
          name: 'Children Ministry',
          description:
              'Teaching children about Jesus in fun and engaging ways. '
              'Sunday children church, Bible lessons, games, and special events.',
          leader: 'Rev. Lucie Adarquah-Yiadom',
          meetingDay: 'Sunday',
          meetingTime: '10:00 AM',
          location: 'Children Hall',
        ),
      ];

  // ─────────────────────────────────────────────────────
  // MEMBERS
  // ─────────────────────────────────────────────────────
  List<Member> getMembers() => [
        Member(
          id: 'mem-1',
          name: 'Rev. Ebenezer Adarquah-Yiadom',
          email: 'pastor@faithklinikministries.com',
          phone: '(614) 555-0100',
          role: 'Executive Pastor',
          department: 'Leadership',
          joinDate: DateTime(2018, 1, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-2',
          name: 'Rev. Lucie Adarquah-Yiadom',
          email: 'residentpastor@faithklinikministries.com',
          phone: '(614) 555-0101',
          role: 'Resident Pastor',
          department: 'Administration',
          joinDate: DateTime(2018, 1, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-3',
          name: 'Gloria Adarquah-Yiadom',
          email: 'elder.gloria@faithklinikministries.com',
          phone: '(614) 555-0102',
          role: 'Elder',
          department: 'Prayer Ministry',
          joinDate: DateTime(2018, 2, 15),
          status: 'Active',
        ),
        Member(
          id: 'mem-4',
          name: 'Deaconess Esinam Segoh',
          email: 'esinam@faithklinikministries.com',
          phone: '(614) 555-0103',
          role: 'Deaconess',
          department: 'Food Pantry Ministry',
          joinDate: DateTime(2018, 3, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-5',
          name: 'Enam Egyir',
          email: 'enam@faithklinikministries.com',
          phone: '(614) 555-0104',
          role: 'Dance Ministry Leader',
          department: 'Faith Klinik Dance Ministers',
          joinDate: DateTime(2018, 6, 15),
          status: 'Active',
          isDeptHead: true,
          ministries: ['Ushering Lead', "Children's Dance Lead", 'Elder'],
        ),
        Member(
          id: 'mem-6',
          name: 'Jedidiah Adarquah-Yiadom',
          email: 'jedidiah@faithklinikministries.com',
          phone: '(614) 555-0105',
          role: 'Music Ministry Leader',
          department: 'League of Anointed Ministers',
          joinDate: DateTime(2018, 8, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-7',
          name: 'Jasper D.',
          email: 'jasper@faithklinikministries.com',
          phone: '(614) 555-0108',
          role: 'Media Ministry Leader',
          department: 'Media Ministry',
          joinDate: DateTime(2019, 1, 20),
          status: 'Active',
        ),
        Member(
          id: 'mem-8',
          name: 'Jeshurun Adarquah-Yiadom',
          email: 'jeshurun@faithklinikministries.com',
          phone: '(614) 555-0110',
          role: 'Youth Pastor',
          department: 'Youth Ministry',
          joinDate: DateTime(2019, 9, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-9',
          name: 'Eyram Kwauvi',
          email: 'eyram@faithklinikministries.com',
          phone: '(614) 555-0112',
          role: 'Dance Team Member',
          department: 'Faith Klinik Dance Ministers',
          joinDate: DateTime(2020, 2, 1),
          status: 'Active',
        ),
        Member(
          id: 'mem-10',
          name: 'Edem Kwauvi',
          email: 'edem@faithklinikministries.com',
          phone: '(614) 555-0113',
          role: 'Dance Team Member',
          department: 'Faith Klinik Dance Ministers',
          joinDate: DateTime(2020, 2, 1),
          status: 'Active',
        ),
      ];

  // ─────────────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────────────
  List<Event> getEvents() {
    final now = DateTime.now();
    return [
      Event(
        id: 'evt-1',
        title: 'Sunday Worship Service',
        date: _nextWeekday(now, DateTime.sunday),
        time: '8:30 AM – 10:00 AM',
        location: 'Main Sanctuary',
        type: 'Worship',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-2',
        title: 'Morning Prayer',
        date: _nextWeekday(now, DateTime.sunday),
        time: '7:30 AM – 8:00 AM',
        location: 'Prayer Room',
        type: 'Prayer',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-3',
        title: 'Zoom Bible Study',
        date: _nextWeekday(now, DateTime.friday),
        time: '8:00 PM – 9:30 PM',
        location: 'Zoom – ID: 619 342 2249 | Passcode: 12345',
        type: 'Study',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-4',
        title: 'Zoom Daily Prayer',
        date: _nextWeekday(now, DateTime.monday),
        time: '8:00 PM – 9:00 PM',
        location: 'Zoom – ID: 619 342 2249 | Passcode: 12345',
        type: 'Prayer',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-5',
        title: 'Youth Meeting',
        date: _nextWeekday(now, DateTime.friday),
        time: '7:00 PM',
        location: 'Youth Room',
        type: 'Youth',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-6',
        title: 'Dance Ministry Practice',
        date: _nextWeekday(now, DateTime.saturday),
        time: '10:00 AM',
        location: 'Main Sanctuary',
        type: 'Ministry',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-7',
        title: 'Food Pantry Service',
        date: _nextWeekday(now, DateTime.wednesday),
        time: '6:00 PM',
        location: 'Fellowship Hall',
        type: 'Outreach',
        status: 'Upcoming',
      ),
      Event(
        id: 'evt-8',
        title: 'Praise & Worship Night',
        date: DateTime(now.year, now.month + 1, 1),
        time: '6:00 PM',
        location: 'Main Sanctuary',
        type: 'Worship',
        status: 'Upcoming',
      ),
    ];
  }

  DateTime _nextWeekday(DateTime from, int weekday) {
    var d = from;
    while (d.weekday != weekday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  // ─────────────────────────────────────────────────────
  // ANNOUNCEMENTS
  // ─────────────────────────────────────────────────────
  List<Announcement> getAnnouncements() {
    final now = DateTime.now();
    return [
      Announcement(
        id: 'ann-1',
        title: 'Faith Klinik Annual Revival',
        content:
            'Join us for 7 days of intensive prayer and worship! Services at 6:00 AM and '
            '7:00 PM daily. Special guest ministers from across Ohio. All are welcome!',
        priority: 'High',
        author: 'Rev. Ebenezer Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 2)),
        department: 'All',
        status: 'Published',
      ),
      Announcement(
        id: 'ann-2',
        title: 'Youth Ministry Camp Registration',
        content:
            'Register now for the annual youth camp at Camp Akita! Early bird discount available. '
            'Contact Jeshurun Adarquah-Yiadom for details and registration forms.',
        priority: 'Normal',
        author: 'Jeshurun Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 3)),
        department: 'Youth Ministry',
        status: 'Published',
      ),
      Announcement(
        id: 'ann-3',
        title: 'Dance Ministry Practice – New Members Welcome',
        content:
            'Dance ministry practice every Saturday at 10:00 AM in the Main Sanctuary. '
            'New members are warmly welcome! Contact Enam Egyir for more information.',
        priority: 'Normal',
        author: 'Enam Egyir',
        date: now.subtract(const Duration(days: 4)),
        department: 'Faith Klinik Dance Ministers',
        status: 'Published',
      ),
      Announcement(
        id: 'ann-4',
        title: 'Food Pantry Expansion – Volunteers Needed',
        content:
            'We are expanding our food pantry to serve more families in Columbus. '
            'Volunteers needed every Wednesday 6:00 PM. Target: serve 100 families monthly. '
            'Contact Deaconess Esinam Segoh to volunteer.',
        priority: 'High',
        author: 'Deaconess Esinam Segoh',
        date: now.subtract(const Duration(days: 5)),
        department: 'Food Pantry Ministry',
        status: 'Published',
      ),
      Announcement(
        id: 'ann-5',
        title: 'New Member Orientation',
        content:
            'New member orientation class every first Sunday at 2:00 PM in the Fellowship Hall. '
            'Learn about Faith Klinik Ministries, our vision, and how to get connected!',
        priority: 'Normal',
        author: 'Rev. Lucie Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 6)),
        department: 'All',
        status: 'Published',
      ),
      Announcement(
        id: 'ann-6',
        title: 'Zoom Prayer & Bible Study',
        content:
            'Join our Zoom daily prayer Mon–Thu 8:00–9:00 PM and Bible Study every Friday '
            '8:00–9:30 PM. Zoom Meeting ID: 619 342 2249 | Passcode: 12345. '
            'Everyone is invited!',
        priority: 'Normal',
        author: 'Gloria Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 1)),
        department: 'Prayer Ministry',
        status: 'Published',
      ),
    ];
  }

  // ─────────────────────────────────────────────────────
  // LIVE STREAMS
  // ─────────────────────────────────────────────────────
  List<LiveStream> getStreams() {
    final now = DateTime.now();
    final sunday = _nextWeekday(now, DateTime.sunday);
    return [
      LiveStream(
        id: 'stream-1',
        title: 'Sunday Morning Worship Service – Faith Klinik Ministries',
        date: sunday,
        time: '8:30 AM',
        status: 'Upcoming',
        viewers: 0,
        category: 'Worship',
        streamUrl: 'https://www.youtube.com/@FaithKlinikMinistries/streams',
      ),
      LiveStream(
        id: 'stream-2',
        title: 'Midweek Bible Study',
        date: _nextWeekday(now, DateTime.friday),
        time: '8:00 PM',
        status: 'Upcoming',
        viewers: 0,
        category: 'Bible Study',
        streamUrl: 'https://www.youtube.com/@FaithKlinikMinistries/streams',
      ),
      LiveStream(
        id: 'stream-3',
        title: 'Praise & Worship Night',
        date: now.subtract(const Duration(days: 7)),
        time: '6:00 PM',
        status: 'Ended',
        viewers: 87,
        category: 'Worship',
        streamUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
      LiveStream(
        id: 'stream-4',
        title: 'Youth Service',
        date: now.subtract(const Duration(days: 14)),
        time: '7:00 PM',
        status: 'Ended',
        viewers: 45,
        category: 'Youth',
        streamUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
    ];
  }

  // ─────────────────────────────────────────────────────
  // PRAYER REQUESTS
  // ─────────────────────────────────────────────────────
  List<PrayerRequest> getPrayerRequests() {
    final now = DateTime.now();
    return [
      PrayerRequest(
        id: 'prayer-1',
        title: 'Healing Prayer',
        memberName: 'Gloria Adarquah-Yiadom',
        request: 'Please pray for healing and restoration in my body. '
            'Trusting God for complete healing.',
        category: 'Health',
        status: 'Open',
        date: now.subtract(const Duration(days: 5)),
        isPrivate: false,
        responses: 5,
      ),
      PrayerRequest(
        id: 'prayer-2',
        title: 'Job Search',
        memberName: 'Jasper D.',
        request:
            'Seeking God\'s guidance in finding new employment opportunities. '
            'Believing for open doors.',
        category: 'Career',
        status: 'Open',
        date: now.subtract(const Duration(days: 4)),
        isPrivate: false,
        responses: 3,
      ),
      PrayerRequest(
        id: 'prayer-3',
        title: 'Family Restoration',
        memberName: 'Deaconess Esinam Segoh',
        request: 'Praying for God\'s intervention and restoration in family matters.',
        category: 'Family',
        status: 'Answered',
        date: now.subtract(const Duration(days: 10)),
        isPrivate: false,
        responses: 8,
      ),
      PrayerRequest(
        id: 'prayer-4',
        title: 'Financial Breakthrough',
        memberName: 'Enam Egyir',
        request: 'Trusting God for provision during this season. '
            'Believing for financial breakthrough.',
        category: 'Financial',
        status: 'Open',
        date: now.subtract(const Duration(days: 3)),
        isPrivate: false,
        responses: 2,
      ),
      PrayerRequest(
        id: 'prayer-5',
        title: 'Church Growth',
        memberName: 'Rev. Ebenezer Adarquah-Yiadom',
        request:
            'Pray for the growth of Faith Klinik Ministries in Columbus. '
            'That souls will be saved and lives transformed.',
        category: 'General',
        status: 'Open',
        date: now.subtract(const Duration(days: 1)),
        isPrivate: false,
        responses: 12,
      ),
    ];
  }

  // ─────────────────────────────────────────────────────
  // KIDS – GAMES
  // ─────────────────────────────────────────────────────
  List<ChildGame> getGames() => [
        const ChildGame(
          id: 'game-1',
          title: 'Bible Memory Verse Game',
          description:
              'Learn Bible memory verses through fun matching activities! '
              'Perfect for building scripture knowledge.',
          difficulty: 'Easy',
          completed: false,
        ),
        const ChildGame(
          id: 'game-2',
          title: "Noah's Ark Animals",
          description:
              "Help Noah collect all the animals two by two! "
              "Learn about God's faithfulness to Noah.",
          difficulty: 'Easy',
          completed: false,
        ),
        const ChildGame(
          id: 'game-3',
          title: 'David and Goliath Adventure',
          description:
              'Experience the epic Bible story of young David defeating the giant Goliath '
              'with God\'s help!',
          difficulty: 'Medium',
          completed: false,
        ),
        const ChildGame(
          id: 'game-4',
          title: 'Bible Trivia Challenge',
          description:
              'Test your Bible knowledge with fun trivia questions! '
              'Earn stars for every correct answer.',
          difficulty: 'Hard',
          completed: false,
        ),
        const ChildGame(
          id: 'game-5',
          title: 'Fruit of the Spirit Matching',
          description:
              'Match the fruits of the Spirit — love, joy, peace, patience, kindness — '
              'with their meanings from Galatians 5:22!',
          difficulty: 'Easy',
          completed: false,
        ),
        const ChildGame(
          id: 'game-6',
          title: 'Build the Temple Puzzle',
          description:
              'Help King Solomon build the temple! '
              'Put the pieces together and learn about God\'s house.',
          difficulty: 'Medium',
          completed: false,
        ),
      ];

  // ─────────────────────────────────────────────────────
  // KIDS – LESSONS
  // ─────────────────────────────────────────────────────
  List<ChildLesson> getLessons() => [
        const ChildLesson(
          id: 'lesson-1',
          title: 'Jesus Loves Me',
          content:
              'Did you know that Jesus loves you so much? John 3:16 says God loved the world '
              'so much that He gave His only Son. You are so special to Jesus! '
              'Draw a picture of what God\'s love means to you.',
          duration: '10 min',
          ageRange: '3–6',
          completed: false,
        ),
        const ChildLesson(
          id: 'lesson-2',
          title: 'The Good Samaritan',
          content:
              'Jesus told a story about a man who was hurt on the road. '
              'Many people walked past, but one kind man — the Good Samaritan — stopped to help. '
              'Jesus says: love your neighbour as yourself (Luke 10:27). '
              'Who can you show kindness to today?',
          duration: '15 min',
          ageRange: '6–10',
          completed: false,
        ),
        const ChildLesson(
          id: 'lesson-3',
          title: 'The Creation Story',
          content:
              'In the beginning, God created the heavens and the earth (Genesis 1:1)! '
              'In 6 days God made light, sky, land, plants, sun & moon, animals, and people. '
              'On the 7th day He rested. Everything God made is GOOD!',
          duration: '12 min',
          ageRange: '4–8',
          completed: false,
        ),
        const ChildLesson(
          id: 'lesson-4',
          title: 'Daniel and the Lions',
          content:
              'Daniel loved God so much that he prayed three times every day. '
              'When he was thrown into the lions\' den, God sent an angel to protect him! '
              'Daniel 6:22 — "My God sent his angel and shut the mouths of the lions." '
              'Being brave with God\'s help!',
          duration: '18 min',
          ageRange: '7–12',
          completed: false,
        ),
        const ChildLesson(
          id: 'lesson-5',
          title: 'Jonah and the Big Fish',
          content:
              'God asked Jonah to go to Nineveh, but Jonah ran away! God sent a big storm '
              'and a huge fish swallowed Jonah. Inside the fish, Jonah prayed and said sorry. '
              'The fish spat him out and Jonah obeyed God. Obeying God is always the right choice!',
          duration: '14 min',
          ageRange: '5–9',
          completed: false,
        ),
        const ChildLesson(
          id: 'lesson-6',
          title: "The Lord's Prayer",
          content:
              'Jesus taught His disciples how to pray in Matthew 6:9-13. '
              '"Our Father in heaven, hallowed be your name, your kingdom come, '
              'your will be done on earth as in heaven." '
              'Let\'s learn this prayer together and talk to God every day!',
          duration: '10 min',
          ageRange: '5–10',
          completed: false,
        ),
      ];

  // ─────────────────────────────────────────────────────
  // KIDS – SERMONS / VIDEOS
  // ─────────────────────────────────────────────────────
  List<ChildSermon> getSermons() {
    final now = DateTime.now();
    return [
      ChildSermon(
        id: 'sermon-1',
        title: "God's Love is Bigger Than...",
        speaker: 'Pastor Children – Faith Klinik',
        date: now.subtract(const Duration(days: 7)),
        duration: '15:00',
        views: 45,
        videoUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
      ChildSermon(
        id: 'sermon-2',
        title: 'Be Kind Like Jesus',
        speaker: 'Rev. Lucie Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 14)),
        duration: '12:30',
        views: 38,
        videoUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
      ChildSermon(
        id: 'sermon-3',
        title: 'Prayer Warriors for Children',
        speaker: 'Pastor Children – Faith Klinik',
        date: now.subtract(const Duration(days: 21)),
        duration: '14:45',
        views: 52,
        videoUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
      ChildSermon(
        id: 'sermon-4',
        title: 'Bible Heroes Adventure',
        speaker: 'Jeshurun Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 28)),
        duration: '16:20',
        views: 41,
        videoUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
      ChildSermon(
        id: 'sermon-5',
        title: 'The Armour of God',
        speaker: 'Rev. Lucie Adarquah-Yiadom',
        date: now.subtract(const Duration(days: 35)),
        duration: '13:00',
        views: 33,
        videoUrl: 'https://www.youtube.com/@FaithKlinikMinistries',
      ),
    ];
  }

  // ─────────────────────────────────────────────────────
  // CHURCH GROUPS / MINISTRIES (all 13)
  // ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> getGroups() => [
    {
      'id': 'grp-1', 'name': 'Leadership Team',
      'description': 'The governing leadership of Faith Klinik Ministries. Provides vision, direction, and spiritual oversight for all ministries and church operations.',
      'leaders': ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom'],
      'members': ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Tuesday', 'meeting_time': '7:00 PM', 'location': 'Pastor\'s Office',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMLeadership',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Leadership team meets weekly to review ministry operations, approve budgets, and set church-wide direction.',
    },
    {
      'id': 'grp-2', 'name': 'Youth Ministry',
      'description': 'Engaging and discipling the next generation in their faith journey. Weekly youth services every Saturday at 4 PM, camps, and mentorship.',
      'leaders': ['Jeshurun Adarquah-Yiadom'],
      'members': ['Jeshurun Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Saturday', 'meeting_time': '4:00 PM', 'location': 'Youth Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMYouth',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Youth meet every Saturday. All youth 13–25 welcome. Attendance required for ministry involvement.',
    },
    {
      'id': 'grp-3', 'name': 'Faith Klinik Dance Ministers',
      'description': 'Expressing worship through dance and movement. We minister during Sunday services, special programs, and outreach events.',
      'leaders': ['Enam Egyir'],
      'members': ['Enam Egyir', 'Eyram Kwauvi', 'Edem Kwauvi'],
      'pending_members': <String>[],
      'meeting_day': 'Saturday', 'meeting_time': '10:00 AM', 'location': 'Main Sanctuary',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMDance',
      'google_meet_link': '', 'dues': 10.0, 'dues_period': 'monthly',
      'bylaws': 'Members must attend rehearsal weekly. Costumes provided by ministry. Monthly dues cover costume maintenance and ministry supplies.',
    },
    {
      'id': 'grp-4', 'name': 'League of Anointed Ministers',
      'description': 'Leading the congregation in worship through music and praise. We seek God\'s presence through anointed songs and instruments.',
      'leaders': ['Jedidiah Adarquah-Yiadom'],
      'members': ['Jedidiah Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Thursday', 'meeting_time': '7:00 PM', 'location': 'Music Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMWorship',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Worship team rehearses every Thursday. Sunday sound check at 8:30 AM. All musicians must be active church members.',
    },
    {
      'id': 'grp-5', 'name': 'Food Pantry Ministry',
      'description': 'Providing food assistance to families in need in Columbus. We serve over 100 families monthly and accept donations every Wednesday.',
      'leaders': ['Deaconess Esinam Segoh'],
      'members': ['Deaconess Esinam Segoh'],
      'pending_members': <String>[],
      'meeting_day': 'Wednesday', 'meeting_time': '6:00 PM', 'location': 'Fellowship Hall',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMFoodPantry',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'All volunteers must complete orientation. Food distributions occur every 2nd Saturday. Donations accepted Wednesday evenings.',
    },
    {
      'id': 'grp-6', 'name': 'Media Ministry',
      'description': 'Managing audio, video, live streaming, and digital media for all services. We ensure the Gospel reaches the world through technology.',
      'leaders': ['Jasper D.'],
      'members': ['Jasper D.'],
      'pending_members': <String>[],
      'meeting_day': 'Second Saturday', 'meeting_time': '2:00 PM', 'location': 'Media Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMMedia',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Media team arrives 1 hour before every service. Equipment training required. Sunday livestream is mandatory coverage.',
    },
    {
      'id': 'grp-7', 'name': 'Prayer Ministry',
      'description': 'Coordinating prayer and intercession for the church and community. Daily Zoom prayers Mon–Thu 8–9 PM. Bible Study Fridays 8–9:30 PM.',
      'leaders': ['Gloria Adarquah-Yiadom'],
      'members': ['Rev. Ebenezer Adarquah-Yiadom', 'Rev. Lucie Adarquah-Yiadom', 'Gloria Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Daily (Mon–Fri)', 'meeting_time': '8:00 PM', 'location': 'Zoom ID: 619 342 2249',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMPrayer',
      'google_meet_link': 'https://zoom.us/j/6193422249', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Prayer line open Mon–Thu 8–9 PM. Friday Bible Study 8–9:30 PM. All members encouraged to join at least twice weekly.',
    },
    {
      'id': 'grp-8', 'name': 'Women\'s Ministry',
      'description': 'Fellowship and growth for women of faith. Monthly meetings, conferences, and community outreach for women of all ages.',
      'leaders': ['Rev. Lucie Adarquah-Yiadom'],
      'members': ['Rev. Lucie Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Second Saturday', 'meeting_time': '10:00 AM', 'location': 'Conference Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMWomen',
      'google_meet_link': '', 'dues': 5.0, 'dues_period': 'monthly',
      'bylaws': 'Open to all women 18+. Monthly dues support conference and outreach activities. Annual women\'s retreat each spring.',
    },
    {
      'id': 'grp-9', 'name': 'Men\'s Ministry',
      'description': 'Building strong men of faith and character. Monthly breakfasts, accountability groups, and community service projects.',
      'leaders': ['Rev. Ebenezer Adarquah-Yiadom'],
      'members': ['Rev. Ebenezer Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'First Saturday', 'meeting_time': '8:00 AM', 'location': 'Fellowship Hall',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMMen',
      'google_meet_link': '', 'dues': 5.0, 'dues_period': 'monthly',
      'bylaws': 'Open to all men 18+. Monthly breakfast on 1st Saturday. Dues support community outreach and annual men\'s retreat.',
    },
    {
      'id': 'grp-10', 'name': 'Ushering Department',
      'description': 'Welcoming and serving church attendees with excellence and hospitality. Training every third Sunday for all new ushers.',
      'leaders': ['Deaconess Esinam Segoh'],
      'members': ['Deaconess Esinam Segoh'],
      'pending_members': <String>[],
      'meeting_day': 'Third Sunday', 'meeting_time': '12:00 PM', 'location': 'Main Sanctuary',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMUshers',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Ushers report 30 min before service. Uniform required (white top, dark bottom). Annual budget covers uniforms and training materials.',
    },
    {
      'id': 'grp-11', 'name': 'Children\'s Ministry',
      'description': 'Teaching children about Jesus in fun, engaging ways. Sunday children church, Bible lessons, games, and special events.',
      'leaders': ['Rev. Lucie Adarquah-Yiadom'],
      'members': ['Rev. Lucie Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Sunday', 'meeting_time': '10:00 AM', 'location': 'Children Church Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMChildren',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'All children\'s workers must complete a background check. Two adults must be present at all times with children.',
    },
    {
      'id': 'grp-12', 'name': 'Evangelism Committee',
      'description': 'Reaching the lost with the Gospel in Columbus and beyond. Faith Klinik is a missions-minded church supporting local and world evangelism.',
      'leaders': ['Rev. Lucie Adarquah-Yiadom'],
      'members': ['Rev. Lucie Adarquah-Yiadom', 'Rev. Ebenezer Adarquah-Yiadom'],
      'pending_members': <String>[],
      'meeting_day': 'Thursday', 'meeting_time': '7:00 PM', 'location': 'Fellowship Hall',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMEvangelism',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Committee plans quarterly outreach events. All members are encouraged to participate in at least one outreach per quarter.',
    },
    {
      'id': 'grp-13', 'name': 'Welfare Committee',
      'description': 'Supporting members and community in times of need — hospital visits, bereavement support, financial assistance referrals, and care packages.',
      'leaders': ['Hagar Abonjour'],
      'members': ['Hagar Abonjour'],
      'pending_members': <String>[],
      'meeting_day': 'Second Sunday', 'meeting_time': '1:00 PM', 'location': 'Conference Room',
      'whatsapp_group': 'https://chat.whatsapp.com/FKMWelfare',
      'google_meet_link': '', 'dues': 0.0, 'dues_period': 'monthly',
      'bylaws': 'Welfare requests handled confidentially. Committee meets monthly to review needs. Members must maintain strict confidentiality.',
    },
  ];
}
