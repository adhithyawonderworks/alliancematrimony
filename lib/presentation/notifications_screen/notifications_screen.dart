import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final notifications = await _supabase.fetchNotifications();
    if (!mounted) return;

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });

    await _supabase.markAllNotificationsRead();
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Just now';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120D16),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFEEE0F0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEEE0F0),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC8556A)),
            )
          : _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final title = (item['title'] ?? 'New update') as String;
                final message =
                    (item['body'] ??
                            item['message'] ??
                            'You have a new update.')
                        as String;
                final createdAt = item['created_at'] as String?;
                final isUnread = item['is_read'] == false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? const Color(0xFF1E1520)
                        : const Color(0xFF181118),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnread
                          ? const Color(0xFFC8556A).withAlpha(100)
                          : const Color(0xFF2A1E2E),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? const Color(0xFFC8556A)
                              : const Color(0xFF6B5870),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEEE0F0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimestamp(createdAt),
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    color: Color(0xFF9A8A9E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Color(0xFFCCBDD0),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 32,
                color: Color(0xFF6B5870),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No new notifications yet',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEE0F0),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your matches, interests, and profile activity will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Color(0xFF9A8A9E),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
