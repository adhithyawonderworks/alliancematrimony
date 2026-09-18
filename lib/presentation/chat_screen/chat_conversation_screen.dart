import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/supabase_service.dart';
import '../../widgets/report_user_bottom_sheet.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  /// The other participant's user_id — used to create/fetch the Supabase conversation
  final String? otherUserId;

  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    this.otherUserId,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabase = SupabaseService.instance;

  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _supabaseConversationId;
  dynamic _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    String? convId;

    // If we have a real Supabase conversation id (UUID format), use it directly
    if (widget.otherUserId != null) {
      convId = await _supabase.getOrCreateConversation(widget.otherUserId!);
    } else if (_isUuid(widget.conversationId)) {
      convId = widget.conversationId;
    }

    if (convId != null) {
      _supabaseConversationId = convId;
      await _loadMessages(convId);
      _subscribeToMessages(convId);
    } else {
      // Fallback: no Supabase conversation, just show empty state
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isUuid(String s) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(s);
  }

  Future<void> _loadMessages(String convId) async {
    final raw = await _supabase.fetchMessages(convId);
    final currentUid = _supabase.currentUserId;
    final msgs = raw.map((m) {
      final dt = DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now();
      return ChatMessage(
        id: m['id'] as String,
        text: m['content'] as String,
        isMe: m['sender_id'] == currentUid,
        time: _formatTime(dt),
      );
    }).toList();

    if (mounted) {
      setState(() {
        _messages
          ..clear()
          ..addAll(msgs);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _subscribeToMessages(String convId) {
    _messageSubscription = _supabase.subscribeToMessages(
      conversationId: convId,
      onNewMessage: (msg) {
        final currentUid = _supabase.currentUserId;
        // Avoid duplicating messages we sent ourselves (already added optimistically)
        if (msg['sender_id'] == currentUid) return;
        final dt = DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now();
        final chatMsg = ChatMessage(
          id: msg['id'] as String,
          text: msg['content'] as String,
          isMe: false,
          time: _formatTime(dt),
        );
        if (mounted) {
          setState(() => _messages.add(chatMsg));
          _scrollToBottom();
        }
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();

    // Optimistic UI update
    final optimisticMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isMe: true,
      time: _formatTime(DateTime.now()),
    );
    setState(() {
      _messages.add(optimisticMsg);
      _isSending = true;
    });
    _scrollToBottom();

    if (_supabaseConversationId != null) {
      await _supabase.sendMessage(
        conversationId: _supabaseConversationId!,
        content: text,
      );
    }

    if (mounted) setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E1520),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Color(0xFFEEE0F0),
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.avatarUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 36,
                    height: 36,
                    color: const Color(0xFF2A1E2E),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: const Color(0xFF2A1E2E),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: Color(0xFF6B5870),
                    ),
                  ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E1520),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              Text(
                widget.isOnline ? 'Online' : 'Last seen recently',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: widget.isOnline
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFF6B5870),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9A8A9E)),
          color: const Color(0xFF1E1520),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) async {
            if (value == 'copy') {
              await Clipboard.setData(ClipboardData(text: widget.name));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Match name copied.',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                  ),
                  backgroundColor: Color(0xFF2D7A4F),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            if (value == 'report' && widget.otherUserId != null) {
              await ReportUserBottomSheet.show(
                context,
                reportedUserId: widget.otherUserId!,
                reportedUserName: widget.name,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, size: 18, color: Color(0xFFEEE0F0)),
                  SizedBox(width: 10),
                  Text(
                    'Copy name',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFFEEE0F0),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.otherUserId != null)
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: Color(0xFFC8556A)),
                    SizedBox(width: 10),
                    Text(
                      'Report user',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFFEEE0F0),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0x1AFFFFFF)),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC8556A)),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Color(0xFF3A2E40),
            ),
            const SizedBox(height: 12),
            Text(
              'Say hello to ${widget.name}!',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Color(0xFF6B5870),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _MessageBubble(message: msg);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1520),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x33FFFFFF), width: 1),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: Color(0xFFEEE0F0),
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: Color(0xFF6B5870),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFC8556A),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFFC8556A)
                    : const Color(0xFF2A1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 18),
                ),
                border: message.isMe
                    ? null
                    : Border.all(color: const Color(0x1AFFFFFF), width: 1),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: message.isMe ? Colors.white : const Color(0xFFEEE0F0),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.time,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                color: Color(0xFF6B5870),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
