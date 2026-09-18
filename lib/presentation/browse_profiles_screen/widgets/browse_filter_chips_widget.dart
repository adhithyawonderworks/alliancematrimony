import 'package:flutter/material.dart';

import '../../../services/app_localizations.dart';

class BrowseFilterChipsWidget extends StatefulWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const BrowseFilterChipsWidget({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  State<BrowseFilterChipsWidget> createState() =>
      _BrowseFilterChipsWidgetState();
}

class _BrowseFilterChipsWidgetState extends State<BrowseFilterChipsWidget> {
  final AppLocalizations _localizations = AppLocalizations();

  @override
  void initState() {
    super.initState();
    _localizations.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _localizations.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _filters => [
    {
      'label': 'All',
      'localizedLabel': _localizations.get('filter_all'),
      'icon': Icons.grid_view_rounded,
    },
    {
      'label': 'New',
      'localizedLabel': _localizations.get('filter_new'),
      'icon': Icons.fiber_new_rounded,
    },
    {
      'label': 'Verified',
      'localizedLabel': _localizations.get('filter_verified'),
      'icon': Icons.verified_rounded,
    },
    {
      'label': 'Hindu',
      'localizedLabel': 'Hindu',
      'icon': Icons.temple_hindu_rounded,
    },
    {
      'label': 'Christian',
      'localizedLabel': 'Christian',
      'icon': Icons.church_rounded,
    },
    {
      'label': 'Muslim',
      'localizedLabel': 'Muslim',
      'icon': Icons.mosque_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = _filters[i];
          final isActive = widget.activeFilter == filter['label'];
          return GestureDetector(
            onTap: () => widget.onFilterChanged(filter['label'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFC8556A)
                    : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFC8556A)
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 12,
                    color: isActive ? Colors.white : const Color(0xFF9A8A9E),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    filter['localizedLabel'] as String,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF9A8A9E),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
