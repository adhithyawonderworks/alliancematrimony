import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/app_localizations.dart';
import '../../services/supabase_service.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppLocalizations _localizations = AppLocalizations();
  final SupabaseService _supabase = SupabaseService.instance;

  List<Map<String, dynamic>> _receivedInterests = [];
  List<Map<String, dynamic>> _sentInterests = [];
  bool _isLoadingReceived = true;
  bool _isLoadingSent = true;
  RealtimeChannel? _interestsChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _localizations.addListener(_onLanguageChanged);
    _loadData();
    _subscribeToInterests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _localizations.removeListener(_onLanguageChanged);
    _interestsChannel?.unsubscribe();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    await Future.wait([_loadReceived(), _loadSent()]);
  }

  Future<void> _loadReceived() async {
    if (!mounted) return;
    setState(() => _isLoadingReceived = true);
    final data = await _supabase.fetchReceivedInterests();
    if (mounted) {
      setState(() {
        _receivedInterests = data;
        _isLoadingReceived = false;
      });
    }
  }

  Future<void> _loadSent() async {
    if (!mounted) return;
    setState(() => _isLoadingSent = true);
    final data = await _supabase.fetchSentInterests();
    if (mounted) {
      setState(() {
        _sentInterests = data;
        _isLoadingSent = false;
      });
    }
  }

  void _subscribeToInterests() {
    _interestsChannel = _supabase.subscribeToInterests(
      onUpdate: () {
        if (mounted) _loadData();
      },
    );
  }

  Future<void> _acceptInterest(String interestId) async {
    final success = await _supabase.acceptInterest(interestId);
    if (!mounted) return;
    if (success) {
      setState(() {
        final idx = _receivedInterests.indexWhere((i) => i['id'] == interestId);
        if (idx != -1) {
          _receivedInterests[idx] = {
            ..._receivedInterests[idx],
            'status': 'accepted',
          };
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizations.get('interest_accepted'),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
          backgroundColor: const Color(0xFF2D7A4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _declineInterest(String interestId) async {
    final success = await _supabase.declineInterest(interestId);
    if (!mounted) return;
    if (success) {
      setState(() {
        final idx = _receivedInterests.indexWhere((i) => i['id'] == interestId);
        if (idx != -1) {
          _receivedInterests[idx] = {
            ..._receivedInterests[idx],
            'status': 'declined',
          };
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizations.get('interest_declined'),
            style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
          backgroundColor: const Color(0xFF3A2E40),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildReceivedTab(), _buildSentTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
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
                _localizations.get('interests_title'),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your connections and discover matches',
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

  Widget _buildTabBar() {
    final receivedCount = _receivedInterests
        .where((i) => i['status'] == 'pending')
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1520),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC8556A), Color(0xFFB03050)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF8A7A90),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_rounded, size: 15),
                  const SizedBox(width: 6),
                  Text(_localizations.get('received')),
                  if (receivedCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8556A).withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$receivedCount',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC8556A),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 15),
                  const SizedBox(width: 6),
                  Text(_localizations.get('sent')),
                  if (_sentInterests.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A87C).withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_sentInterests.length}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8A87C),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_isLoadingReceived) return _buildLoadingState();
    if (_receivedInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_rounded,
        title: 'No interests yet',
        subtitle: 'When someone sends you an interest, it will appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadReceived,
      color: const Color(0xFFC8556A),
      backgroundColor: const Color(0xFF1E1520),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        itemCount: _receivedInterests.length,
        itemBuilder: (context, index) {
          final interest = _receivedInterests[index];
          return _InterestCard(
            interest: interest,
            isReceived: true,
            formatTimestamp: _formatTimestamp,
            onAccept: () => _acceptInterest(interest['id'] as String),
            onDecline: () => _declineInterest(interest['id'] as String),
          );
        },
      ),
    );
  }

  Widget _buildSentTab() {
    if (_isLoadingSent) return _buildLoadingState();
    if (_sentInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_rounded,
        title: 'No interests sent',
        subtitle: 'Browse profiles and send interests to connect with matches.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSent,
      color: const Color(0xFFC8556A),
      backgroundColor: const Color(0xFF1E1520),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        itemCount: _sentInterests.length,
        itemBuilder: (context, index) {
          final interest = _sentInterests[index];
          return _InterestCard(
            interest: interest,
            isReceived: false,
            formatTimestamp: _formatTimestamp,
            onAccept: () {},
            onDecline: () {},
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: 4,
      itemBuilder: (context, index) => _SkeletonCard(),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1520),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF6B5870)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCCBDD0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: Color(0xFF6B5870),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final Map<String, dynamic> interest;
  final bool isReceived;
  final String Function(String?) formatTimestamp;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InterestCard({
    required this.interest,
    required this.isReceived,
    required this.formatTimestamp,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final profile = interest['profile'] as Map<String, dynamic>?;
    final status = interest['status'] as String? ?? 'pending';
    final timestamp = formatTimestamp(interest['created_at'] as String?);
    final firstName = profile?['first_name'] as String? ?? 'Unknown';
    final lastName = profile?['last_name'] as String? ?? '';
    final maskedName = lastName.isNotEmpty
        ? '$firstName ${lastName[0]}***'
        : firstName;
    final age = profile?['age'] as int?;
    final job = profile?['job'] as String? ?? '';
    final place = profile?['place'] as String? ?? '';
    final heightCm = profile?['height_cm'] as String? ?? '';
    final imageUrl = profile?['image_url'] as String? ?? '';
    final isVerified = profile?['is_verified'] as bool? ?? false;
    final message = interest['message'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF2D7A4F);
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Accepted';
        break;
      case 'declined':
        statusColor = const Color(0xFF8A7A90);
        statusIcon = Icons.cancel_rounded;
        statusLabel = 'Declined';
        break;
      default:
        statusColor = const Color(0xFFE8A87C);
        statusIcon = Icons.schedule_rounded;
        statusLabel = isReceived ? 'Awaiting response' : 'Pending';
    }

    final isPendingReceived = isReceived && status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isPendingReceived
            ? const Color(0xFF221520)
            : const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPendingReceived
              ? const Color(0xFFC8556A).withAlpha(100)
              : status == 'accepted'
              ? const Color(0xFF2D7A4F).withAlpha(77)
              : const Color(0x1AFFFFFF),
          width: isPendingReceived ? 1.5 : 1,
        ),
        boxShadow: isPendingReceived
            ? [
                BoxShadow(
                  color: const Color(0xFFC8556A).withAlpha(25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 72,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 72,
                            height: 80,
                            color: const Color(0xFF2A1E2E),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF6B5870),
                              size: 28,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 72,
                            height: 80,
                            color: const Color(0xFF2A1E2E),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF6B5870),
                              size: 28,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1E2E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6B5870),
                            size: 28,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Profile info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              maskedName,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEEE0F0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A4A8A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: Color(0xFF60A5FA),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (age != null || job.isNotEmpty)
                        Text(
                          [
                            if (age != null) '$age yrs',
                            if (job.isNotEmpty) job,
                          ].join(' • '),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Color(0xFFCCBDD0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 3),
                      if (place.isNotEmpty || heightCm.isNotEmpty)
                        Row(
                          children: [
                            if (place.isNotEmpty) ...[
                              const Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: Color(0xFF9A8A9E),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  place,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: Color(0xFF9A8A9E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (place.isNotEmpty && heightCm.isNotEmpty)
                              const Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B5870),
                                ),
                              ),
                            if (heightCm.isNotEmpty)
                              Text(
                                heightCm,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  color: Color(0xFF9A8A9E),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      // Timestamp + status row
                      Row(
                        children: [
                          if (isPendingReceived)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC8556A).withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFC8556A).withAlpha(60),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 10,
                                    color: Color(0xFFC8556A),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    timestamp,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFC8556A),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            Icon(
                              isReceived
                                  ? Icons.call_received_rounded
                                  : Icons.send_rounded,
                              size: 11,
                              color: isReceived
                                  ? const Color(0xFFC8556A)
                                  : const Color(0xFFE8A87C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timestamp,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: Color(0xFF9A8A9E),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(31),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 10, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Message if present
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 14,
                      color: Color(0xFF9A8A9E),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Color(0xFFCCBDD0),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Accept / Decline actions for pending received interests
            if (isReceived && status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onDecline,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1E2E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0x33FFFFFF),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF9A8A9E),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Decline',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9A8A9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC8556A), Color(0xFFB03050)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Accept',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1520),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E2E),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1E2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 11,
                    width: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1E2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 11,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1E2E),
                      borderRadius: BorderRadius.circular(6),
                    ),
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
