import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_localizations.dart';
import '../../services/supabase_service.dart';
import './chat_conversation_screen.dart';

class ChatConversation {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final String otherUserId;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.otherUserId,
  });
}

class ChatScreen extends StatefulWidget {
  final bool isPremium;
  const ChatScreen({super.key, this.isPremium = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  final AppLocalizations _localizations = AppLocalizations();

  List<ChatConversation> _conversations = [];
  bool _isLoading = true;
  bool _showSearchBar = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  dynamic _conversationSubscription;

  // Fallback preview conversations for non-premium blurred preview
  final List<ChatConversation> _previewConversations = const [
    ChatConversation(
      id: 'p1',
      name: 'Priya S.',
      avatarUrl:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      lastMessage: 'Hi! I saw your profile and would love to connect 😊',
      time: '2m ago',
      unreadCount: 2,
      isOnline: true,
      otherUserId: '',
    ),
    ChatConversation(
      id: 'p2',
      name: 'Ananya R.',
      avatarUrl:
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
      lastMessage: 'That sounds wonderful! Tell me more about yourself.',
      time: '1h ago',
      unreadCount: 0,
      isOnline: false,
      otherUserId: '',
    ),
    ChatConversation(
      id: 'p3',
      name: 'Kavitha M.',
      avatarUrl:
          'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
      lastMessage: 'Looking forward to our conversation!',
      time: '3h ago',
      unreadCount: 1,
      isOnline: true,
      otherUserId: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _localizations.addListener(_onLanguageChanged);
    if (widget.isPremium) {
      _loadConversations();
      _subscribeToConversations();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _localizations.removeListener(_onLanguageChanged);
    _conversationSubscription?.unsubscribe();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadConversations() async {
    final raw = await _supabase.fetchConversations();
    final convs = raw.map((c) {
      final lastMsgAt = c['last_message_at'] != null
          ? DateTime.tryParse(c['last_message_at'] as String)
          : null;
      return ChatConversation(
        id: c['id'] as String,
        name: (c['other_name'] as String?) ?? 'Unknown',
        avatarUrl: (c['other_avatar'] as String?) ?? '',
        lastMessage: (c['last_message'] as String?) ?? '',
        time: lastMsgAt != null ? _relativeTime(lastMsgAt) : '',
        unreadCount: 0,
        isOnline: false,
        otherUserId: (c['other_user_id'] as String?) ?? '',
      );
    }).toList();

    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoading = false;
      });
    }
  }

  void _subscribeToConversations() {
    _conversationSubscription = _supabase.subscribeToConversations(
      onUpdate: () {
        if (mounted) _loadConversations();
      },
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  List<ChatConversation> get _filteredConversations {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _conversations;

    return _conversations.where((conversation) {
      final haystack = [
        conversation.name,
        conversation.lastMessage,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      }
    });

    if (_showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: widget.isPremium
                      ? _buildConversationsList()
                      : _buildPremiumGate(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.8),
            radius: 1.2,
            colors: [Color(0xFF2A0D1A), Color(0xFF120D16)],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            _localizations.get('chat_title'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEE0F0),
            ),
          ),
          const Spacer(),
          if (widget.isPremium)
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                _showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
                color: const Color(0xFFEEE0F0),
                size: 22,
              ),
            ),
          if (widget.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3D22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: Color(0xFF4ADE80),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _localizations.get('premium_badge'),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC8556A)),
      );
    }

    final filtered = _filteredConversations;

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: Color(0xFF3A2E40),
            ),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start chatting with your matches\nfrom the Browse screen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF6B5870),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_showSearchBar)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1520),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33FFFFFF), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: Color(0xFFEEE0F0),
                ),
                decoration: InputDecoration(
                  hintText: 'Search chats by name or message',
                  hintStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: Color(0xFF9A8A9E),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFC8556A),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF9A8A9E),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFC8556A),
            backgroundColor: const Color(0xFF1E1520),
            onRefresh: _loadConversations,
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 52,
                          color: Color(0xFF3A2E40),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No chats match your search',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEE0F0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Text(
                            'Clear search',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFFC8556A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final conv = filtered[index];
                      return _ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    conversationId: conv.id,
                                    name: conv.name,
                                    avatarUrl: conv.avatarUrl,
                                    isOnline: conv.isOnline,
                                    otherUserId: conv.otherUserId,
                                  ),
                                ),
                              )
                              .then((_) => _loadConversations());
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumGate(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          _buildBlurredPreview(),
          const SizedBox(height: 24),
          _buildUnlockCard(context),
        ],
      ),
    );
  }

  Widget _buildBlurredPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Column(
            children: _previewConversations.map((conv) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1520),
                  border: Border(
                    bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2A1E2E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A2E40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 10,
                            width: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1E2E),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(color: const Color(0xFF120D16).withAlpha(120)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1520).withAlpha(191),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _localizations.get('unlock_chat'),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _localizations.get('chat_premium_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF9A8A9E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.alliancematrimony.online/features.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8556A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: conversation.unreadCount > 0
              ? const Color(0xFF1E1520)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: conversation.unreadCount > 0
              ? Border.all(color: const Color(0x1AFFFFFF), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: conversation.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: conversation.avatarUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 52,
                            height: 52,
                            color: const Color(0xFF2A1E2E),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            color: const Color(0xFF2A1E2E),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF6B5870),
                            ),
                          ),
                        )
                      : Container(
                          width: 52,
                          height: 52,
                          color: const Color(0xFF2A1E2E),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6B5870),
                          ),
                        ),
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF120D16),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
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
                          conversation.name,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xFFEEE0F0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: conversation.unreadCount > 0
                              ? const Color(0xFFC8556A)
                              : const Color(0xFF6B5870),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage.isNotEmpty
                              ? conversation.lastMessage
                              : 'Start a conversation',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: conversation.unreadCount > 0
                                ? const Color(0xFFCCBDD0)
                                : const Color(0xFF6B5870),
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8556A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
