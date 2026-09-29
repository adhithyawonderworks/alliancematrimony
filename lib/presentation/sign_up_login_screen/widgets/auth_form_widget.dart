import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import './signup_fields_widget.dart';
import '../../../services/supabase_service.dart';

// Signup steps enum
enum _SignupStep {
  agreement,
  emailEntry, // Step 1: enter email + password
  profileForm, // Step 2: fill full profile & create account
}

class AuthFormWidget extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onToggleMode;
  final VoidCallback onAuthSuccess;

  const AuthFormWidget({
    super.key,
    required this.isLogin,
    required this.onToggleMode,
    required this.onAuthSuccess,
  });

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _agreementAcceptedAt;

  // Signup step state
  _SignupStep _signupStep = _SignupStep.emailEntry;

  // Profile data collected from the form
  Map<String, dynamic> _profileData = {};
  XFile? _selectedProfileImage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    if (!widget.isLogin) _signupStep = _SignupStep.agreement;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(covariant AuthFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLogin && !widget.isLogin) {
      _agreementAcceptedAt = null;
      _signupStep = _SignupStep.agreement;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _animateTransition(VoidCallback stateChange) {
    _fadeController.reverse().then((_) {
      setState(stateChange);
      _fadeController.forward();
    });
  }

  void _handleSubmit() async {
    if (widget.isLogin) {
      // Login with email + password
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email.isEmpty || !email.contains('@')) {
        _showError('Enter a valid email address');
        return;
      }
      if (password.isEmpty || password.length < 6) {
        _showError('Password must be at least 6 characters');
        return;
      }
      setState(() => _isLoading = true);
      final error = await SupabaseService.instance.signInWithPassword(
        email,
        password,
      );
      setState(() => _isLoading = false);
      if (error != null) {
        _showError('Login failed: $error');
        return;
      }
      widget.onAuthSuccess();
      return;
    }

    // Signup flow
    switch (_signupStep) {
      case _SignupStep.agreement:
        _agreementAcceptedAt = DateTime.now().toUtc();
        _animateTransition(() => _signupStep = _SignupStep.emailEntry);
        break;
      case _SignupStep.emailEntry:
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final confirmPassword = _confirmPasswordController.text;
        if (email.isEmpty || !email.contains('@')) {
          _showError('Enter a valid email address');
          return;
        }
        if (password.isEmpty || password.length < 6) {
          _showError('Password must be at least 6 characters');
          return;
        }
        if (password != confirmPassword) {
          _showError('Passwords do not match');
          return;
        }
        setState(() => _isLoading = true);
        final error = await SupabaseService.instance.signUpWithPassword(
          email,
          password,
          metadata: {
            'truthfulness_agreement_accepted_at': _agreementAcceptedAt
                ?.toIso8601String(),
          },
        );
        setState(() => _isLoading = false);
        if (error != null) {
          _showError('Sign up failed: $error');
          return;
        }
        _animateTransition(() => _signupStep = _SignupStep.profileForm);
        break;

      case _SignupStep.profileForm:
        if (!(_formKey.currentState?.validate() ?? false)) return;
        if (_profileData['truthfulness_confirmed'] != true) {
          _showError('Please confirm that your profile details are true.');
          return;
        }
        final imageUrl = _profileData['image_url'] as String? ?? '';
        if (_selectedProfileImage == null || !imageUrl.startsWith('http')) {
          _showError('Please wait for your profile photo to finish uploading.');
          return;
        }
        setState(() => _isLoading = true);
        try {
          if (_profileData.isEmpty) {
            throw Exception('Complete the profile form before continuing.');
          }
          _profileData['truthfulness_confirmed_at'] = _agreementAcceptedAt
              ?.toIso8601String();
          await SupabaseService.instance.upsertProfile(_profileData);
          await SupabaseService.instance.recordTruthfulnessSubmission(
            acceptedAt: _agreementAcceptedAt!,
            profileSnapshot: _profileData,
          );
        } catch (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showError(error.toString().replaceFirst('Exception: ', ''));
          }
          return;
        }
        if (!mounted) return;
        setState(() => _isLoading = false);
        widget.onAuthSuccess();
        break;
    }
  }

  void _onEmailOtpVerified() {
    _animateTransition(() => _signupStep = _SignupStep.profileForm);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        backgroundColor: const Color(0xFFB91C1C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String get _submitButtonLabel {
    if (widget.isLogin) {
      return 'Login';
    }
    switch (_signupStep) {
      case _SignupStep.agreement:
        return 'Accept';
      case _SignupStep.emailEntry:
        return 'Create Account';
      case _SignupStep.profileForm:
        return 'Continue';
    }
  }

  bool get _showSubmitButton {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1520).withAlpha(191),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x33FFFFFF), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_signupStep != _SignupStep.agreement) ...[
                      _buildModeToggle(),
                      const SizedBox(height: 24),
                      if (!widget.isLogin) _buildSignupStepIndicator(),
                      if (!widget.isLogin) const SizedBox(height: 20),
                    ],
                    if (widget.isLogin)
                      _buildLoginContent()
                    else
                      _buildSignupStepContent(),
                    const SizedBox(height: 20),
                    if (_showSubmitButton) _buildSubmitButton(),
                    if (_signupStep != _SignupStep.agreement) ...[
                      const SizedBox(height: 16),
                      _buildToggleLink(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupStepIndicator() {
    final steps = [
      ('Email', Icons.email_outlined),
      ('Profile', Icons.person_outline_rounded),
    ];

    int activeIndex;
    switch (_signupStep) {
      case _SignupStep.agreement:
        activeIndex = 0;
        break;
      case _SignupStep.emailEntry:
        activeIndex = 0;
        break;
      case _SignupStep.profileForm:
        activeIndex = 1;
        break;
    }

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? const Color(0xFF4ADE80) : const Color(0x33FFFFFF),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < activeIndex;
        final isActive = stepIndex == activeIndex;
        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFF0D3D22)
                    : isActive
                    ? const Color(0xFFC8556A)
                    : const Color(0x1AFFFFFF),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF2D7A4F)
                      : isActive
                      ? const Color(0xFFC8556A)
                      : const Color(0x33FFFFFF),
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Color(0xFF4ADE80),
                    )
                  : Icon(
                      steps[stepIndex].$2,
                      size: 16,
                      color: isActive ? Colors.white : const Color(0xFF9A8A9E),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex].$1,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isDone
                    ? const Color(0xFF4ADE80)
                    : isActive
                    ? const Color(0xFFEEE0F0)
                    : const Color(0xFF9A8A9E),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoginContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.lock_outline_rounded,
          title: 'Welcome Back',
          subtitle: 'Enter your email and password to continue',
        ),
        const SizedBox(height: 16),
        _buildGlassField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              (v == null || !v.contains('@')) ? 'Enter valid email' : null,
        ),
        const SizedBox(height: 14),
        _buildGlassField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: const Color(0xFF9A8A9E),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (v) =>
              (v == null || v.length < 6) ? 'Min 6 characters' : null,
        ),
      ],
    );
  }

  Widget _buildSignupStepContent() {
    switch (_signupStep) {
      case _SignupStep.agreement:
        return _buildAgreementStep();
      case _SignupStep.emailEntry:
        return _buildEmailPasswordStep();
      case _SignupStep.profileForm:
        return SignupFieldsWidget(
          formKey: _formKey,
          selectedImageFile: _selectedProfileImage,
          onImageChanged: (file) {
            setState(() => _selectedProfileImage = file);
          },
          onDataChanged: (data) {
            _profileData = data;
          },
        );
    }
  }

  Widget _buildAgreementStep() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, color: Color(0xFFC8556A), size: 30),
          SizedBox(height: 16),
          Text(
            'Declaration of truthful information',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEE0F0),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'I agree that all details I provide in my profile are true and accurate to the best of my knowledge.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              height: 1.6,
              color: Color(0xFFB7A8BC),
            ),
          ),
        ],
      ),
    );
  }

  void _beginSignup() {
    _agreementAcceptedAt = null;
    widget.onToggleMode();
    _animateTransition(() => _signupStep = _SignupStep.agreement);
  }

  Widget _buildEmailPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.email_outlined,
          title: 'Create Your Account',
          subtitle: 'Enter your email and set a password to get started',
        ),
        const SizedBox(height: 16),
        _buildGlassField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              (v == null || !v.contains('@')) ? 'Enter valid email' : null,
        ),
        const SizedBox(height: 14),
        _buildGlassField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a password (min 6 characters)',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: const Color(0xFF9A8A9E),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (v) =>
              (v == null || v.length < 6) ? 'Min 6 characters' : null,
        ),
        const SizedBox(height: 14),
        _buildGlassField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: const Color(0xFF9A8A9E),
            ),
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please confirm your password' : null,
        ),
      ],
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFC8556A).withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC8556A).withAlpha(80),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFC8556A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEE0F0),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: Color(0xFF9A8A9E),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9A8A9E),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Color(0xFFEEE0F0),
              ),
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF9A8A9E),
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: const Color(0x1AFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFC8556A),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFB91C1C),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8556A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _submitButtonLabel,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.isLogin
              ? "Don't have an account? "
              : 'Already have an account? ',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: Color(0xFF9A8A9E),
          ),
        ),
        GestureDetector(
          onTap: widget.onToggleMode,
          child: Text(
            widget.isLogin ? 'Sign Up' : 'Login',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC8556A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: widget.isLogin ? null : widget.onToggleMode,
          child: Text(
            'Login',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: widget.isLogin ? FontWeight.w700 : FontWeight.w400,
              color: widget.isLogin
                  ? const Color(0xFFC8556A)
                  : const Color(0xFF9A8A9E),
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: widget.isLogin ? widget.onToggleMode : null,
          child: Text(
            'Sign Up',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: !widget.isLogin ? FontWeight.w700 : FontWeight.w400,
              color: !widget.isLogin
                  ? const Color(0xFFC8556A)
                  : const Color(0xFF9A8A9E),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Single-step OTP widget ───────────────────────────────────────────────────

class _SingleOtpWidget extends StatefulWidget {
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final bool isLoading;
  final Future<String?> Function(String otp)? onVerifyWithOtp;

  const _SingleOtpWidget({
    required this.onVerify,
    required this.onResend,
    required this.isLoading,
  }) : onVerifyWithOtp = null;

  @override
  State<_SingleOtpWidget> createState() => _SingleOtpWidgetState();
}

class _SingleOtpWidgetState extends State<_SingleOtpWidget> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _verifying = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Enter all 6 digits',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => _verifying = true);
    if (widget.onVerifyWithOtp != null) {
      final error = await widget.onVerifyWithOtp!(otp);
      if (!mounted) return;
      setState(() => _verifying = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid OTP: $error',
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
            backgroundColor: const Color(0xFFB91C1C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _verifying = false);
    }
    widget.onVerify();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 40,
                    height: 48,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEEE0F0),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0x1AFFFFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0x33FFFFFF),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0x33FFFFFF),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFC8556A),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8556A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: widget.onResend,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: Color(0xFF9A8A9E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
