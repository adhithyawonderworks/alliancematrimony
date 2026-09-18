import 'package:flutter/material.dart';

import '../../../services/app_localizations.dart';

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
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

  @override
  Widget build(BuildContext context) {
    final languages = AppLanguage.values;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final lang = languages[i];
          final isSelected = _localizations.currentLanguage == lang;
          return GestureDetector(
            onTap: () => _localizations.setLanguage(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC8556A)
                    : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC8556A)
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
              child: Text(
                AppLocalizations.languageCodes[lang]!,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF9A8A9E),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
