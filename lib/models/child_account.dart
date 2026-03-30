import 'package:uuid/uuid.dart';

class ChildAccount {
  final String id;
  final String parentUserId; // The Supabase user ID of the parent
  final String accountName; // e.g. "Emma", "Junior"
  final String pin; // 4-digit PIN unique to this child
  final String? avatarUrl;
  final DateTime createdAt;
  final int ageYears; // optional, 0 = not set

  const ChildAccount({
    required this.id,
    required this.parentUserId,
    required this.accountName,
    required this.pin,
    this.avatarUrl,
    required this.createdAt,
    this.ageYears = 0,
  });

  factory ChildAccount.create({
    required String parentUserId,
    required String accountName,
    required String pin,
    int ageYears = 0,
  }) {
    return ChildAccount(
      id: const Uuid().v4(),
      parentUserId: parentUserId,
      accountName: accountName,
      pin: pin,
      createdAt: DateTime.now(),
      ageYears: ageYears,
    );
  }

  factory ChildAccount.fromJson(Map<String, dynamic> json) {
    return ChildAccount(
      id: json['id'] as String,
      parentUserId: json['parent_user_id'] as String? ?? '',
      accountName: json['account_name'] as String,
      pin: json['pin'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      ageYears: json['age_years'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_user_id': parentUserId,
      'account_name': accountName,
      'pin': pin,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'age_years': ageYears,
    };
  }

  ChildAccount copyWith({
    String? accountName,
    String? pin,
    String? avatarUrl,
    int? ageYears,
  }) {
    return ChildAccount(
      id: id,
      parentUserId: parentUserId,
      accountName: accountName ?? this.accountName,
      pin: pin ?? this.pin,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      ageYears: ageYears ?? this.ageYears,
    );
  }
}
