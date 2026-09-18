import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_localizations.dart';
import '../services/supabase_service.dart';

class _TabSpec {
  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;
  const _TabSpec({
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;
  final AppLocalizations _localizations = AppLocalizations();
  final SupabaseService _supabase = SupabaseService.instance;

  int _pendingInterestsCount = 0;
  int _unreadNotificationCount = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      labelKey: 'discover',
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      labelKey: 'interests',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      branchIndex: 1,
    ),
    _TabSpec(
      labelKey: 'matches',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      branchIndex: 2,
    ),
    _TabSpec(
      labelKey: 'messages',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      branchIndex: 3,
    ),
    _TabSpec(
      labelKey: 'my_profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      branchIndex: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _localizations.addListener(_onLanguageChanged);
    _loadPendingCount();
    _loadUnreadNotificationCount();
    _supabase.subscribeToInterests(onUpdate: _loadPendingCount);
    _supabase.subscribeToNotifications(onNew: (_) => _loadUnreadNotificationCount());
  }

  @override
  void dispose() {
    _localizations.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPendingCount() async {
    final received = await _supabase.fetchReceivedInterests();
    final count = received.where((i) => i['status'] == 'pending').length;
    if (mounted) setState(() => _pendingInterestsCount = count);
  }

  Future<void> _loadUnreadNotificationCount() async {
    final count = await _supabase.fetchUnreadNotificationCount();
    if (mounted) setState(() => _unreadNotificationCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 16,
        right: 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1520).withAlpha(179),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withAlpha(31), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = i == _selectedVisualIndex;
                final totalBadgeCount = _pendingInterestsCount + _unreadNotificationCount;
                final showBadge = i == 1 && totalBadgeCount > 0;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedVisualIndex = i);
                    widget.navigationShell.goBranch(
                      tab.branchIndex!,
                      initialLocation:
                          tab.branchIndex ==
                          widget.navigationShell.currentIndex,
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFC8556A).withAlpha(46)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isActive ? tab.selectedIcon : tab.icon,
                                key: ValueKey(isActive),
                                size: 22,
                                color: isActive
                                    ? const Color(0xFFC8556A)
                                    : const Color(0xFF8A7A90),
                              ),
                            ),
                            if (showBadge)
                              Positioned(
                                top: -4,
                                right: -6,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC8556A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF1E1520),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    totalBadgeCount > 99
                                        ? '99+'
                                        : '$totalBadgeCount',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFFC8556A)
                                : const Color(0xFF8A7A90),
                          ),
                          child: Text(
                            tab.labelKey == 'matches'
                                ? 'Matches'
                                : _localizations.get(tab.labelKey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
