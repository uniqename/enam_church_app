#!/usr/bin/env python3
import os

# Create all model, provider, and utility files for Faith Klinik app

files = {
    'lib/utils/colors.dart': '''import 'package:flutter/material.dart';

class AppColors {
  // Church brand colors
  static const Color brown = Color(0xFF8B4513);
  static const Color gold = Color(0xFFD4AF37);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Kids colors
  static const Color kidsGreen = Color(0xFF4CAF50);
  static const Color kidsBlue = Color(0xFF2196F3);
  static const Color kidsPurple = Color(0xFF9C27B0);
  static const Color kidsOrange = Color(0xFFFF9800);
  static const Color kidsYellow = Color(0xFFFFC107);
  static const Color kidsPink = Color(0xFFE91E63);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brown, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kidsGradient = LinearGradient(
    colors: [kidsGreen, kidsBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
''',

    'lib/models/user.dart': '''class User {
  final int id;
  final String username;
  final String password;
  final String role;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? parent;
  final int? age;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.parent,
    this.age,
  });
}
''',

    'lib/models/member.dart': '''class Member {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String joinDate;
  final String status;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.status,
  });
}
''',

    'lib/models/event.dart': '''class Event {
  final int id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String type;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    required this.status,
  });
}
''',

    'lib/models/finance.dart': '''class Finance {
  final int id;
  final String type;
  final double amount;
  final String member;
  final String date;
  final String method;
  final String status;

  Finance({
    required this.id,
    required this.type,
    required this.amount,
    required this.member,
    required this.date,
    required this.method,
    required this.status,
  });
}
''',

    'lib/models/prayer_request.dart': '''class PrayerRequest {
  final int id;
  final String title;
  final String member;
  final String request;
  final String category;
  final String status;
  final String date;
  final bool private;
  final int responses;

  PrayerRequest({
    required this.id,
    required this.title,
    required this.member,
    required this.request,
    required this.category,
    required this.status,
    required this.date,
    required this.private,
    required this.responses,
  });
}
''',

    'lib/models/message.dart': '''class Message {
  final int id;
  final String sender;
  final String recipient;
  final String subject;
  final String content;
  final String date;
  final bool read;
  final String priority;

  Message({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.subject,
    required this.content,
    required this.date,
    required this.read,
    required this.priority,
  });
}
''',

    'lib/models/stream.dart': '''class LiveStream {
  final int id;
  final String title;
  final String date;
  final String time;
  final String status;
  final int viewers;
  final String category;

  LiveStream({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.viewers,
    required this.category,
  });
}
''',

    'lib/models/announcement.dart': '''class Announcement {
  final int id;
  final String title;
  final String content;
  final String priority;
  final String author;
  final String date;
  final String department;
  final String status;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.author,
    required this.date,
    required this.department,
    required this.status,
  });
}
''',

    'lib/models/department.dart': '''class Department {
  final int id;
  final String name;
  final String head;
  final List<String> members;
  final String whatsappGroup;
  final String slackChannel;

  Department({
    required this.id,
    required this.name,
    required this.head,
    required this.members,
    required this.whatsappGroup,
    required this.slackChannel,
  });
}
''',

    'lib/models/ministry.dart': '''class Ministry {
  final int id;
  final String name;
  final String description;
  final String leader;
  final String meetingDay;
  final String meetingTime;
  final String location;

  Ministry({
    required this.id,
    required this.name,
    required this.description,
    required this.leader,
    required this.meetingDay,
    required this.meetingTime,
    required this.location,
  });
}
''',

    'lib/models/kids_game.dart': '''class KidsGame {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  bool completed;

  KidsGame({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.completed = false,
  });
}
''',

    'lib/models/kids_lesson.dart': '''class KidsLesson {
  final int id;
  final String title;
  final String content;
  final String duration;
  final String age;
  bool completed;

  KidsLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    required this.age,
    this.completed = false,
  });
}
''',

    'lib/models/kids_sermon.dart': '''class KidsSermon {
  final int id;
  final String title;
  final String speaker;
  final String date;
  final String duration;
  final int views;

  KidsSermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    required this.duration,
    required this.views,
  });
}
''',

    'lib/models/giving_option.dart': '''class GivingOption {
  final int id;
  final String type;
  final String description;
  final List<int> suggested;
  final String frequency;

  GivingOption({
    required this.id,
    required this.type,
    required this.description,
    required this.suggested,
    required this.frequency,
  });
}
''',

    'lib/models/bible_app.dart': '''class BibleApp {
  final int id;
  final String name;
  final String description;
  final String url;
  final String category;

  BibleApp({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.category,
  });
}
''',

    'lib/models/notification.dart': '''class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  bool read;
  final String date;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.date,
  });
}
''',
}

# Create files
for filepath, content in files.items():
    full_path = filepath
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content)
    print(f"Created: {filepath}")

print("\\nAll model and utility files created successfully!")
