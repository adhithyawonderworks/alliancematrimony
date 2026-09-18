
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/app_localizations.dart';
import '../../services/supabase_service.dart';
import '../chat_screen/chat_conversation_screen.dart';
import '../../widgets/report_user_bottom_sheet.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService.instance;
  final AppLocalizations _localizations = AppLocalizations();

  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _localizations.addListener(_onLanguageChanged);
    _loadMatches();
    _subscribeToInterests();
  }

  @override
  void dispose() {
    _animController.dispose();
    _localizations.removeListener(_onLanguageChanged);
    _channel?.unsubscribe();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _supabase.fetchMatches();
    if (mounted) {
      setState(() {
        _matches = data;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    }
  }

  void _subscribeToInterests() {
    _channel = _supabase.subscribeToInterests(
      onUpdate: () {
        if (mounted) _loadMatches();
      },
    );
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _openChat(Map<String, dynamic> match) async {
    final otherUserId = match['other_user_id'] as String?;
    if (otherUserId == null) return;

    final profile = match['profile'] as Map<String, dynamic>?;
    final firstName = profile?['first_name'] as String? ?? 'Match';
    final lastName = profile?['last_name'] as String? ?? '';
    final name = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
    final imageUrl = profile?['image_url'] as String? ?? '';

    final conversationId = await _supabase.getOrCreateConversation(otherUserId);
    if (!mounted || conversationId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          conversationId: conversationId,
          name: name,
          avatarUrl: imageUrl,
          isOnline: false,
          otherUserId: otherUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _matches.isEmpty
                  ? _buildEmptyState()
                  : _buildMatchesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Matches',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const Spacer(),
              if (_matches.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC8556A), Color(0xFFB03050)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_matches.length}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Mutual connections — both of you said yes!',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: Color(0xFF9A8A9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: const Color(0xFFC8556A),
      backgroundColor: const Color(0xFF1E1520),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return _buildMatchCard(match, index);
        },
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, int index) {
    final profile = match['profile'] as Map<String, dynamic>?;
    final firstName = profile?['first_name'] as String? ?? 'Unknown';
    final lastName = profile?['last_name'] as String? ?? '';
    final name = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
    final age = profile?['age'] as int?;
    final job = profile?['job'] as String? ?? '';
    final place = profile?['place'] as String? ?? '';
    final imageUrl = profile?['image_url'] as String? ?? '';
    final isVerified = profile?['is_verified'] as bool? ?? false;
    final matchedAt = _formatTimestamp(match['updated_at'] as String?);
    final otherUserId = match['other_user_id'] as String? ?? '';

    final delay = index * 0.08;
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        delay.clamp(0.0, 0.9),
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - animation.value)),
        child: Opacity(opacity: animation.value, child: child),
      ),
      child: GestureDetector(
        onTap: () => _openChat(match),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1520),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC8556A).withAlpha(51),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Subtle gradient shimmer top-left
                Positioned(
                  top: -20,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFC8556A).withAlpha(18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.white54,
                                          size: 28,
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.white54,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white54,
                                      size: 28,
                                    ),
                                  ),
                          ),
                          // Match badge
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC8556A),
                                    Color(0xFFE8A87C),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1E1520),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEEE0F0),
                                    ),
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Color(0xFF4A9EFF),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (age != null) ...[
                                  Text(
                                    '$age yrs',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: Color(0xFF9A8A9E),
                                    ),
                                  ),
                                  if (job.isNotEmpty)
                                    const Text(
                                      ' · ',
                                      style: TextStyle(
                                        color: Color(0xFF6B5870),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                                if (job.isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      job,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        color: Color(0xFF9A8A9E),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (place.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 11,
                                    color: Color(0xFF6B5870),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      place,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        color: Color(0xFF6B5870),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC8556A,
                                    ).withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.favorite_rounded,
                                        size: 10,
                                        color: Color(0xFFC8556A),
                                      ),
                                      const SizedBox(width: 3),
                                      const Text(
                                        'Matched',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFC8556A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (matchedAt.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    matchedAt,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      color: Color(0xFF6B5870),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Action buttons column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Chat button
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC8556A), Color(0xFFB03050)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC8556A).withAlpha(77),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Report button
                          GestureDetector(
                            onTap: () {
                              if (otherUserId.isNotEmpty) {
                                ReportUserBottomSheet.show(
                                  context,
                                  reportedUserId: otherUserId,
                                  reportedUserName: name,
                                );
                              }
                            },
                            child: Container(
                              width: 42,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1E2E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF3A2A40),
                                ),
                              ),
                              child: const Icon(
                                Icons.flag_outlined,
                                size: 14,
                                color: Color(0xFF9A8A9E),
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
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: 5,
      itemBuilder: (context, index) => _SkeletonMatchCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1520),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 36,
                color: Color(0xFF6B5870),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No matches yet',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFCCBDD0),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'When you and another person both accept each other\'s interest, they\'ll appear here as a match.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF6B5870),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8556A), Color(0xFFB03050)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Browse Profiles',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonMatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2030),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2030),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2030),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2030),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2030),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
