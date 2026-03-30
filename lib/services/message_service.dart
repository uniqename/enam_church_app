import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import 'supabase_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final _supabase = SupabaseService();
  final _uuid = const Uuid();

  static const String _localKey = 'local_messages';

  // ── Church groups available for group messaging ──────────────────────────
  static const List<String> churchGroups = [
    'Youth Ministry',
    'Men\'s Fellowship',
    'Women\'s Fellowship',
    'Prayer Team',
    'Media Team',
    'Ushers & Greeters',
    'Children\'s Ministry',
    'Worship Team',
    'Community Outreach',
    'Leadership Team',
  ];

  // ── Local storage helpers ─────────────────────────────────────────────────
  Future<List<Message>> _getLocalMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Message.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocalMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(messages.map((m) => m.toSupabase()).toList()),
    );
  }

  Future<List<Message>> _fetchAll() async {
    if (SupabaseService.isConfigured) {
      try {
        final data = await _supabase.query(
          'messages',
          orderBy: 'date',
          ascending: false,
        );
        if (data.isNotEmpty) {
          return data.map((json) => Message.fromSupabase(json)).toList();
        }
      } catch (e) {
        print('⚠️ Supabase unavailable, using local messages: $e');
      }
    }
    final local = await _getLocalMessages();
    local.sort((a, b) => b.date.compareTo(a.date));
    return local;
  }

  Future<void> _persistMessage(Message message) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.insert('messages', message.toSupabase());
        return;
      } catch (e) {
        print('⚠️ Supabase send failed, saving locally: $e');
      }
    }
    final local = await _getLocalMessages();
    local.insert(0, message);
    await _saveLocalMessages(local);
  }

  // ── Read methods ─────────────────────────────────────────────────────────

  /// All broadcast messages (recipientId == 'all')
  Future<List<Message>> getBroadcastMessages() async {
    final all = await _fetchAll();
    return all.where((m) => m.isBroadcast).toList();
  }

  /// Private DM thread between two users (messages sent by either party)
  Future<List<Message>> getDirectMessages(String currentUserId) async {
    final all = await _fetchAll();
    return all
        .where((m) =>
            m.isDirect &&
            (m.senderId == currentUserId || m.recipientId == currentUserId))
        .toList();
  }

  /// Conversation thread between currentUser and one specific partner
  Future<List<Message>> getConversation(
      String currentUserId, String partnerId) async {
    final all = await _fetchAll();
    return all
        .where((m) =>
            m.isDirect &&
            ((m.senderId == currentUserId && m.recipientId == partnerId) ||
                (m.senderId == partnerId && m.recipientId == currentUserId)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns unique conversation partners for a user (for DM list)
  Future<List<_ConversationSummary>> getConversationList(
      String currentUserId) async {
    final messages = await getDirectMessages(currentUserId);
    final Map<String, _ConversationSummary> map = {};

    for (final m in messages) {
      final partnerId =
          m.senderId == currentUserId ? m.recipientId : m.senderId;
      final partnerName =
          m.senderId == currentUserId ? m.recipientName : m.senderName;
      final isUnread = !m.read && m.recipientId == currentUserId;

      if (!map.containsKey(partnerId) ||
          m.date.isAfter(map[partnerId]!.lastMessage.date)) {
        map[partnerId] = _ConversationSummary(
          partnerId: partnerId,
          partnerName: partnerName.isEmpty ? 'Member' : partnerName,
          lastMessage: m,
          hasUnread: isUnread,
        );
      } else if (isUnread) {
        map[partnerId] = map[partnerId]!.withUnread();
      }
    }
    final list = map.values.toList()
      ..sort((a, b) =>
          b.lastMessage.date.compareTo(a.lastMessage.date));
    return list;
  }

  /// Group messages for a specific group
  Future<List<Message>> getGroupMessages(String groupName) async {
    final all = await _fetchAll();
    return all
        .where((m) => m.isGroup && m.groupName == groupName)
        .toList();
  }

  /// Leader-only messages
  Future<List<Message>> getLeaderMessages() async {
    final all = await _fetchAll();
    return all.where((m) => m.isLeaders).toList();
  }

  // ── Legacy: kept for backwards compatibility ─────────────────────────────
  Future<List<Message>> getAllMessages() => getBroadcastMessages();

  // ── Send methods ─────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String subject,
    required String content,
    String priority = 'Normal',
  }) async {
    await sendBroadcast(
      senderId: senderId,
      senderName: senderName,
      subject: subject,
      content: content,
      priority: priority,
    );
  }

  Future<void> sendBroadcast({
    required String senderId,
    required String senderName,
    required String subject,
    required String content,
    String priority = 'Normal',
  }) async {
    final message = Message(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      recipientId: 'all',
      subject: subject,
      content: content,
      date: DateTime.now(),
      read: false,
      priority: priority,
      messageType: 'broadcast',
    );
    await _persistMessage(message);
  }

  Future<void> sendDirectMessage({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String content,
    String priority = 'Normal',
  }) async {
    final message = Message(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      recipientName: recipientName,
      subject: 'Direct message',
      content: content,
      date: DateTime.now(),
      read: false,
      priority: priority,
      messageType: 'direct',
    );
    await _persistMessage(message);
  }

  Future<void> sendGroupMessage({
    required String senderId,
    required String senderName,
    required String groupName,
    required String subject,
    required String content,
    String priority = 'Normal',
  }) async {
    final message = Message(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      recipientId: 'group:$groupName',
      subject: subject,
      content: content,
      date: DateTime.now(),
      read: false,
      priority: priority,
      messageType: 'group',
    );
    await _persistMessage(message);
  }

  Future<void> sendLeaderMessage({
    required String senderId,
    required String senderName,
    required String subject,
    required String content,
    String priority = 'Normal',
  }) async {
    final message = Message(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      recipientId: 'leaders',
      subject: subject,
      content: content,
      date: DateTime.now(),
      read: false,
      priority: priority,
      messageType: 'leaders',
    );
    await _persistMessage(message);
  }

  // ── Mark as read ─────────────────────────────────────────────────────────

  Future<void> markAsRead(String messageId) async {
    if (SupabaseService.isConfigured) {
      try {
        await _supabase.update('messages', messageId, {'read': true});
        return;
      } catch (_) {}
    }
    final local = await _getLocalMessages();
    final idx = local.indexWhere((m) => m.id == messageId);
    if (idx >= 0) {
      local[idx] = local[idx].copyWith(read: true);
      await _saveLocalMessages(local);
    }
  }
}

class _ConversationSummary {
  final String partnerId;
  final String partnerName;
  final Message lastMessage;
  final bool hasUnread;

  const _ConversationSummary({
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.hasUnread,
  });

  _ConversationSummary withUnread() => _ConversationSummary(
        partnerId: partnerId,
        partnerName: partnerName,
        lastMessage: lastMessage,
        hasUnread: true,
      );
}
