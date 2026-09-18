import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../services/app_localizations.dart';
import './widgets/auth_background_widget.dart';
import './widgets/auth_form_widget.dart';
import './widgets/language_selector_widget.dart';

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen> {
  bool _isLogin = true;
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

  void _onAuthSuccess() {
    context.go(AppRoutes.browseProfilesScreen);
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF120D16),
      body: Stack(
        children: [
          const AuthBackgroundWidget(),
          SafeArea(
            child: SingleChildScrollView(
              child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        const SizedBox(height: 40),
        _buildLogoSection(),
        const SizedBox(height: 16),
        const LanguageSelectorWidget(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AuthFormWidget(
            isLogin: _isLogin,
            onToggleMode: _toggleMode,
            onAuthSuccess: _onAuthSuccess,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: 480,
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildLogoSection(),
            const SizedBox(height: 16),
            const LanguageSelectorWidget(),
            const SizedBox(height: 24),
            AuthFormWidget(
              isLogin: _isLogin,
              onToggleMode: _toggleMode,
              onAuthSuccess: _onAuthSuccess,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC8556A), Color(0xFFE8A87C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC8556A).withAlpha(102),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _localizations.currentLanguage == AppLanguage.english
                    ? 'Alliance'
                    : _localizations.get('app_name'),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              if (_localizations.currentLanguage == AppLanguage.english)
                const TextSpan(
                  text: ' Matrimony',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFC8556A),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _localizations.get('tagline'),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFF9A8A9E),
          ),
        ),
      ],
    );
  }
}
