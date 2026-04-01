import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../services/member_service.dart';
import '../../services/auth_service.dart';
import '../../models/member.dart';
import '../../utils/colors.dart';
import '../quiz/quiz_home_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  final _messageService = MessageService();
  final _authService = AuthService();

  late TabController _tabController;

  String? _userId;
  String? _userName;
  String? _userRole;
  bool _isLoading = true;

  // per-tab data
  List<Message> _broadcast = [];
  List<Message> _directMessages = [];
  List<Message> _leaderMessages = [];

  // Maps groupName → messages for group tab
  final Map<String, List<Message>> _groupMessages = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _authService.getCurrentUserId();
      final userName = await _authService.getCurrentUserName();
      final role = await _authService.getUserRole();

      final broadcast = await _messageService.getBroadcastMessages();
      final direct = userId != null
          ? await _messageService.getDirectMessages(userId)
          : <Message>[];
      final leaders = await _messageService.getLeaderMessages();

      final Map<String, List<Message>> groupMsgs = {};
      for (final g in MessageService.churchGroups) {
        final msgs = await _messageService.getGroupMessages(g);
        groupMsgs[g] = msgs;
      }

      if (mounted) {
        setState(() {
          _userId = userId;
          _userName = userName;
          _userRole = role;
          _broadcast = broadcast;
          _directMessages = direct;
          _leaderMessages = leaders;
          _groupMessages.addAll(groupMsgs);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  bool get _isLeader {
    final r = _userRole?.toLowerCase() ?? '';
    return r == 'admin' || r == 'pastor' || r == 'department_head';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communications'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: _unreadBroadcast > 0,
                label: Text('$_unreadBroadcast'),
                child: const Icon(Icons.campaign_outlined, size: 20),
              ),
              text: 'Broadcast',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: _unreadDirect > 0,
                label: Text('$_unreadDirect'),
                child: const Icon(Icons.chat_bubble_outline, size: 20),
              ),
              text: 'Direct',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: _unreadGroups > 0,
                label: Text('$_unreadGroups'),
                child: const Icon(Icons.group_outlined, size: 20),
              ),
              text: 'Groups',
            ),
            const Tab(
              icon: Icon(Icons.quiz_outlined, size: 20),
              text: 'Quiz',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BroadcastTab(
                  messages: _broadcast,
                  onRefresh: _loadAll,
                  onCompose: _composeBroadcast,
                  onMarkRead: _markRead,
                ),
                _DirectTab(
                  allMessages: _directMessages,
                  currentUserId: _userId ?? '',
                  currentUserName: _userName ?? 'Me',
                  onRefresh: _loadAll,
                  messageService: _messageService,
                ),
                _GroupsTab(
                  groupMessages: Map.from(_groupMessages),
                  currentUserId: _userId ?? '',
                  currentUserName: _userName ?? 'Me',
                  isLeader: _isLeader,
                  onRefresh: _loadAll,
                  messageService: _messageService,
                  leaderMessages: _leaderMessages,
                ),
                const QuizHomeScreen(),
              ],
            ),
      floatingActionButton: _buildFab(),
    );
  }

  int get _unreadBroadcast =>
      _broadcast.where((m) => !m.read).length;
  int get _unreadDirect =>
      _directMessages.where((m) => !m.read && m.recipientId == _userId).length;
  int get _unreadGroups {
    int count = 0;
    for (final msgs in _groupMessages.values) {
      count += msgs.where((m) => !m.read).length;
    }
    return count;
  }

  Widget? _buildFab() {
    final tab = _tabController.index;
    if (tab == 3) return null; // Quiz tab handles its own FAB
    if (tab == 0) {
      return FloatingActionButton.extended(
        onPressed: _composeBroadcast,
        backgroundColor: AppColors.accentPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign),
        label: const Text('Broadcast'),
      );
    }
    if (tab == 1) {
      return FloatingActionButton.extended(
        onPressed: _composeDirectMessage,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('New DM'),
      );
    }
    // Groups tab — no floating FAB, compose is per-group
    return null;
  }

  Future<void> _markRead(String messageId) async {
    await _messageService.markAsRead(messageId);
    _loadAll();
  }

  // ── Compose broadcast ─────────────────────────────────────────────────────
  void _composeBroadcast() {
    _showComposeSheet(
      title: 'Broadcast to All',
      titleIcon: Icons.campaign,
      titleColor: AppColors.purple,
      recipientLabel: 'To: All Members',
      showPriority: true,
      onSend: (subject, content, priority) async {
        await _messageService.sendBroadcast(
          senderId: _userId ?? 'anonymous',
          senderName: _userName ?? 'Member',
          subject: subject,
          content: content,
          priority: priority,
        );
      },
    );
  }

  // ── Compose DM ────────────────────────────────────────────────────────────
  void _composeDirectMessage() async {
    final members = await MemberService().getAllMembers();
    if (!mounted) return;
    final selected = await _showMemberPicker(members);
    if (selected == null || !mounted) return;

    _showComposeSheet(
      title: 'Direct Message',
      titleIcon: Icons.chat_bubble_outline,
      titleColor: const Color(0xFF1565C0),
      recipientLabel: 'To: ${selected.name}',
      showPriority: false,
      isChat: true,
      onSend: (subject, content, priority) async {
        await _messageService.sendDirectMessage(
          senderId: _userId ?? 'anonymous',
          senderName: _userName ?? 'Member',
          recipientId: selected.id,
          recipientName: selected.name,
          content: content,
          priority: priority,
        );
      },
    );
  }

  Future<Member?> _showMemberPicker(List<Member> members) async {
    final filtered = members
        .where((m) => m.id != _userId && m.status.toLowerCase() == 'active')
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return showModalBottomSheet<Member>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MemberPickerSheet(members: filtered),
    );
  }

  // ── Reusable compose sheet ────────────────────────────────────────────────
  void _showComposeSheet({
    required String title,
    required IconData titleIcon,
    required Color titleColor,
    required String recipientLabel,
    required Future<void> Function(String subject, String content, String priority) onSend,
    bool showPriority = true,
    bool isChat = false,
  }) {
    final subjectController = TextEditingController();
    final contentController = TextEditingController();
    String priority = 'Normal';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(titleIcon, color: titleColor),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                recipientLabel,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              if (!isChat) ...[
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon:
                        Icon(Icons.subject, color: titleColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: titleColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: contentController,
                maxLines: isChat ? 3 : 4,
                decoration: InputDecoration(
                  labelText: isChat ? 'Message' : 'Message body',
                  prefixIcon:
                      Icon(Icons.message, color: titleColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: titleColor, width: 2),
                  ),
                ),
              ),
              if (showPriority) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Normal', child: Text('Normal')),
                    DropdownMenuItem(
                        value: 'High', child: Text('High — Urgent')),
                  ],
                  onChanged: (v) =>
                      setSheet(() => priority = v ?? 'Normal'),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final subject = isChat
                        ? 'Direct message'
                        : subjectController.text.trim();
                    final content = contentController.text.trim();
                    if (content.isEmpty ||
                        (!isChat && subject.isEmpty)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Message is required')),
                      );
                      return;
                    }
                    final nav = Navigator.of(ctx);
                    final messenger =
                        ScaffoldMessenger.of(context);
                    try {
                      await onSend(subject, content, priority);
                      nav.pop();
                      await _loadAll();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Message sent!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Failed to send: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titleColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TAB 1: Broadcast
// ────────────────────────────────────────────────────────────────────────────

class _BroadcastTab extends StatelessWidget {
  final List<Message> messages;
  final VoidCallback onRefresh;
  final VoidCallback onCompose;
  final Future<void> Function(String) onMarkRead;

  const _BroadcastTab({
    required this.messages,
    required this.onRefresh,
    required this.onCompose,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyState(
        icon: Icons.campaign_outlined,
        message: 'No broadcasts yet',
        subtitle: 'Church-wide messages will appear here',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (ctx, i) => _MessageCard(
          message: messages[i],
          onTap: () => _showDetails(ctx, messages[i]),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Message message) {
    if (!message.read) onMarkRead(message.id);
    showDialog(
      context: context,
      builder: (_) => _MessageDetailDialog(message: message),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TAB 2: Direct Messages
// ────────────────────────────────────────────────────────────────────────────

class _DirectTab extends StatelessWidget {
  final List<Message> allMessages;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback onRefresh;
  final MessageService messageService;

  const _DirectTab({
    required this.allMessages,
    required this.currentUserId,
    required this.currentUserName,
    required this.onRefresh,
    required this.messageService,
  });

  @override
  Widget build(BuildContext context) {
    // Group into conversations
    final Map<String, List<Message>> convMap = {};
    for (final m in allMessages) {
      final key = m.senderId == currentUserId ? m.recipientId : m.senderId;
      convMap.putIfAbsent(key, () => []).add(m);
    }
    final conversations = convMap.entries.toList()
      ..sort((a, b) {
        final aLast = a.value.reduce(
            (x, y) => x.date.isAfter(y.date) ? x : y);
        final bLast = b.value.reduce(
            (x, y) => x.date.isAfter(y.date) ? x : y);
        return bLast.date.compareTo(aLast.date);
      });

    if (conversations.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline,
        message: 'No direct messages',
        subtitle: 'Tap "New DM" to message someone privately',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: conversations.length,
        itemBuilder: (ctx, i) {
          final entry = conversations[i];
          final msgs = entry.value..sort((a, b) => b.date.compareTo(a.date));
          final latest = msgs.first;
          final partnerId = entry.key;
          final partnerName = latest.senderId == currentUserId
              ? latest.recipientName
              : latest.senderName;
          final unread = msgs
              .where((m) => !m.read && m.recipientId == currentUserId)
              .length;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color(0xFF1565C0).withValues(alpha: 0.15),
                child: Text(
                  (partnerName.isEmpty ? '?' : partnerName[0])
                      .toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                partnerName.isEmpty ? 'Member' : partnerName,
                style: TextStyle(
                  fontWeight: unread > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                latest.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: unread > 0 ? Colors.black87 : Colors.grey,
                  fontWeight: unread > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmtDate(latest.date),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1565C0),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => _ConversationScreen(
                    partnerId: partnerId,
                    partnerName:
                        partnerName.isEmpty ? 'Member' : partnerName,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName,
                    messageService: messageService,
                    onMessageSent: onRefresh,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year &&
        d.month == now.month &&
        d.day == now.day) {
      return DateFormat('h:mm a').format(d);
    }
    return DateFormat('MMM d').format(d);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Conversation thread screen (used by Direct tab)
// ────────────────────────────────────────────────────────────────────────────

class _ConversationScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String currentUserId;
  final String currentUserName;
  final MessageService messageService;
  final VoidCallback onMessageSent;

  const _ConversationScreen({
    required this.partnerId,
    required this.partnerName,
    required this.currentUserId,
    required this.currentUserName,
    required this.messageService,
    required this.onMessageSent,
  });

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  List<Message> _messages = [];
  final _inputController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final msgs = await widget.messageService
        .getConversation(widget.currentUserId, widget.partnerId);
    // Mark all unread messages from partner as read
    for (final m in msgs) {
      if (!m.read && m.recipientId == widget.currentUserId) {
        widget.messageService.markAsRead(m.id);
      }
    }
    if (mounted) setState(() => _messages = msgs);
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.messageService.sendDirectMessage(
        senderId: widget.currentUserId,
        senderName: widget.currentUserName,
        recipientId: widget.partnerId,
        recipientName: widget.partnerName,
        content: text,
      );
      _inputController.clear();
      await _load();
      widget.onMessageSent();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text(
                widget.partnerName.isNotEmpty
                    ? widget.partnerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.partnerName),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Start a conversation with ${widget.partnerName}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isMe = m.senderId == widget.currentUserId;
                      return _ChatBubble(
                          message: m, isMe: isMe);
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: const Color(0xFF1565C0),
                        onPressed: _send,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF1565C0)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : null,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('h:mm a').format(message.date),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white60 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TAB 3: Groups
// ────────────────────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  final Map<String, List<Message>> groupMessages;
  final String currentUserId;
  final String currentUserName;
  final bool isLeader;
  final VoidCallback onRefresh;
  final MessageService messageService;
  final List<Message> leaderMessages;

  const _GroupsTab({
    required this.groupMessages,
    required this.currentUserId,
    required this.currentUserName,
    required this.isLeader,
    required this.onRefresh,
    required this.messageService,
    required this.leaderMessages,
  });

  static const _groupIcons = {
    'Youth Ministry': Icons.people,
    'Men\'s Fellowship': Icons.man,
    'Women\'s Fellowship': Icons.woman,
    'Prayer Team': Icons.favorite,
    'Media Team': Icons.videocam,
    'Ushers & Greeters': Icons.waving_hand,
    'Children\'s Ministry': Icons.child_care,
    'Worship Team': Icons.music_note,
    'Community Outreach': Icons.volunteer_activism,
    'Leadership Team': Icons.star,
  };

  static const _groupColors = {
    'Youth Ministry': Color(0xFF7B1FA2),
    'Men\'s Fellowship': Color(0xFF1565C0),
    'Women\'s Fellowship': Color(0xFFAD1457),
    'Prayer Team': Color(0xFFE53935),
    'Media Team': Color(0xFF00897B),
    'Ushers & Greeters': Color(0xFF2E7D32),
    'Children\'s Ministry': Color(0xFFE65100),
    'Worship Team': Color(0xFF6A1B9A),
    'Community Outreach': Color(0xFF00838F),
    'Leadership Team': Color(0xFFF57F17),
  };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Leaders section (visible to leaders only)
          if (isLeader) ...[
            _sectionHeader('Leadership Channel', Icons.star,
                const Color(0xFFF57F17)),
            const SizedBox(height: 6),
            _GroupChannelCard(
              name: 'Leadership Team',
              icon: Icons.star,
              color: const Color(0xFFF57F17),
              messageCount: leaderMessages.length,
              unreadCount: leaderMessages.where((m) => !m.read).length,
              latestMessage: leaderMessages.isNotEmpty
                  ? leaderMessages.first
                  : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _GroupChannelScreen(
                    groupName: 'Leadership Team',
                    color: const Color(0xFFF57F17),
                    icon: Icons.star,
                    messages: leaderMessages,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName,
                    messageService: messageService,
                    isLeaderChannel: true,
                    onMessageSent: onRefresh,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _sectionHeader(
              'Church Groups', Icons.group, AppColors.purple),
          const SizedBox(height: 6),
          ...MessageService.churchGroups
              .where((g) => g != 'Leadership Team')
              .map((g) {
            final msgs = groupMessages[g] ?? [];
            final unread = msgs.where((m) => !m.read).length;
            final icon = _groupIcons[g] ?? Icons.group;
            final color = _groupColors[g] ?? AppColors.purple;
            return _GroupChannelCard(
              name: g,
              icon: icon,
              color: color,
              messageCount: msgs.length,
              unreadCount: unread,
              latestMessage: msgs.isNotEmpty ? msgs.first : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _GroupChannelScreen(
                    groupName: g,
                    color: color,
                    icon: icon,
                    messages: msgs,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName,
                    messageService: messageService,
                    isLeaderChannel: false,
                    onMessageSent: onRefresh,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ],
    );
  }
}

class _GroupChannelCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int messageCount;
  final int unreadCount;
  final Message? latestMessage;
  final VoidCallback onTap;

  const _GroupChannelCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.messageCount,
    required this.unreadCount,
    required this.latestMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight:
                unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: latestMessage != null
            ? Text(
                latestMessage!.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: unreadCount > 0
                      ? Colors.black87
                      : Colors.grey,
                  fontWeight: unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              )
            : Text('$messageCount messages',
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
        trailing: unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// ── Group channel screen ──────────────────────────────────────────────────

class _GroupChannelScreen extends StatefulWidget {
  final String groupName;
  final Color color;
  final IconData icon;
  final List<Message> messages;
  final String currentUserId;
  final String currentUserName;
  final MessageService messageService;
  final bool isLeaderChannel;
  final VoidCallback onMessageSent;

  const _GroupChannelScreen({
    required this.groupName,
    required this.color,
    required this.icon,
    required this.messages,
    required this.currentUserId,
    required this.currentUserName,
    required this.messageService,
    required this.isLeaderChannel,
    required this.onMessageSent,
  });

  @override
  State<_GroupChannelScreen> createState() => _GroupChannelScreenState();
}

class _GroupChannelScreenState extends State<_GroupChannelScreen> {
  List<Message> _messages = [];
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final subject = _subjectController.text.trim();
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      if (widget.isLeaderChannel) {
        await widget.messageService.sendLeaderMessage(
          senderId: widget.currentUserId,
          senderName: widget.currentUserName,
          subject: subject.isEmpty ? 'Group message' : subject,
          content: content,
        );
      } else {
        await widget.messageService.sendGroupMessage(
          senderId: widget.currentUserId,
          senderName: widget.currentUserName,
          groupName: widget.groupName,
          subject: subject.isEmpty ? 'Group message' : subject,
          content: content,
        );
      }
      _subjectController.clear();
      _contentController.clear();
      // Refresh
      final updated = widget.isLeaderChannel
          ? await widget.messageService.getLeaderMessages()
          : await widget.messageService
              .getGroupMessages(widget.groupName);
      if (mounted) {
        setState(() {
          _messages = updated..sort((a, b) => a.date.compareTo(b.date));
        });
      }
      widget.onMessageSent();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, size: 20),
            const SizedBox(width: 8),
            Text(widget.groupName),
          ],
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon,
                            size: 48,
                            color: widget.color.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No messages in ${widget.groupName} yet',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _GroupMessageBubble(
                      message: _messages[i],
                      isMe: _messages[i].senderId ==
                          widget.currentUserId,
                      color: widget.color,
                    ),
                  ),
          ),
          // Compose bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:
                          'Message ${widget.groupName}...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: widget.color,
                        onPressed: _send,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Color color;

  const _GroupMessageBubble({
    required this.message,
    required this.isMe,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    message.senderName.isEmpty
                        ? 'Member'
                        : message.senderName,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? color
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        Radius.circular(isMe ? 16 : 4),
                    bottomRight:
                        Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.subject.isNotEmpty &&
                        message.subject != 'Group message') ...[
                      Text(
                        message.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe
                              ? Colors.white
                              : color,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : null,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(message.date),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white60
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ────────────────────────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const _MessageCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: message.read
                      ? Colors.grey.shade100
                      : AppColors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  message.read
                      ? Icons.mail_outline
                      : Icons.mail,
                  color: message.read
                      ? Colors.grey
                      : AppColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.subject,
                            style: TextStyle(
                              fontWeight: message.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (message.priority.toLowerCase() ==
                            'high')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Urgent',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    if (message.senderName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'From: ${message.senderName}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      message.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, y  h:mm a')
                          .format(message.date),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageDetailDialog extends StatelessWidget {
  final Message message;
  const _MessageDetailDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message.subject),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.senderName.isNotEmpty) ...[
              Text('From: ${message.senderName}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
            Text(message.content,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Sent: ${DateFormat('MMM d, y  h:mm a').format(message.date)}',
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey),
            ),
            if (message.priority.toLowerCase() == 'high') ...[
              const SizedBox(height: 4),
              const Text(
                'Priority: Urgent',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyState(
      {required this.icon,
      required this.message,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Member picker sheet ────────────────────────────────────────────────────

class _MemberPickerSheet extends StatefulWidget {
  final List<Member> members;
  const _MemberPickerSheet({required this.members});

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  final _searchController = TextEditingController();
  List<Member> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.members;
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        _filtered = widget.members
            .where((m) =>
                m.name.toLowerCase().contains(q) ||
                m.department.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                const Text('Select Recipient',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final m = _filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.purple.withValues(alpha: 0.15),
                    child: Text(
                      m.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(m.name),
                  subtitle: Text(m.department,
                      style: const TextStyle(fontSize: 12)),
                  onTap: () => Navigator.pop(context, m),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
