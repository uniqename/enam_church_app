import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum GroupType { department, ministry }

class JoinRequest {
  final String id;
  final String userId;
  final String userName;
  final String groupId;
  final String groupName;
  final GroupType groupType;
  final String message;
  final String status; // pending, approved, rejected
  final DateTime submittedAt;

  const JoinRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.groupType,
    required this.message,
    required this.status,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'group_id': groupId,
        'group_name': groupName,
        'group_type': groupType.name,
        'message': message,
        'status': status,
        'submitted_at': submittedAt.toIso8601String(),
      };

  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String? ?? 'Member',
        groupId: json['group_id'] as String,
        groupName: json['group_name'] as String,
        groupType: GroupType.values.firstWhere(
          (t) => t.name == json['group_type'],
          orElse: () => GroupType.department,
        ),
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        submittedAt: DateTime.parse(json['submitted_at'] as String),
      );
}

class JoinRequestService {
  static final JoinRequestService _instance = JoinRequestService._internal();
  factory JoinRequestService() => _instance;
  JoinRequestService._internal();

  static const String _key = 'local_join_requests';
  final _uuid = const Uuid();

  Future<List<JoinRequest>> _getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JoinRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<JoinRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(requests.map((r) => r.toJson()).toList()));
  }

  Future<bool> hasUserRequested(String userId, String groupId) async {
    final all = await _getAll();
    return all.any((r) =>
        r.userId == userId &&
        r.groupId == groupId &&
        r.status == 'pending');
  }

  Future<bool> isUserMember(String userId, String userName, String groupId,
      List<String> groupMembers) async {
    return groupMembers
        .any((m) => m.toLowerCase() == userName.toLowerCase());
  }

  Future<void> submitRequest({
    required String userId,
    required String userName,
    required String groupId,
    required String groupName,
    required GroupType groupType,
    required String message,
  }) async {
    final all = await _getAll();
    all.removeWhere(
        (r) => r.userId == userId && r.groupId == groupId && r.status == 'pending');
    all.add(JoinRequest(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      groupId: groupId,
      groupName: groupName,
      groupType: groupType,
      message: message,
      status: 'pending',
      submittedAt: DateTime.now(),
    ));
    await _saveAll(all);
  }

  Future<List<JoinRequest>> getPendingForGroup(String groupId) async {
    final all = await _getAll();
    return all.where((r) => r.groupId == groupId && r.status == 'pending').toList();
  }

  Future<List<JoinRequest>> getAllPending() async {
    final all = await _getAll();
    return all.where((r) => r.status == 'pending').toList();
  }

  Future<void> reviewRequest(String requestId, bool approved) async {
    final all = await _getAll();
    final idx = all.indexWhere((r) => r.id == requestId);
    if (idx < 0) return;
    final r = all[idx];
    all[idx] = JoinRequest(
      id: r.id,
      userId: r.userId,
      userName: r.userName,
      groupId: r.groupId,
      groupName: r.groupName,
      groupType: r.groupType,
      message: r.message,
      status: approved ? 'approved' : 'rejected',
      submittedAt: r.submittedAt,
    );
    await _saveAll(all);
  }
}


<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>
