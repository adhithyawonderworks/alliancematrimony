import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final bool phoneOtpVerified;
  final bool emailOtpVerified;
  final VoidCallback onPhoneVerified;
  final VoidCallback onEmailVerified;

  const OtpInputWidget({
    super.key,
    required this.phoneOtpVerified,
    required this.emailOtpVerified,
    required this.onPhoneVerified,
    required this.onEmailVerified,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final List<TextEditingController> _phoneOtpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _emailOtpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _phoneFocusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _emailFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _phoneOtpControllers) {
      c.dispose();
    }
    for (final c in _emailOtpControllers) {
      c.dispose();
    }
    for (final n in _phoneFocusNodes) {
      n.dispose();
    }
    for (final n in _emailFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _verifyPhone() {
    _verifyOtp(
      controllers: _phoneOtpControllers,
      callback: widget.onPhoneVerified,
    );
  }

  void _verifyEmail() {
    _verifyOtp(
      controllers: _emailOtpControllers,
      callback: widget.onEmailVerified,
    );
  }

  void _verifyOtp({
    required List<TextEditingController> controllers,
    required VoidCallback callback,
  }) {
    final otp = controllers.map((controller) => controller.text).join();
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

    callback();
  }

  void _resendPhone() {
    _clearOtpFields(_phoneOtpControllers, _phoneFocusNodes);
  }

  void _resendEmail() {
    _clearOtpFields(_emailOtpControllers, _emailFocusNodes);
  }

  void _clearOtpFields(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].clear();
      focusNodes[i].unfocus();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOtpSection(
          title: 'Mobile OTP Verification',
          subtitle: 'Enter the 6-digit OTP sent to your mobile number',
          controllers: _phoneOtpControllers,
          focusNodes: _phoneFocusNodes,
          isVerified: widget.phoneOtpVerified,
          onVerify: _verifyPhone,
          onResend: _resendPhone,
        ),
        const SizedBox(height: 20),
        _buildOtpSection(
          title: 'Email OTP Verification',
          subtitle: 'Enter the 6-digit OTP sent to your email',
          controllers: _emailOtpControllers,
          focusNodes: _emailFocusNodes,
          isVerified: widget.emailOtpVerified,
          onVerify: _verifyEmail,
          onResend: _resendEmail,
        ),
      ],
    );
  }

  Widget _buildOtpSection({
    required String title,
    required String subtitle,
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required bool isVerified,
    required VoidCallback onVerify,
    required VoidCallback onResend,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isVerified
                  ? const Color(0xFF2D7A4F)
                  : const Color(0x33FFFFFF),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEE0F0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: Color(0xFF9A8A9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3D22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Color(0xFF4ADE80),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF4ADE80),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (!isVerified) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 40,
                      height: 48,
                      child: TextFormField(
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                            focusNodes[i + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onVerify,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC8556A)),
                          foregroundColor: const Color(0xFFC8556A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
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
                      onPressed: onResend,
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
            ],
          ),
        ),
      ),
    );
  }
}
